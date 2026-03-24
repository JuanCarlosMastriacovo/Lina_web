from datetime import date
from decimal import Decimal
import traceback

from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse

from CapaBRL.linabase import linabase
from CapaBRL.config import (
    DEFAULT_EMPR_CODE, CODM_RECI, MAX_LINEAS_RECIBO, FMT_NROCOMP, LEN_TEXTO_LARGO,
)
from CapaBRL.recibos_brl import crear_recibo
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import sess_conns, ctx_empr, ctx_date


# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA24"
ROUTE_BASE = "/lina24"

LinaClie = get_table_model("linaclie")


class Lina24(linabase):
    """Módulo de Emisión de Recibos de Cobranza (LINA24)."""
    pass


# ==================== FUNCIONES AUXILIARES ====================

def _get_empr() -> str:
    return ctx_empr.get() or DEFAULT_EMPR_CODE


def _get_fecha_sesion() -> date:
    raw = ctx_date.get()
    if raw:
        try:
            return date.fromisoformat(raw)
        except ValueError:
            pass
    return date.today()


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina24_index(request: Request):
    Lina24.set_prog_code(PROG_CODE)
    user = Lina24.get_current_user(request)
    if not user:
        return RedirectResponse("/login")
    return Lina24.templates.TemplateResponse(
        "lina24/form.html",
        {"request": request, "max_lineas": MAX_LINEAS_RECIBO},
    )


@router.get("/clie/info")
async def lina24_clie_info(cliecodi: str = Query(default="")):
    """Devuelve nombre del cliente y próximo número de recibo."""
    empr = _get_empr()
    try:
        cod = int(cliecodi)
    except (ValueError, TypeError):
        return JSONResponse({"ok": False, "cliename": ""})
    rec = LinaClie.row_get({"emprcodi": empr, "cliecodi": cod})
    if not rec:
        return JSONResponse({"ok": False, "cliename": ""})
    conn = sess_conns.get_conn(readonly=True)
    try:
        cur = conn.cursor()
        cur.execute(
            "SELECT COALESCE(MAX(cohenume), 0) + 1 FROM linacohe"
            " WHERE emprcodi=%s AND codmcodi=%s",
            (empr, CODM_RECI),
        )
        cohenume = cur.fetchone()[0]
        cur.close()
    finally:
        sess_conns.release_conn(conn)
    return JSONResponse({
        "ok":       True,
        "cliename": str(rec.get("cliename") or "").strip(),
        "cohenume": cohenume,
    })


@router.post("/save")
async def lina24_save(request: Request):
    """Graba el recibo de cobranza y devuelve el número asignado."""
    Lina24.set_prog_code(PROG_CODE)
    user = Lina24.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    try:
        data = await request.json()
    except Exception:
        return JSONResponse({"ok": False, "error": "Datos inválidos"}, status_code=400)

    empr     = _get_empr()
    cohefech = _get_fecha_sesion()

    try:
        cliecodi = int(data.get("cliecodi", 0))
    except (ValueError, TypeError):
        cliecodi = 0
    if cliecodi <= 0:
        return JSONResponse(
            {"ok": False, "error": "Debe ingresar un código de cliente válido."},
            status_code=400,
        )

    coheobse = str(data.get("coheobse", "")).strip()[:LEN_TEXTO_LARGO]

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

    # Parsear renglones
    lineas = []
    reng   = 0
    for ln in data.get("lineas", []):
        desc = str(ln.get("desc", "")).strip()[:LEN_TEXTO_LARGO]
        try:
            unit = Decimal(str(ln.get("unit", 0) or 0))
        except Exception:
            unit = Decimal(0)
        if not desc and unit == 0:
            continue
        reng += 1
        lineas.append({"codereng": reng, "codedesc": desc, "codeunit": unit})

    cohetota = sum(ln["codeunit"] for ln in lineas)
    if not lineas or cohetota <= 0:
        return JSONResponse(
            {"ok": False, "error": "No se admiten recibos vacíos o con total cero."},
            status_code=400,
        )

    # Validar efec + banc == cohetota
    if abs((efec + banc) - cohetota) > Decimal("0.01"):
        return JSONResponse(
            {
                "ok":    False,
                "error": (
                    f"La suma de efectivo ({float(efec):,.2f}) y transferencia ({float(banc):,.2f})"
                    f" debe ser igual al total ({float(cohetota):,.2f})."
                ),
            },
            status_code=400,
        )

    tab_id    = Lina24.get_tab_id(request)
    conn      = Lina24.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn      = sess_conns.get_conn(readonly=False)
        owns_conn = True

    try:
        cohenume = crear_recibo(
            conn, empr, cohefech, cliecodi, coheobse,
            lineas, efec, banc, cohetota, CODM_RECI,
        )

        if user and tab_id and not owns_conn:
            sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=PROG_CODE)
        else:
            conn.commit()

        msg = f"{CODM_RECI} N° {cohenume:{FMT_NROCOMP}} grabado."
        return JSONResponse({"ok": True, "cohenume": cohenume, "message": msg})

    except ValueError as e:
        if owns_conn:
            try:
                conn.rollback()
            except Exception:
                pass
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
