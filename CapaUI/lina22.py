from datetime import date, datetime

from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse

from CapaBRL.linabase import linabase
from CapaBRL.remitos_brl import anular_remito
from CapaBRL.formatters import fmt_money
from CapaDAL.dataconn import sess_conns, ctx_empr
from CapaBRL.config import DEFAULT_EMPR_CODE
from CapaDAL.tablebase import get_table_model

LinaClie = get_table_model("linaclie")

# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA22"
ROUTE_BASE = "/lina22"


class Lina22(linabase):
    """Archivo de Remitos de Venta (LINA22)."""
    pass


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina22_index(request: Request):
    Lina22.set_prog_code(PROG_CODE)
    user = Lina22.get_current_user(request)
    if not user:
        return RedirectResponse("/login")
    return Lina22.templates.TemplateResponse(
        "lina22/form.html",
        {"request": request, "hoy": date.today().isoformat()},
    )


@router.get("/list")
async def lina22_list(
    request: Request,
    desde:    str = Query(default=""),
    hasta:    str = Query(default=""),
    cliecodi: int = Query(default=0),
):
    """Devuelve JSON con los remitos que cumplen el filtro."""
    Lina22.set_prog_code(PROG_CODE)
    user = Lina22.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    empr = ctx_empr.get() or DEFAULT_EMPR_CODE

    # Parsear fechas
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
        where  = ["fvhe.emprcodi = %s"]

        if fecha_desde:
            where.append("fvhe.fvhefech >= %s")
            params.append(fecha_desde)
        where.append("fvhe.fvhefech <= %s")
        params.append(fecha_hasta)

        if cliecodi > 0:
            where.append("fvhe.cliecodi = %s")
            params.append(cliecodi)

        sql = (
            "SELECT fvhe.codmcodi, fvhe.fvhenume, fvhe.fvhefech,"
            "       fvhe.cliecodi, fvhe.fvhetota, fvhe.fvheobse,"
            "       COALESCE(clie.cliename, '') AS cliename"
            "  FROM linafvhe fvhe"
            "  LEFT JOIN linaclie clie"
            "         ON clie.emprcodi = fvhe.emprcodi"
            "        AND clie.cliecodi = fvhe.cliecodi"
            " WHERE " + " AND ".join(where) +
            " ORDER BY fvhe.fvhenume ASC"
        )
        cur.execute(sql, params)
        rows_raw = cur.fetchall()
        cur.close()
    finally:
        sess_conns.release_conn(conn)

    rows = []
    for r in rows_raw:
        obse     = str(r.get("fvheobse") or "").strip()
        anulado  = obse.startswith("*** ANULAD")
        # Para anulados: mostrar obse como nombre de cliente (igual que FoxPro GetClName)
        cliename = obse if anulado else str(r.get("cliename") or "").strip()
        fvhefech = r.get("fvhefech")
        fecha_str = fvhefech.strftime("%d/%m/%Y") if hasattr(fvhefech, "strftime") else str(fvhefech or "")
        rows.append({
            "codm":    str(r.get("codmcodi") or ""),
            "nro":     int(r.get("fvhenume") or 0),
            "fecha":   fecha_str,
            "cta":     str(int(r.get("cliecodi") or 0)).zfill(4),
            "cliente": cliename,
            "importe": fmt_money(r.get("fvhetota") or 0),
            "anulado": anulado,
        })

    return JSONResponse({"ok": True, "rows": rows})


@router.post("/anular")
async def lina22_anular(request: Request):
    """Anula un remito: elimina renglones, blanquea cabecera, quita movimiento ctcl."""
    Lina22.set_prog_code(PROG_CODE)
    user = Lina22.get_current_user(request)
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

    result = anular_remito(codm, nro)
    return JSONResponse(result)


@router.get("/clie/info")
async def lina22_clie_info(cliecodi: str = Query(default="")):
    empr = ctx_empr.get() or DEFAULT_EMPR_CODE
    try:
        cod = int(cliecodi)
    except (ValueError, TypeError):
        return JSONResponse({"ok": False, "cliename": ""})
    rec = LinaClie.row_get({"emprcodi": empr, "cliecodi": cod})
    if not rec:
        return JSONResponse({"ok": False, "cliename": ""})
    return JSONResponse({"ok": True, "cliename": str(rec.get("cliename") or "").strip()})
