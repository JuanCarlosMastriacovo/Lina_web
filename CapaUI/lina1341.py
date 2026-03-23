from fastapi import APIRouter, Request, Query
from fastapi.responses import Response, HTMLResponse, RedirectResponse
from weasyprint import HTML
from jinja2 import Environment, FileSystemLoader
from pathlib import Path
from datetime import date, datetime, timedelta

from CapaBRL.linabase import linabase
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import ctx_empr, sess_conns
from CapaDAL.config import APP_CONFIG

# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA1341"
ROUTE_BASE = "/lina1341"

LinaArti        = get_table_model("linaarti")
LinaEmpr        = get_table_model("linaempr")
EMPR_CODE_FIELD = LinaEmpr.require_column("emprcodi")
EMPR_NAME_FIELD = LinaEmpr.require_column("emprname")

pdf_templates_dir = Path(__file__).parent.parent / "templates"
pdf_jinja_env     = Environment(loader=FileSystemLoader(str(pdf_templates_dir)))


# ==================== CLASE PRINCIPAL ====================

class Lina1341(linabase):
    """Módulo de Ficha de Cardex (LINA1341)."""
    pass


# ==================== FUNCIONES AUXILIARES ====================

def _get_empr_info():
    empr_code = ctx_empr.get() or "01"
    empr_rec  = LinaEmpr.row_get({EMPR_CODE_FIELD: empr_code})
    empr_name = str(empr_rec.get(EMPR_NAME_FIELD) or "").strip() if empr_rec else ""
    return empr_code, empr_name


def _get_cardex(articodi: str, fecha_desde, fecha_hasta: date):
    """
    Retorna (artidesc, filas) donde cada fila es:
      [fecha_str, concepto, salida_str, entrada_str, saldo_str]

    La primera fila es siempre la apertura (EXISTENCIA ANTERIOR o SALDO ANTERIOR).
    Movimientos:
      - linafcde → Entrada (suma al saldo), concepto = codmcodi + fchenume
      - linafvde → Salida  (resta al saldo), concepto = codmcodi + fvhenume
    Orden cronológico: fecha ASC, numero ASC.
    """
    empr = ctx_empr.get() or "01"

    # Datos del artículo
    art      = LinaArti.row_get({"articodi": articodi})
    if not art:
        return None, []
    artidesc = str(art.get("artidesc") or "")
    artiexan = int(art.get("artiexan") or 0)
    artiexfe = art.get("artiexfe")   # date o None
    artipmpe = int(art.get("artipmpe") or 0)
    artiprec = float(art.get("artiprec") or 0)

    conn = sess_conns.get_conn(readonly=True)
    try:
        cur = conn.cursor()
        try:
            # ── Saldo de apertura ───────────────────────────────────────────
            if fecha_desde:
                # Calcular saldo acumulado ANTES de fecha_desde
                cur.execute(
                    """SELECT
                           COALESCE((SELECT SUM(fcdecant) FROM linafcde
                                      WHERE emprcodi = %s AND articodi = %s
                                        AND fchefech < %s), 0)
                         - COALESCE((SELECT SUM(fvdecant) FROM linafvde
                                      WHERE emprcodi = %s AND articodi = %s
                                        AND fvhefech < %s), 0)""",
                    (empr, articodi, fecha_desde, empr, articodi, fecha_desde),
                )
                delta = int(cur.fetchone()[0] or 0)
                saldo_ini    = artiexan + delta
                apertura_fec = fecha_desde - timedelta(days=1)
                apertura_lbl = f"SALDO AL {apertura_fec.strftime('%d/%m/%Y')}"
            else:
                saldo_ini    = artiexan
                apertura_fec = artiexfe if isinstance(artiexfe, date) else None
                apertura_lbl = "EXISTENCIA ANTERIOR"

            # ── Movimientos de compras (Entradas) ──────────────────────────
            params_e = [empr, articodi]
            cond_e   = ""
            if fecha_desde:
                cond_e += " AND fchefech >= %s"; params_e.append(fecha_desde)
            cond_e += " AND fchefech <= %s"; params_e.append(fecha_hasta)

            cur.execute(
                f"SELECT fchefech, codmcodi, fchenume, fcdecant "
                f"  FROM linafcde "
                f" WHERE emprcodi = %s AND articodi = %s{cond_e} "
                f" ORDER BY fchefech, fchenume",
                params_e,
            )
            entradas = [(*row, "E") for row in cur.fetchall()]

            # ── Movimientos de ventas (Salidas) ────────────────────────────
            params_s = [empr, articodi]
            cond_s   = ""
            if fecha_desde:
                cond_s += " AND fvhefech >= %s"; params_s.append(fecha_desde)
            cond_s += " AND fvhefech <= %s"; params_s.append(fecha_hasta)

            cur.execute(
                f"SELECT fvhefech, codmcodi, fvhenume, fvdecant "
                f"  FROM linafvde "
                f" WHERE emprcodi = %s AND articodi = %s{cond_s} "
                f" ORDER BY fvhefech, fvhenume",
                params_s,
            )
            salidas = [(*row, "S") for row in cur.fetchall()]

        finally:
            cur.close()
    finally:
        sess_conns.release_conn(conn)

    # ── Combinar y ordenar ─────────────────────────────────────────────────
    movs = sorted(entradas + salidas, key=lambda r: (r[0], r[2]))

    # ── Construir filas del cardex ─────────────────────────────────────────
    def fmt_fec(d):
        return d.strftime("%d/%m/%Y") if d else "---"

    def fmt_qty(n):
        return str(n) if n else ""

    saldo  = saldo_ini
    filas  = [[fmt_fec(apertura_fec), apertura_lbl, "", "", str(saldo)]]

    for fec, codm, nro, cant, tipo in movs:
        concepto = f"{str(codm).strip()} {int(nro):08d}"
        cant     = int(cant or 0)
        if tipo == "E":
            saldo  += cant
            entrada = str(cant)
            salida  = ""
        else:
            saldo  -= cant
            salida  = str(cant)
            entrada = ""
        filas.append([fmt_fec(fec), concepto, salida, entrada, str(saldo)])

    art_info = {
        "articodi": articodi,
        "artidesc": artidesc,
        "artipmpe": artipmpe,
        "artiprec": artiprec,
    }
    return art_info, filas


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina1341_index(request: Request):
    Lina1341.set_prog_code(PROG_CODE)
    user = Lina1341.get_current_user(request)
    if not user:
        return RedirectResponse("/login")
    return Lina1341.templates.TemplateResponse(
        "lina1341/seleccion.html",
        {"request": request, "error": None, "hoy": date.today().isoformat()},
    )


@router.get("/pdf")
async def lina1341_pdf(
    request: Request,
    articodi:    str = Query(default=""),
    fecha_desde: str = Query(default=""),
    fecha_hasta: str = Query(default=""),
):
    Lina1341.set_prog_code(PROG_CODE)
    user = Lina1341.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    articodi = articodi.strip().upper()
    if not articodi:
        return Lina1341.templates.TemplateResponse(
            "lina1341/seleccion.html",
            {"request": request, "error": "Debe ingresar un código de artículo.", "hoy": date.today().isoformat()},
        )

    hoy = date.today()
    fd  = None
    try:
        if fecha_desde:
            fd = date.fromisoformat(fecha_desde)
    except ValueError:
        pass
    try:
        ff = date.fromisoformat(fecha_hasta) if fecha_hasta else hoy
    except ValueError:
        ff = hoy

    if fd and fd > ff:
        return Lina1341.templates.TemplateResponse(
            "lina1341/seleccion.html",
            {"request": request, "error": "La fecha inicial no puede ser mayor que la final.", "hoy": hoy.isoformat()},
        )

    empr_code, empr_name = _get_empr_info()
    art_info, filas = _get_cardex(articodi, fd, ff)

    if art_info is None:
        return Lina1341.templates.TemplateResponse(
            "lina1341/seleccion.html",
            {"request": request, "error": f"Artículo '{articodi}' no encontrado.", "hoy": hoy.isoformat()},
        )

    template = pdf_jinja_env.get_template("lina1341/main.html")
    html_str = template.render(
        app_name        = APP_CONFIG.get("app_name", ""),
        app_description = APP_CONFIG.get("app_description", ""),
        prog_code   = PROG_CODE,
        empr_code   = empr_code,
        empr_name   = empr_name,
        usuario     = user,
        fecha       = hoy.strftime("%d/%m/%Y"),
        hora        = datetime.now().strftime("%H:%M"),
        art_info    = art_info,
        fecha_desde = fd.strftime("%d/%m/%Y") if fd else "inicio",
        fecha_hasta = ff.strftime("%d/%m/%Y"),
        filas       = filas,
    )

    pdf = HTML(string=html_str).write_pdf()
    return Response(
        content    = pdf,
        media_type = "application/pdf",
        headers    = {"Content-Disposition": f"inline; filename=cardex_{articodi}.pdf"},
    )
