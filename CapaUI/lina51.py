from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse
from datetime import date
from typing import Dict, Any

from CapaBRL.linabase import linabase
from CapaDAL.dataconn import ctx_date

# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA51"
ROUTE_BASE = "/lina51"


# ==================== CLASE PRINCIPAL ====================

class Lina51(linabase):
    """Cambio de Fecha de Sesión (LINA51)."""

    @classmethod
    def get_permisos_por_usuario(cls, user: str) -> Dict[str, Any]:
        if cls.permisos_por_usuario_func:
            return cls.permisos_por_usuario_func(user)
        return {}


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina51_index(
    request: Request,
    _tab: str = Query(default=""),
):
    Lina51.set_prog_code(PROG_CODE)
    user = Lina51.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    perms_dict = Lina51.get_permisos_por_usuario(user)
    perms = perms_dict.get(PROG_CODE)

    return Lina51.templates.TemplateResponse(
        "lina51/main.html",
        {
            "request":          request,
            "session_date_iso": ctx_date.get() or date.today().isoformat(),
            "perms":            perms,
            "tab_id":           _tab,
        },
    )
