from datetime import date

from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse

from CapaBRL.linabase import linabase
from CapaBRL.compras_brl import anular_factura
from CapaBRL.formatters import fmt_money
from CapaDAL.dataconn import sess_conns, ctx_empr
from CapaBRL.config import DEFAULT_EMPR_CODE
from CapaDAL.tablebase import get_table_model

LinaProv = get_table_model("linaprov")

# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA32"
ROUTE_BASE = "/lina32"


class Lina32(linabase):
    """Archivo de Facturas de Compra (LINA32)."""
    pass


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina32_index(request: Request):
    Lina32.set_prog_code(PROG_CODE)
    user = Lina32.get_current_user(request)
    if not user:
        return RedirectResponse("/login")
    return Lina32.templates.TemplateResponse(
        "lina32/form.html",
        {"request": request, "hoy": date.today().isoformat()},
    )


@router.get("/list")
async def lina32_list(
    request:  Request,
    desde:    str = Query(default=""),
    hasta:    str = Query(default=""),
    provcodi: int = Query(default=0),
):
    """Devuelve JSON con las facturas de compra que cumplen el filtro."""
    Lina32.set_prog_code(PROG_CODE)
    user = Lina32.get_current_user(request)
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
        where  = ["fche.emprcodi = %s"]

        if fecha_desde:
            where.append("fche.fchefech >= %s")
            params.append(fecha_desde)
        where.append("fche.fchefech <= %s")
        params.append(fecha_hasta)

        if provcodi > 0:
            where.append("fche.provcodi = %s")
            params.append(provcodi)

        sql = (
            "SELECT fche.codmcodi, fche.fchenume, fche.fchefech,"
            "       fche.provcodi, fche.fchetota, fche.fcheobse,"
            "       COALESCE(prov.provname, '') AS provname"
            "  FROM linafche fche"
            "  LEFT JOIN linaprov prov"
            "         ON prov.emprcodi = fche.emprcodi"
            "        AND prov.provcodi = fche.provcodi"
            " WHERE " + " AND ".join(where) +
            " ORDER BY fche.fchenume ASC"
        )
        cur.execute(sql, params)
        rows_raw = cur.fetchall()
        cur.close()
    finally:
        sess_conns.release_conn(conn)

    rows = []
    for r in rows_raw:
        obse     = str(r.get("fcheobse") or "").strip()
        anulado  = obse.startswith("*** ANULAD")
        provname = obse if anulado else str(r.get("provname") or "").strip()
        fchefech = r.get("fchefech")
        fecha_str = fchefech.strftime("%d/%m/%Y") if hasattr(fchefech, "strftime") else str(fchefech or "")
        rows.append({
            "codm":      str(r.get("codmcodi") or ""),
            "nro":       int(r.get("fchenume") or 0),
            "fecha":     fecha_str,
            "cta":       str(int(r.get("provcodi") or 0)).zfill(4),
            "proveedor": provname,
            "importe":   fmt_money(r.get("fchetota") or 0),
            "anulado":   anulado,
        })

    return JSONResponse({"ok": True, "rows": rows})


@router.post("/anular")
async def lina32_anular(request: Request):
    """Anula una factura de compra."""
    Lina32.set_prog_code(PROG_CODE)
    user = Lina32.get_current_user(request)
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

    result = anular_factura(codm, nro)
    return JSONResponse(result)


@router.get("/prov/info")
async def lina32_prov_info(provcodi: str = Query(default="")):
    empr = ctx_empr.get() or DEFAULT_EMPR_CODE
    try:
        cod = int(provcodi)
    except (ValueError, TypeError):
        return JSONResponse({"ok": False, "provname": ""})
    rec = LinaProv.row_get({"emprcodi": empr, "provcodi": cod})
    if not rec:
        return JSONResponse({"ok": False, "provname": ""})
    return JSONResponse({"ok": True, "provname": str(rec.get("provname") or "").strip()})
