"""
Rutas de impresión de comprobantes (remitos y recibos, ventas y compras).

Parámetros de query:
    clpr : "C" (ventas/cobros) | "P" (compras/pagos)
    codm : código de movimiento (ej. "REMI", "RECI")
    nume : número de comprobante (int)

Salidas:
    GET /cpbte/pdf  → PDF inline
    GET /cpbte/txt  → TXT inline (formato fijo, 80 col)
"""
from datetime import date, datetime

from fastapi import APIRouter, Query
from fastapi.requests import Request
from fastapi.responses import Response, HTMLResponse, RedirectResponse
from jinja2 import Environment, FileSystemLoader
from pathlib import Path
from weasyprint import HTML

from CapaBRL.cpbte_brl import get_cpbte, generar_cpbte_txt
from CapaBRL.formatters import fmt_money
from CapaBRL.config import FMT_NROCOMP
from CapaBRL.linabase import linabase
from CapaDAL.config import APP_CONFIG

router = APIRouter()

_templates_dir = Path(__file__).parent.parent / "templates"
_jinja_env     = Environment(loader=FileSystemLoader(str(_templates_dir)))

# Usado para auth; no es un módulo de menú, no requiere PROG_CODE en linabase
_PROG = "LINACPBTE"


# ── helpers ───────────────────────────────────────────────────────────────────

def _current_user(request: Request):
    from CapaDAL.dataconn import ctx_user
    return ctx_user.get()


def _build_filas_remi(renglones):
    return [
        {
            "articodi": r.articodi,
            "desc":     r.desc,
            "cant":     r.cant,
            "unit":     fmt_money(r.unit),
            "subtotal": fmt_money(r.subtotal),
        }
        for r in renglones
    ]


def _build_filas_reci(renglones):
    return [
        {
            "desc": r.desc,
            "unit": fmt_money(r.unit),
        }
        for r in renglones
    ]


# ── PDF ───────────────────────────────────────────────────────────────────────

@router.get("/pdf")
async def cpbte_pdf(
    request: Request,
    clpr: str = Query(..., description="C=ventas, P=compras"),
    codm: str = Query(..., description="Código de movimiento (REMI, RECI, …)"),
    nume: int = Query(..., description="Número de comprobante"),
):
    """Genera el PDF de un comprobante."""
    user = _current_user(request)
    if not user:
        return RedirectResponse("/login")

    datos = get_cpbte(clpr, codm, nume)
    if datos is None:
        return HTMLResponse(
            f"<p style='font-family:Arial;color:red;padding:20px;'>"
            f"Comprobante no encontrado: {codm} {nume:{FMT_NROCOMP}} ({clpr})"
            f"</p>",
            status_code=404,
        )

    empr_code, empr_name = linabase.get_empr_info()
    app_name = APP_CONFIG.get("app_name", "")
    hoy  = date.today().strftime("%d/%m/%Y")
    hora = datetime.now().strftime("%H:%M")

    filas    = _build_filas_remi(datos.renglones_remi) if datos.es_remi else _build_filas_reci(datos.renglones_reci)
    total_cant = sum(r.cant for r in datos.renglones_remi) if datos.es_remi else None

    reci_num_fmt = (
        f"{datos.reci_vinculado_num:{FMT_NROCOMP}}"
        if datos.reci_vinculado_num else None
    )

    template = _jinja_env.get_template("linacpbte/cpbte.html")
    html_str = template.render(
        app_name   = app_name,
        empr_code  = empr_code,
        empr_name  = empr_name,
        usuario    = user,
        fecha      = hoy,
        hora       = hora,
        titulo1    = datos.titulo1,
        titulo2    = datos.titulo2,
        contacto_cod = datos.contacto_cod,
        contacto_nom = datos.contacto_nom,
        es_remi    = datos.es_remi,
        filas      = filas,
        total      = fmt_money(datos.total),
        total_cant = total_cant,
        obse       = datos.obse,
        saldo      = fmt_money(datos.saldo) if datos.saldo is not None else None,
        reci_vinculado_num   = reci_num_fmt,
        reci_vinculado_total = fmt_money(datos.reci_vinculado_total) if datos.reci_vinculado_total else None,
    )

    pdf      = HTML(string=html_str).write_pdf()
    filename = f"{codm.lower()}_{nume:{FMT_NROCOMP}}.pdf"
    return Response(
        content    = pdf,
        media_type = "application/pdf",
        headers    = {"Content-Disposition": f"inline; filename={filename}"},
    )


# ── TXT ───────────────────────────────────────────────────────────────────────

@router.get("/txt")
async def cpbte_txt(
    request: Request,
    clpr: str = Query(..., description="C=ventas, P=compras"),
    codm: str = Query(..., description="Código de movimiento (REMI, RECI, …)"),
    nume: int = Query(..., description="Número de comprobante"),
):
    """Genera el TXT de un comprobante (formato fijo 80 col, BR-cpbte)."""
    user = _current_user(request)
    if not user:
        return RedirectResponse("/login")

    datos = get_cpbte(clpr, codm, nume)
    if datos is None:
        return Response(
            content    = f"Comprobante no encontrado: {codm} {nume:{FMT_NROCOMP}} ({clpr})\n".encode("utf-8"),
            media_type = "text/plain; charset=utf-8",
            status_code = 404,
        )

    empr_code, empr_name = linabase.get_empr_info()
    app_name = APP_CONFIG.get("app_name", "")

    txt      = generar_cpbte_txt(
        datos     = datos,
        app_name  = app_name,
        empr_code = empr_code,
        empr_name = empr_name,
        usuario   = user,
        fecha     = date.today().strftime("%d/%m/%Y"),
        hora      = datetime.now().strftime("%H:%M"),
    )

    filename = f"{codm.lower()}_{nume:{FMT_NROCOMP}}.txt"
    return Response(
        content    = txt.encode("utf-8"),
        media_type = "text/plain; charset=utf-8",
        headers    = {"Content-Disposition": f"inline; filename={filename}"},
    )
