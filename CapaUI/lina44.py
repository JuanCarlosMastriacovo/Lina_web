from datetime import date
import traceback

from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse

from CapaBRL.linabase import linabase
from CapaBRL.config import DEFAULT_EMPR_CODE, LEN_CONC_CAJA
from CapaDAL.dataconn import sess_conns, ctx_empr, ctx_date


# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA44"
ROUTE_BASE = "/lina44"


class Lina44(linabase):
    """Módulo de Entradas y Salidas Bancarias (LINA44)."""
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
async def lina44_index(request: Request):
    Lina44.set_prog_code(PROG_CODE)
    user = Lina44.get_current_user(request)
    if not user:
        return RedirectResponse("/login")
    return Lina44.templates.TemplateResponse(
        "lina44/form.html",
        {"request": request},
    )


@router.get("/prov/info")
async def lina44_prov_info(provcodi: str = Query(default="")):
    """Devuelve nombre del proveedor dado su código."""
    empr = _get_empr()
    try:
        cod = int(provcodi)
    except (ValueError, TypeError):
        return JSONResponse({"ok": False, "provname": ""})
    if cod <= 0:
        return JSONResponse({"ok": False, "provname": ""})
    conn = sess_conns.get_conn(readonly=True)
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT provname FROM linaprov WHERE emprcodi=%s AND provcodi=%s",
            (empr, cod),
        )
        row = cur.fetchone()
        cur.close()
    finally:
        sess_conns.release_conn(conn)
    if not row:
        return JSONResponse({"ok": False, "provname": ""})
    return JSONResponse({"ok": True, "provname": str(row["provname"] or "").strip()})


@router.post("/save")
async def lina44_save(request: Request):
    """
    Graba un movimiento bancario (entrada o salida).
    Payload: {provcodi, concepto, importe}
      importe > 0 → bancdebe (salida/egreso)
      importe < 0 → banchabe (entrada/ingreso), se guarda el valor absoluto
    """
    Lina44.set_prog_code(PROG_CODE)
    user = Lina44.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    try:
        data = await request.json()
    except Exception:
        return JSONResponse({"ok": False, "error": "Datos inválidos"}, status_code=400)

    empr     = _get_empr()
    bancfech = _get_fecha_sesion()

    try:
        provcodi = int(data.get("provcodi") or 0)
    except (ValueError, TypeError):
        provcodi = 0
    if provcodi < 0:
        provcodi = 0

    concepto = str(data.get("concepto") or "").strip()[:LEN_CONC_CAJA]
    if not concepto:
        return JSONResponse({"ok": False, "error": "Debe ingresar un concepto."}, status_code=400)

    try:
        importe = float(data.get("importe") or 0)
    except (ValueError, TypeError):
        importe = 0.0

    if abs(importe) < 0.005:
        return JSONResponse({"ok": False, "error": "El importe no puede ser cero."}, status_code=400)

    bancdebe = importe if importe > 0 else 0.0
    banchabe = abs(importe) if importe < 0 else 0.0

    conn = sess_conns.get_conn(readonly=False)
    try:
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO linabanc"
            "  (emprcodi, cliecodi, provcodi, bancfech, bancnumc, bancconc, bancdebe, banchabe)"
            " VALUES (%s, 0, %s, %s, 0, %s, %s, %s)",
            (empr, provcodi, bancfech, concepto, bancdebe, banchabe),
        )
        cur.close()
        conn.commit()
        tipo = "Salida" if importe > 0 else "Entrada"
        return JSONResponse({"ok": True, "message": f"{tipo} bancaria de $ {abs(importe):,.2f} grabada."})
    except Exception as e:
        try:
            conn.rollback()
        except Exception:
            pass
        traceback.print_exc()
        return JSONResponse({"ok": False, "error": str(e)}, status_code=500)
    finally:
        sess_conns.release_conn(conn)
