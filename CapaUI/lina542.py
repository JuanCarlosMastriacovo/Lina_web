from fastapi import APIRouter, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse

from CapaBRL.linabase import linabase
from CapaBRL.password_rules import hash_password, verify_password, validate_password
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import sess_conns, ctx_empr


# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA542"
ROUTE_BASE = "/lina542"

LinaUser = get_table_model("linauser")
LinaEmpr = get_table_model("linaempr")


# ==================== CLASE PRINCIPAL ====================

class Lina542(linabase):
    """Cambio de contraseña propia (LINA542). Acceso solo al usuario de sesión."""


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina542_main(request: Request):
    Lina542.set_prog_code(PROG_CODE)
    user = Lina542.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    # Sin verificación de linasafe: cualquier usuario autenticado puede
    # cambiar su propia contraseña.
    tab_id = Lina542.get_tab_id(request)
    return Lina542.templates.TemplateResponse(
        "lina542/main.html",
        {"request": request, "user": user, "tab_id": tab_id},
    )


@router.post("/change", response_class=JSONResponse)
async def lina542_change(
    request:         Request,
    pass_actual:     str = Form(...),
    pass_nueva:      str = Form(...),
    pass_confirma:   str = Form(...),
    tab_id:          str = Form(default="", alias="_tab"),
):
    user = Lina542.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "Sesión expirada."}, status_code=401)

    pass_actual_raw  = pass_actual.strip()
    pass_nueva_raw   = pass_nueva.strip()
    pass_confirma_raw = pass_confirma.strip()

    # ── Validaciones previas ─────────────────────────────────────
    if not pass_actual_raw:
        return JSONResponse({"ok": False, "error": "Ingrese su contraseña actual."}, status_code=409)

    if pass_nueva_raw != pass_confirma_raw:
        return JSONResponse({"ok": False, "error": "Las contraseñas nuevas no coinciden."}, status_code=409)

    err = validate_password(pass_nueva_raw, user)
    if err:
        return JSONResponse({"ok": False, "error": err}, status_code=409)

    conn      = sess_conns.get_conn(readonly=False, user_override=user)
    owns_conn = True
    try:
        # ── Verificar contraseña actual ──────────────────────────
        row = LinaUser.row_get(
            {"emprcodi": ctx_empr.get(), "usercodi": user},
            conn=conn,
        )
        if not row:
            return JSONResponse({"ok": False, "error": "Usuario no encontrado."}, status_code=404)

        if not verify_password(pass_actual_raw, row["userpass"]):
            return JSONResponse({"ok": False, "error": "La contraseña actual es incorrecta."}, status_code=409)

        # ── Actualizar en TODAS las empresas (transacción única) ─
        nuevo_hash = hash_password(pass_nueva_raw)
        cur = conn.cursor()
        try:
            cur.execute(
                "UPDATE linauser SET userpass = %s WHERE usercodi = %s",
                (nuevo_hash, user),
            )
            filas_actualizadas = cur.rowcount
        finally:
            cur.close()

        # ── Determinar si hay más de una empresa ─────────────────
        cur2 = conn.cursor()
        try:
            cur2.execute("SELECT COUNT(*) FROM linaempr")
            total_empresas = cur2.fetchone()[0]
        finally:
            cur2.close()

        conn.commit()

        msg = "Contraseña actualizada correctamente."
        if total_empresas > 1:
            msg += f" La contraseña se ha cambiado para todas las empresas ({filas_actualizadas} registros)."

        return JSONResponse({"ok": True, "message": msg})

    except Exception as e:
        conn.rollback()
        return JSONResponse({"ok": False, "error": f"Error al cambiar la contraseña: {e}"}, status_code=500)
    finally:
        sess_conns.release_conn(conn)
