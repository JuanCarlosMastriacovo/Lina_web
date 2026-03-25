from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from datetime import date
from decimal import Decimal
import traceback

from CapaBRL.linabase import linabase
from CapaBRL.config import (
    DEFAULT_EMPR_CODE, CODM_REMI, CODM_RECI, CLIE_AJUSTE,
    MAX_LINEAS_REMITO, FMT_NROCOMP, LEN_TEXTO_LARGO,
)
from CapaBRL.stock_brl import get_existencia_articulo
from CapaBRL.remitos_brl import crear_remito_con_cobro
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import sess_conns, ctx_empr, ctx_date


# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA21"
ROUTE_BASE = "/lina21"

LinaArti = get_table_model("linaarti")
LinaClie = get_table_model("linaclie")


# ==================== CLASE PRINCIPAL ====================

class Lina21(linabase):
    """Módulo de Emisión de Remitos de Venta (LINA21)."""
    pass


# ==================== FUNCIONES AUXILIARES ====================

def _get_empr() -> str:
    """Retorna el código de empresa activo en la sesión."""
    return ctx_empr.get() or DEFAULT_EMPR_CODE


def _get_fecha_sesion() -> date:
    """Retorna la fecha de sesión (ctx_date) como objeto date."""
    raw = ctx_date.get()
    if raw:
        try:
            return date.fromisoformat(raw)
        except ValueError:
            pass
    return date.today()


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina21_index(request: Request):
    Lina21.set_prog_code(PROG_CODE)
    user = Lina21.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    is_htmx = request.headers.get("HX-Request") == "true"
    ctx = {"request": request, "clie_ajuste": CLIE_AJUSTE, "max_lineas": MAX_LINEAS_REMITO}
    if is_htmx:
        return Lina21.templates.TemplateResponse("lina21/form.html", ctx)
    return Lina21.templates.TemplateResponse("lina21/main.html", ctx)


@router.get("/clie/info")
async def lina21_clie_info(cliecodi: str = Query(default="")):
    empr = _get_empr()
    try:
        cod = int(cliecodi)
    except (ValueError, TypeError):
        return JSONResponse({"ok": False, "cliename": ""})
    rec = LinaClie.row_get({"emprcodi": empr, "cliecodi": cod})
    if not rec:
        return JSONResponse({"ok": False, "cliename": ""})
    return JSONResponse({"ok": True, "cliename": str(rec.get("cliename") or "").strip()})


@router.get("/arti/info")
async def lina21_arti_info(articodi: str = Query(default="")):
    empr     = _get_empr()
    articodi = articodi.strip().upper()
    if not articodi:
        return JSONResponse({"ok": False})
    rec = LinaArti.row_get({"emprcodi": empr, "articodi": articodi})
    if not rec:
        return JSONResponse({"ok": False, "error": "Artículo no encontrado"})

    conn = sess_conns.get_conn(readonly=True)
    try:
        existencia = get_existencia_articulo(empr, articodi, conn)
    finally:
        sess_conns.release_conn(conn)

    return JSONResponse({
        "ok":         True,
        "artidesc":   str(rec.get("artidesc") or "").strip(),
        "artiprec":   float(rec.get("artiprec") or 0),
        "existencia": existencia,
    })


@router.post("/save")
async def lina21_save(request: Request):
    user = Lina21.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    try:
        data = await request.json()
    except Exception:
        return JSONResponse({"ok": False, "error": "Datos inválidos"}, status_code=400)

    empr     = _get_empr()
    fvhefech = _get_fecha_sesion()   # fecha de sesión, no la envía el frontend

    # ── Parse header ────────────────────────────────────────────────────────
    try:
        cliecodi = int(data.get("cliecodi", 0))
    except (ValueError, TypeError):
        cliecodi = 0
    if cliecodi <= 0:
        return JSONResponse({"ok": False, "error": "Debe ingresar un código de cliente válido."}, status_code=400)

    fvheobse = str(data.get("fvheobse", "")).strip()[:LEN_TEXTO_LARGO]

    try:
        efec = Decimal(str(data.get("efec", 0) or 0))
        banc = Decimal(str(data.get("banc", 0) or 0))
    except Exception:
        efec = Decimal(0)
        banc = Decimal(0)
    if efec < 0:
        efec = Decimal(0)
    if banc < 0:
        banc = Decimal(0)

    # ── Parse detail lines ───────────────────────────────────────────────────
    lineas_raw = data.get("lineas", [])
    lineas     = []
    reng       = 0
    for ln in lineas_raw:
        articodi = str(ln.get("articodi", "")).strip().upper()
        if not articodi or articodi == "*":
            continue
        reng += 1
        desc = str(ln.get("desc", "")).strip()[:LEN_TEXTO_LARGO]
        try:
            cant = int(ln.get("cant", 0) or 0)
        except (ValueError, TypeError):
            cant = 0
        try:
            unit = Decimal(str(ln.get("unit", 0) or 0))
        except Exception:
            unit = Decimal(0)
        lineas.append({
            "fvdereng": reng,
            "articodi": articodi,
            "fvdedesc": desc,
            "fvdecant": cant,
            "fvdeunit": unit,
        })

    # ── Validate ────────────────────────────────────────────────────────────
    is_ajuste = (cliecodi == CLIE_AJUSTE)
    fvhetota  = Decimal(0) if is_ajuste else sum(ln["fvdecant"] * ln["fvdeunit"] for ln in lineas)
    if not is_ajuste:
        if not lineas or fvhetota <= 0:
            return JSONResponse(
                {"ok": False, "error": "No se admiten comprobantes vacíos o con total cero."},
                status_code=400,
            )

    # ── Get connection ────────────────────────────────────────────────────────
    tab_id    = Lina21.get_tab_id(request)
    conn      = Lina21.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn      = sess_conns.get_conn(readonly=False)
        owns_conn = True

    try:
        fvhenume, cohenume = crear_remito_con_cobro(
            conn, empr, fvhefech, cliecodi, fvheobse, lineas,
            efec, banc, is_ajuste, fvhetota, CODM_REMI, CODM_RECI,
        )

        if user and tab_id and not owns_conn:
            sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=PROG_CODE)
        else:
            conn.commit()

        msg = f"{CODM_REMI} N° {fvhenume:{FMT_NROCOMP}} grabado."
        if cohenume:
            msg += f"  Recibo N° {cohenume:{FMT_NROCOMP}}."
        return JSONResponse({"ok": True, "fvhenume": fvhenume, "cohenume": cohenume, "message": msg})

    except ValueError as e:
        if owns_conn:
            try: conn.rollback()
            except Exception: pass
        return JSONResponse({"ok": False, "error": str(e)}, status_code=400)
    except Exception as e:
        try:
            conn.rollback()
        except Exception:
            pass
        traceback.print_exc()
        return JSONResponse({"ok": False, "error": str(e)}, status_code=500)
    finally:
        if owns_conn:
            sess_conns.release_conn(conn)
