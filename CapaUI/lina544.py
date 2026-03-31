from fastapi import APIRouter, Request, Query, Form
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from typing import Dict, Any

from CapaBRL.linabase import linabase
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import sess_conns


# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA544"
ROUTE_BASE = "/lina544"

LinaUser = get_table_model("linauser")
LinaEmpr = get_table_model("linaempr")


# ==================== CLASE PRINCIPAL ====================

class Lina544(linabase):
    """Copia de permisos entre usuarios (LINA544)."""

    @classmethod
    def get_permisos_por_usuario(cls, user: str) -> Dict[str, Any]:
        if cls.permisos_por_usuario_func:
            return cls.permisos_por_usuario_func(user)
        return {}


# ==================== FUNCIONES AUXILIARES ====================

def _get_empr_options(conn) -> list:
    rows = LinaEmpr.list_all(
        order_by="emprcodi",
        fields=["emprcodi", "emprname"],
        skip_company_filter=True,
        conn=conn,
    )
    return [
        {"code": str(r.get("emprcodi") or "").strip(),
         "name": str(r.get("emprname") or "").strip()}
        for r in rows
        if str(r.get("emprcodi") or "").strip()
    ]


def _get_all_users(conn) -> list:
    rows = LinaUser.list_all(
        order_by="emprcodi,usercodi",
        fields=["emprcodi", "usercodi", "username"],
        skip_company_filter=True,
        conn=conn,
    )
    return [
        {
            "empr": str(r.get("emprcodi") or "").strip(),
            "code": str(r.get("usercodi") or "").strip(),
            "name": str(r.get("username") or "").strip(),
        }
        for r in rows
        if str(r.get("emprcodi") or "").strip()
        and str(r.get("usercodi") or "").strip()
    ]


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina544_main(request: Request, _tab: str = Query(default="")):
    Lina544.set_prog_code(PROG_CODE)
    user = Lina544.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    perms = Lina544.get_permisos_por_usuario(user).get(Lina544.prog_code)
    if not perms or not perms.cons:
        from fastapi import HTTPException
        raise HTTPException(403, "Sin permisos de consulta")

    conn    = Lina544.get_task_conn(request, readonly=True)
    options = _get_empr_options(conn)

    return Lina544.templates.TemplateResponse(
        "lina544/main.html",
        {
            "request": request,
            "user":    user,
            "perms":   perms,
            "options": options,
            "tab_id":  _tab,
        },
    )


@router.get("/users", response_class=JSONResponse)
async def lina544_users(request: Request):
    """Devuelve todos los usuarios (todas las empresas) para el lookup F4."""
    conn  = Lina544.get_task_conn(request, readonly=True)
    users = _get_all_users(conn)
    return JSONResponse(users)


@router.post("/ejecutar", response_class=JSONResponse)
async def lina544_ejecutar(
    request:      Request,
    orig_empr:    str = Form(...),
    orig_user:    str = Form(...),
    dest_empr:    str = Form(...),
    dest_user:    str = Form(...),
    tab_id:       str = Form(default="", alias="_tab"),
):
    user = Lina544.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "Sesión expirada."}, status_code=401)

    perms = Lina544.get_permisos_por_usuario(user).get(PROG_CODE)
    if not perms or not perms.modi:
        return JSONResponse({"ok": False, "error": "Sin permisos de modificación."}, status_code=403)

    orig_empr = orig_empr.strip()
    orig_user = orig_user.strip()
    dest_empr = dest_empr.strip()
    dest_user = dest_user.strip()

    if not all([orig_empr, orig_user, dest_empr, dest_user]):
        return JSONResponse({"ok": False, "error": "Todos los campos son obligatorios."}, status_code=409)

    if orig_empr == dest_empr and orig_user == dest_user:
        return JSONResponse({"ok": False, "error": "El origen y el destino no pueden ser el mismo usuario."}, status_code=409)

    conn      = sess_conns.get_conn(readonly=False, user_override=user)
    owns_conn = True
    try:
        # Validar existencia origen
        if not LinaUser.row_get({"emprcodi": orig_empr, "usercodi": orig_user}, conn=conn):
            return JSONResponse(
                {"ok": False, "error": f"Usuario origen '{orig_user}' no existe en empresa '{orig_empr}'."},
                status_code=409,
            )

        # Validar existencia destino
        if not LinaUser.row_get({"emprcodi": dest_empr, "usercodi": dest_user}, conn=conn):
            return JSONResponse(
                {"ok": False, "error": f"Usuario destino '{dest_user}' no existe en empresa '{dest_empr}'."},
                status_code=409,
            )

        # Llamar al SP dentro de la misma transacción
        cur = conn.cursor()
        try:
            cur.execute(
                "CALL sp_copy_user_rights(%s, %s, %s, %s)",
                (orig_empr, orig_user, dest_empr, dest_user),
            )
        finally:
            cur.close()

        conn.commit()

        return JSONResponse({
            "ok":      True,
            "message": (
                f"Permisos copiados de '{orig_user}' ({orig_empr}) "
                f"a '{dest_user}' ({dest_empr}) correctamente."
            ),
        })

    except Exception as e:
        conn.rollback()
        return JSONResponse({"ok": False, "error": f"Error al copiar permisos: {e}"}, status_code=500)
    finally:
        sess_conns.release_conn(conn)
