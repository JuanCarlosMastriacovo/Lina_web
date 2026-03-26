from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from datetime import date
from decimal import Decimal
import traceback

from CapaBRL.linabase import linabase
from CapaBRL.config import (
    DEFAULT_EMPR_CODE, CODM_FCHE,
    MAX_LINEAS_FCHE, FMT_NROCOMP, LEN_TEXTO_LARGO,
)
from CapaBRL.stock_brl import get_existencia_articulo
from CapaBRL.compras_brl import crear_factura
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import sess_conns, ctx_empr, ctx_date


# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA31"
ROUTE_BASE = "/lina31"

LinaArti = get_table_model("linaarti")
LinaProv = get_table_model("linaprov")


# ==================== CLASE PRINCIPAL ====================

class Lina31(linabase):
    """Módulo de Registro de Facturas de Compra (LINA31)."""
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
async def lina31_index(request: Request):
    Lina31.set_prog_code(PROG_CODE)
    user = Lina31.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    is_htmx = request.headers.get("HX-Request") == "true"
    ctx = {"request": request, "max_lineas": MAX_LINEAS_FCHE}
    if is_htmx:
        return Lina31.templates.TemplateResponse("lina31/form.html", ctx)
    return Lina31.templates.TemplateResponse("lina31/main.html", ctx)


@router.get("/prov/info")
async def lina31_prov_info(provcodi: str = Query(default="")):
    empr = _get_empr()
    try:
        cod = int(provcodi)
    except (ValueError, TypeError):
        return JSONResponse({"ok": False, "provname": ""})
    rec = LinaProv.row_get({"emprcodi": empr, "provcodi": cod})
    if not rec:
        return JSONResponse({"ok": False, "provname": ""})
    return JSONResponse({"ok": True, "provname": str(rec.get("provname") or "").strip()})


@router.get("/arti/info")
async def lina31_arti_info(articodi: str = Query(default="")):
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
        "existencia": existencia,
    })


@router.post("/save")
async def lina31_save(request: Request):
    user = Lina31.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    try:
        data = await request.json()
    except Exception:
        return JSONResponse({"ok": False, "error": "Datos inválidos"}, status_code=400)

    empr     = _get_empr()
    fchefech = _get_fecha_sesion()

    # ── Parse header ────────────────────────────────────────────────────────
    try:
        provcodi = int(data.get("provcodi", 0))
    except (ValueError, TypeError):
        provcodi = 0
    if provcodi <= 0:
        return JSONResponse(
            {"ok": False, "error": "Debe ingresar un código de proveedor válido."},
            status_code=400,
        )

    fcheobse = str(data.get("fcheobse", "")).strip()[:LEN_TEXTO_LARGO]

    # ── Parse detail lines ───────────────────────────────────────────────────
    lineas_raw = data.get("lineas", [])
    lineas     = []
    reng       = 0
    for ln in lineas_raw:
        articodi = str(ln.get("articodi", "")).strip().upper()
        if not articodi:
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
            "fcdereng": reng,
            "articodi": articodi,
            "fcdedesc": desc,
            "fcdecant": cant,
            "fcdeunit": unit,
        })

    # ── Validate ────────────────────────────────────────────────────────────
    fchetota = sum(ln["fcdecant"] * ln["fcdeunit"] for ln in lineas)
    if not lineas or fchetota == Decimal(0):
        return JSONResponse(
            {"ok": False, "error": "No se admiten comprobantes vacíos o con total cero."},
            status_code=400,
        )

    # ── Get connection ────────────────────────────────────────────────────────
    tab_id    = Lina31.get_tab_id(request)
    conn      = Lina31.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn      = sess_conns.get_conn(readonly=False)
        owns_conn = True

    try:
        fchenume = crear_factura(
            conn, empr, fchefech, provcodi, fcheobse, lineas,
            fchetota, CODM_FCHE,
        )

        if user and tab_id and not owns_conn:
            sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=PROG_CODE)
        else:
            conn.commit()

        msg = f"{CODM_FCHE} N° {fchenume:{FMT_NROCOMP}} registrada."
        return JSONResponse({"ok": True, "fchenume": fchenume, "message": msg})

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
