from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse

from CapaBRL.linabase import linabase
from CapaDAL.dataconn import ctx_empr
from CapaDAL.tablebase import get_table_model

# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA52"
ROUTE_BASE = "/lina52"

LinaEmpr        = get_table_model("linaempr")
EMPR_CODE_FIELD = LinaEmpr.require_column("emprcodi")
EMPR_NAME_FIELD = LinaEmpr.require_column("emprname")


# ==================== CLASE PRINCIPAL ====================

class Lina52(linabase):
    """Cambio de Empresa Activa (LINA52)."""
    pass


# ==================== FUNCIONES AUXILIARES ====================

def _get_empr_options() -> list:
    try:
        rows = LinaEmpr.list_all(order_by=EMPR_CODE_FIELD, skip_company_filter=True)
        options = []
        for rec in rows:
            code = str(rec.get(EMPR_CODE_FIELD) or "").strip()
            name = str(rec.get(EMPR_NAME_FIELD) or "").strip()
            if code:
                options.append({"code": code, "name": name})
        return options
    except Exception:
        return []


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina52_index(
    request: Request,
    _tab: str = Query(default=""),
):
    Lina52.set_prog_code(PROG_CODE)
    user = Lina52.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    return Lina52.templates.TemplateResponse(
        "lina52/main.html",
        {
            "request":      request,
            "current_code": ctx_empr.get() or "",
            "options":      _get_empr_options(),
            "tab_id":       _tab,
        },
    )
