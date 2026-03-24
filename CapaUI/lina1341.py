from fastapi import APIRouter, Request, Query
from fastapi.responses import Response, HTMLResponse, RedirectResponse
from weasyprint import HTML
from jinja2 import Environment, FileSystemLoader
from pathlib import Path
from datetime import date, datetime

from CapaBRL.linabase import linabase
from CapaBRL.cardex_brl import get_cardex
from CapaDAL.config import APP_CONFIG

# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA1341"
ROUTE_BASE = "/lina1341"

pdf_templates_dir = Path(__file__).parent.parent / "templates"
pdf_jinja_env     = Environment(loader=FileSystemLoader(str(pdf_templates_dir)))


# ==================== CLASE PRINCIPAL ====================

class Lina1341(linabase):
    """Módulo de Ficha de Cardex (LINA1341)."""
    pass


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

    empr_code, empr_name = Lina1341.get_empr_info()
    art_info, filas = get_cardex(articodi, fd, ff)

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
