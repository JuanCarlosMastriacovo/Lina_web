from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from typing import Dict, Any

from CapaBRL.linabase import linabase
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import sess_conns


# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA542"
ROUTE_BASE = "/lina542"

LinaUser = get_table_model("linauser")


# ==================== CLASE PRINCIPAL ====================

class Lina542(linabase):
    """Edición de permisos por usuario (LINA542)."""

    @classmethod
    def get_permisos_por_usuario(cls, user: str) -> Dict[str, Any]:
        if cls.permisos_por_usuario_func:
            return cls.permisos_por_usuario_func(user)
        return {}


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina542_main(request: Request, _tab: str = Query(default="")):
    Lina542.set_prog_code(PROG_CODE)
    user = Lina542.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    from fastapi import HTTPException
    perms = Lina542.get_permisos_por_usuario(user).get(PROG_CODE)
    if not perms or not perms.cons:
        raise HTTPException(403, "Sin permisos de consulta")

    return Lina542.templates.TemplateResponse(
        "lina542/main.html",
        {
            "request": request,
            "user":    user,
            "perms":   perms,
            "tab_id":  _tab,
        },
    )


@router.get("/users", response_class=JSONResponse)
async def lina542_users(request: Request):
    """Devuelve usuarios de la empresa activa para lookup F4."""
    user = Lina542.get_current_user(request)
    if not user:
        return JSONResponse([], status_code=401)
    empr  = Lina542.get_curr_emprcodi()
    rows  = LinaUser.list_all(
        order_by="usercodi",
        fields=["usercodi", "username"],
        conn=None,
    )
    return JSONResponse([
        {"code": str(r.get("usercodi") or "").strip(),
         "name": str(r.get("username") or "").strip()}
        for r in rows
        if str(r.get("usercodi") or "").strip()
    ])


@router.get("/permisos", response_class=JSONResponse)
async def lina542_permisos(request: Request, usercodi: str = Query(...)):
    """Valida usuario y devuelve sus permisos para la empresa activa."""
    Lina542.set_prog_code(PROG_CODE)
    user = Lina542.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "Sesión expirada."}, status_code=401)

    empr     = Lina542.get_curr_emprcodi()
    usercodi = usercodi.strip().upper()

    conn      = Lina542.get_task_conn(request, readonly=True)
    owns_conn = False
    if not conn:
        conn      = sess_conns.get_conn(readonly=True, user_override=user)
        owns_conn = True
    try:
        user_row = LinaUser.row_get({"emprcodi": empr, "usercodi": usercodi}, conn=conn)
        if not user_row:
            return JSONResponse({"ok": False, "error": f"Usuario '{usercodi}' no encontrado."})

        username = str(user_row.get("username") or "").strip()

        cur = conn.cursor(dictionary=True)
        try:
            cur.execute(
                """
                SELECT lp.progcodi,
                       lp.progdesc,
                       COALESCE(ls.safealta, 0) AS safealta,
                       COALESCE(ls.safebaja, 0) AS safebaja,
                       COALESCE(ls.safemodi, 0) AS safemodi,
                       COALESCE(ls.safecons, 0) AS safecons
                FROM   linaprog lp
                LEFT JOIN linasafe ls
                       ON  ls.progcodi = lp.progcodi
                       AND ls.emprcodi = %s
                       AND ls.usercodi = %s
                WHERE  TRIM(IFNULL(lp.progcall, '')) <> ''
                ORDER  BY lp.progcodi
                """,
                (empr, usercodi),
            )
            rows = cur.fetchall() or []
        finally:
            cur.close()
    finally:
        if owns_conn:
            sess_conns.release_conn(conn)

    permisos = [
        {
            "progcodi": str(r["progcodi"]).strip(),
            "progdesc": str(r.get("progdesc") or "").strip(),
            "safealta": bool(r["safealta"]),
            "safebaja": bool(r["safebaja"]),
            "safemodi": bool(r["safemodi"]),
            "safecons": bool(r["safecons"]),
        }
        for r in rows
    ]

    return JSONResponse({"ok": True, "username": username, "permisos": permisos})


@router.post("/guardar", response_class=JSONResponse)
async def lina542_guardar(request: Request):
    """Guarda (upsert) todos los permisos del usuario para la empresa activa."""
    user = Lina542.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "Sesión expirada."}, status_code=401)

    perms = Lina542.get_permisos_por_usuario(user).get(PROG_CODE)
    if not perms or not perms.modi:
        return JSONResponse({"ok": False, "error": "Sin permisos de modificación."}, status_code=403)

    payload  = await request.json()
    usercodi = str(payload.get("usercodi") or "").strip().upper()
    rows     = payload.get("rows", [])

    if not usercodi:
        return JSONResponse({"ok": False, "error": "Usuario requerido."}, status_code=400)

    empr = Lina542.get_curr_emprcodi()
    conn = sess_conns.get_conn(readonly=False, user_override=user)
    try:
        user_row = LinaUser.row_get({"emprcodi": empr, "usercodi": usercodi}, conn=conn)
        if not user_row:
            return JSONResponse(
                {"ok": False, "error": f"Usuario '{usercodi}' no encontrado."},
                status_code=409,
            )

        cur = conn.cursor()
        try:
            for r in rows:
                progcodi = str(r.get("progcodi") or "").strip()
                if not progcodi:
                    continue
                alta = "X" if r.get("safealta") else ""
                baja = "X" if r.get("safebaja") else ""
                modi = "X" if r.get("safemodi") else ""
                cons = "X" if r.get("safecons") else ""
                cur.execute(
                    """
                    INSERT INTO linasafe
                        (emprcodi, usercodi, progcodi, safealta, safebaja, safemodi, safecons)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    ON DUPLICATE KEY UPDATE
                        safealta = %s, safebaja = %s, safemodi = %s, safecons = %s
                    """,
                    (empr, usercodi, progcodi, alta, baja, modi, cons,
                     alta, baja, modi, cons),
                )
        finally:
            cur.close()

        conn.commit()
        return JSONResponse({"ok": True})

    except Exception as e:
        conn.rollback()
        return JSONResponse({"ok": False, "error": f"Error al guardar: {e}"}, status_code=500)
    finally:
        sess_conns.release_conn(conn)
