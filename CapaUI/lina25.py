from datetime import date

from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse

from CapaBRL.linabase import linabase
from CapaBRL.recibos_brl import anular_recibo
from CapaBRL.formatters import fmt_money
from CapaDAL.dataconn import sess_conns, ctx_empr
from CapaBRL.config import DEFAULT_EMPR_CODE
from CapaDAL.tablebase import get_table_model

LinaClie = get_table_model("linaclie")

# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA25"
ROUTE_BASE = "/lina25"


class Lina25(linabase):
    """Archivo de Recibos de Cobranza (LINA25)."""
    pass


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina25_index(request: Request):
    Lina25.set_prog_code(PROG_CODE)
    user = Lina25.get_current_user(request)
    if not user:
        return RedirectResponse("/login")
    return Lina25.templates.TemplateResponse(
        "lina25/form.html",
        {"request": request, "hoy": date.today().isoformat()},
    )


@router.get("/list")
async def lina25_list(
    request: Request,
    desde:    str = Query(default=""),
    hasta:    str = Query(default=""),
    cliecodi: int = Query(default=0),
):
    """Devuelve JSON con los recibos que cumplen el filtro."""
    Lina25.set_prog_code(PROG_CODE)
    user = Lina25.get_current_user(request)
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
        where  = ["cohe.emprcodi = %s"]

        if fecha_desde:
            where.append("cohe.cohefech >= %s")
            params.append(fecha_desde)
        where.append("cohe.cohefech <= %s")
        params.append(fecha_hasta)

        if cliecodi > 0:
            where.append("cohe.cliecodi = %s")
            params.append(cliecodi)

        sql = (
            "SELECT cohe.codmcodi, cohe.cohenume, cohe.cohefech,"
            "       cohe.cliecodi, cohe.cohetota, cohe.coheefec, cohe.cohebanc, cohe.coheobse,"
            "       COALESCE(clie.cliename, '') AS cliename"
            "  FROM linacohe cohe"
            "  LEFT JOIN linaclie clie"
            "         ON clie.emprcodi = cohe.emprcodi"
            "        AND clie.cliecodi = cohe.cliecodi"
            " WHERE " + " AND ".join(where) +
            " ORDER BY cohe.cohenume ASC"
        )
        cur.execute(sql, params)
        rows_raw = cur.fetchall()
        cur.close()
    finally:
        sess_conns.release_conn(conn)

    rows = []
    for r in rows_raw:
        obse     = str(r.get("coheobse") or "").strip()
        anulado  = obse.startswith("*** ANULAD")
        cliename = obse if anulado else str(r.get("cliename") or "").strip()
        cohefech = r.get("cohefech")
        fecha_str = cohefech.strftime("%d/%m/%Y") if hasattr(cohefech, "strftime") else str(cohefech or "")
        rows.append({
            "codm":    str(r.get("codmcodi") or ""),
            "nro":     int(r.get("cohenume") or 0),
            "fecha":   fecha_str,
            "cta":     str(int(r.get("cliecodi") or 0)).zfill(4),
            "cliente": cliename,
            "efec":    fmt_money(r.get("coheefec") or 0),
            "banc":    fmt_money(r.get("cohebanc") or 0),
            "importe": fmt_money(r.get("cohetota") or 0),
            "anulado": anulado,
        })

    return JSONResponse({"ok": True, "rows": rows})


@router.post("/anular")
async def lina25_anular(request: Request):
    """Anula un recibo: elimina renglones, blanquea cabecera, revierte ctcl/caja/banco."""
    Lina25.set_prog_code(PROG_CODE)
    user = Lina25.get_current_user(request)
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

    result = anular_recibo(codm, nro)
    return JSONResponse(result)


@router.get("/clie/info")
async def lina25_clie_info(cliecodi: str = Query(default="")):
    empr = ctx_empr.get() or DEFAULT_EMPR_CODE
    try:
        cod = int(cliecodi)
    except (ValueError, TypeError):
        return JSONResponse({"ok": False, "cliename": ""})
    rec = LinaClie.row_get({"emprcodi": empr, "cliecodi": cod})
    if not rec:
        return JSONResponse({"ok": False, "cliename": ""})
    return JSONResponse({"ok": True, "cliename": str(rec.get("cliename") or "").strip()})
