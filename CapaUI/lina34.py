from datetime import date
from decimal import Decimal
import traceback

from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse

from CapaBRL.linabase import linabase
from CapaBRL.config import (
    DEFAULT_EMPR_CODE, CODM_PAGO, MAX_LINEAS_PAGO, FMT_NROCOMP, LEN_TEXTO_LARGO,
)
from CapaBRL.pagos_brl import crear_pago
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import sess_conns, ctx_empr, ctx_date


# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA34"
ROUTE_BASE = "/lina34"

LinaProv = get_table_model("linaprov")


class Lina34(linabase):
    """Módulo de Registro de Pagos a Proveedores (LINA34)."""
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
async def lina34_index(request: Request):
    Lina34.set_prog_code(PROG_CODE)
    user = Lina34.get_current_user(request)
    if not user:
        return RedirectResponse("/login")
    return Lina34.templates.TemplateResponse(
        "lina34/form.html",
        {"request": request, "max_lineas": MAX_LINEAS_PAGO},
    )


@router.get("/prov/info")
async def lina34_prov_info(provcodi: str = Query(default="")):
    """Devuelve nombre del proveedor y próximo número de pago."""
    empr = _get_empr()
    try:
        cod = int(provcodi)
    except (ValueError, TypeError):
        return JSONResponse({"ok": False, "provname": ""})
    rec = LinaProv.row_get({"emprcodi": empr, "provcodi": cod})
    if not rec:
        return JSONResponse({"ok": False, "provname": ""})
    conn = sess_conns.get_conn(readonly=True)
    try:
        cur = conn.cursor()
        cur.execute(
            "SELECT COALESCE(MAX(pahenume), 0) + 1 FROM linapahe"
            " WHERE emprcodi=%s AND codmcodi=%s",
            (empr, CODM_PAGO),
        )
        pahenume = cur.fetchone()[0]
        cur.close()
    finally:
        sess_conns.release_conn(conn)
    return JSONResponse({
        "ok":       True,
        "provname": str(rec.get("provname") or "").strip(),
        "pahenume": pahenume,
    })


@router.post("/save")
async def lina34_save(request: Request):
    """Graba el pago a proveedor y devuelve el número asignado."""
    Lina34.set_prog_code(PROG_CODE)
    user = Lina34.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    try:
        data = await request.json()
    except Exception:
        return JSONResponse({"ok": False, "error": "Datos inválidos"}, status_code=400)

    empr     = _get_empr()
    pahefech = _get_fecha_sesion()

    try:
        provcodi = int(data.get("provcodi", 0))
    except (ValueError, TypeError):
        provcodi = 0
    if provcodi <= 0:
        return JSONResponse(
            {"ok": False, "error": "Debe ingresar un código de proveedor válido."},
            status_code=400,
        )

    paheobse = str(data.get("paheobse", "")).strip()[:LEN_TEXTO_LARGO]

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
        lineas.append({"padereng": reng, "padedesc": desc, "padeunit": unit})

    pahetota = sum(ln["padeunit"] for ln in lineas)
    if not lineas or pahetota <= 0:
        return JSONResponse(
            {"ok": False, "error": "No se admiten pagos vacíos o con total cero."},
            status_code=400,
        )

    # Validar efec + banc == pahetota
    if abs((efec + banc) - pahetota) > Decimal("0.01"):
        return JSONResponse(
            {
                "ok":    False,
                "error": (
                    f"La suma de efectivo ({float(efec):,.2f}) y transferencia ({float(banc):,.2f})"
                    f" debe ser igual al total ({float(pahetota):,.2f})."
                ),
            },
            status_code=400,
        )

    tab_id    = Lina34.get_tab_id(request)
    conn      = Lina34.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn      = sess_conns.get_conn(readonly=False)
        owns_conn = True

    try:
        pahenume = crear_pago(
            conn, empr, pahefech, provcodi, paheobse,
            lineas, efec, banc, pahetota, CODM_PAGO,
        )

        if user and tab_id and not owns_conn:
            sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=PROG_CODE)
        else:
            conn.commit()

        msg = f"{CODM_PAGO} N° {pahenume:{FMT_NROCOMP}} grabado."
        return JSONResponse({"ok": True, "pahenume": pahenume, "message": msg})

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
