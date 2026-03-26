from datetime import date

from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse

from CapaBRL.linabase import linabase
from CapaBRL.pagos_brl import anular_pago
from CapaBRL.formatters import fmt_money
from CapaDAL.dataconn import sess_conns, ctx_empr
from CapaBRL.config import DEFAULT_EMPR_CODE
from CapaDAL.tablebase import get_table_model

LinaProv = get_table_model("linaprov")

# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA35"
ROUTE_BASE = "/lina35"


class Lina35(linabase):
    """Archivo de Pagos a Proveedores (LINA35)."""
    pass


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina35_index(request: Request):
    Lina35.set_prog_code(PROG_CODE)
    user = Lina35.get_current_user(request)
    if not user:
        return RedirectResponse("/login")
    return Lina35.templates.TemplateResponse(
        "lina35/form.html",
        {"request": request, "hoy": date.today().isoformat()},
    )


@router.get("/list")
async def lina35_list(
    request:  Request,
    desde:    str = Query(default=""),
    hasta:    str = Query(default=""),
    provcodi: int = Query(default=0),
):
    """Devuelve JSON con los pagos que cumplen el filtro."""
    Lina35.set_prog_code(PROG_CODE)
    user = Lina35.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    empr = ctx_empr.get() or DEFAULT_EMPR_CODE

    try:
        fecha_desde = date.fromisoformat(desde) if desde.strip() else None
    except ValueError:
        fecha_desde = None
    try:
        fecha_hasta = date.fromisoformat(hasta.strip()) if hasta.strip() else date.today()
    except ValueError:
        fecha_hasta = date.today()

    conn = sess_conns.get_conn(readonly=True)
    try:
        cur = conn.cursor(dictionary=True)

        params = [empr]
        where  = ["pahe.emprcodi = %s"]

        if fecha_desde:
            where.append("pahe.pahefech >= %s")
            params.append(fecha_desde)
        where.append("pahe.pahefech <= %s")
        params.append(fecha_hasta)

        if provcodi > 0:
            where.append("pahe.provcodi = %s")
            params.append(provcodi)

        sql = (
            "SELECT pahe.codmcodi, pahe.pahenume, pahe.pahefech,"
            "       pahe.provcodi, pahe.pahetota, pahe.paheefec, pahe.pahebanc, pahe.paheobse,"
            "       COALESCE(prov.provname, '') AS provname"
            "  FROM linapahe pahe"
            "  LEFT JOIN linaprov prov"
            "         ON prov.emprcodi = pahe.emprcodi"
            "        AND prov.provcodi = pahe.provcodi"
            " WHERE " + " AND ".join(where) +
            " ORDER BY pahe.pahenume ASC"
        )
        cur.execute(sql, params)
        rows_raw = cur.fetchall()
        cur.close()
    finally:
        sess_conns.release_conn(conn)

    rows = []
    for r in rows_raw:
        obse     = str(r.get("paheobse") or "").strip()
        anulado  = obse.startswith("*** ANULAD")
        provname = obse if anulado else str(r.get("provname") or "").strip()
        pahefech = r.get("pahefech")
        fecha_str = pahefech.strftime("%d/%m/%Y") if hasattr(pahefech, "strftime") else str(pahefech or "")
        rows.append({
            "codm":      str(r.get("codmcodi") or ""),
            "nro":       int(r.get("pahenume") or 0),
            "fecha":     fecha_str,
            "cta":       str(int(r.get("provcodi") or 0)).zfill(4),
            "proveedor": provname,
            "efec":      fmt_money(r.get("paheefec") or 0),
            "banc":      fmt_money(r.get("pahebanc") or 0),
            "importe":   fmt_money(r.get("pahetota") or 0),
            "anulado":   anulado,
        })

    return JSONResponse({"ok": True, "rows": rows})


@router.post("/anular")
async def lina35_anular(request: Request):
    """Anula un pago."""
    Lina35.set_prog_code(PROG_CODE)
    user = Lina35.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    try:
        body = await request.json()
        codm = str(body.get("codm") or "").strip().upper()
        nro  = int(body.get("nro") or 0)
    except Exception:
        return JSONResponse({"ok": False, "error": "Datos inválidos"}, status_code=400)

    if not codm or nro <= 0:
        return JSONResponse({"ok": False, "error": "Parámetros inválidos"}, status_code=400)

    result = anular_pago(codm, nro)
    return JSONResponse(result)


@router.get("/prov/info")
async def lina35_prov_info(provcodi: str = Query(default="")):
    empr = ctx_empr.get() or DEFAULT_EMPR_CODE
    try:
        cod = int(provcodi)
    except (ValueError, TypeError):
        return JSONResponse({"ok": False, "provname": ""})
    rec = LinaProv.row_get({"emprcodi": empr, "provcodi": cod})
    if not rec:
        return JSONResponse({"ok": False, "provname": ""})
    return JSONResponse({"ok": True, "provname": str(rec.get("provname") or "").strip()})
