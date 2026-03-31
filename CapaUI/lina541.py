import re

from fastapi import APIRouter, Request, HTTPException, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from typing import Dict, Any

from CapaBRL.linabase import linabase
from CapaBRL.password_rules import hash_password, validate_password
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import sess_conns, ctx_empr
from mysql.connector import IntegrityError


# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA541"
ROUTE_BASE = "/users"

LinaUser             = get_table_model("linauser")
USER_TABLE           = LinaUser.TABLE_NAME
USER_COMPANY_FIELD   = LinaUser.get_company_field_required()
USER_KEY_FIELD       = LinaUser.get_business_key_field()          # usercodi
USER_SELECTOR_FIELDS = LinaUser.get_selector_fields()
USER_LABEL_FIELD     = USER_SELECTOR_FIELDS[1]                    # username

# BR-017: usercodi longitud 8-32, caracteres permitidos
USERCODI_ALLOWED_RE = re.compile(r'^[A-Za-z0-9_.\ ]+$')

# ============================================================
# NOTA BR-017 — Columnas pendientes de agregar a linauser:
#   userpdat  DATETIME   — fecha/hora del último cambio de contraseña
#   userfail  INT        — número de intentos fallidos consecutivos
#   userlock  DATETIME   — bloqueado hasta fecha-hora (NULL = no bloqueado)
#   userplog  CHAR(192)  — historial de los últimos 3 hashes (3×64)
#   userbloq  CHAR(1)    — condición de bloqueo (a definir con el negocio)
# Estas columnas deberán crearse con ALTER TABLE antes de activar las
# políticas de historial, bloqueo temporal y rotación de contraseña.
# ============================================================


# ==================== CLASE PRINCIPAL ====================

class Lina541(linabase):
    """ABM de Usuarios del Sistema (LINA541)."""
    SELECTOR_FIELDS    = USER_SELECTOR_FIELDS
    DEFAULT_SORT_FIELD = SELECTOR_FIELDS[0]

    @classmethod
    def get_permisos_por_usuario(cls, user: str) -> Dict[str, Any]:
        if cls.permisos_por_usuario_func:
            return cls.permisos_por_usuario_func(user)
        return {}


# ==================== VALIDACIÓN DE CONTRASEÑA ====================

def _validate_usercodi(raw: str) -> str | None:
    """Valida usercodi según BR-017. Retorna mensaje de error o None."""
    if len(raw) < 8:
        return "El código de usuario debe tener al menos 8 caracteres."
    if len(raw) > 32:
        return "El código de usuario no puede tener más de 32 caracteres."
    if not USERCODI_ALLOWED_RE.match(raw):
        return "El código sólo puede contener letras, números, guion bajo, espacios y punto."
    return None


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def list_users(request: Request):
    Lina541.set_prog_code(PROG_CODE)
    user = Lina541.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    perms = Lina541.get_permisos_por_usuario(user).get(Lina541.prog_code)
    if not perms or not perms.cons:
        raise HTTPException(403, "No permisos de consulta")

    conn  = Lina541.get_task_conn(request, readonly=True)
    users = LinaUser.list_all(order_by=Lina541.DEFAULT_SORT_FIELD, fields=Lina541.SELECTOR_FIELDS, conn=conn)
    is_htmx = request.headers.get("HX-Request") == "true"

    context = {
        "request":      request,
        "user":         user,
        "users":        users,
        "perms":        perms,
        "allow_recode": False,
    }

    if is_htmx:
        context.update({
            "list_title":   "Usuarios",
            "route_new":    f"{ROUTE_BASE}/new",
            "route_list":   f"{ROUTE_BASE}/list",
            "grid_content": "lina541/grid.html",
        })
        return Lina541.templates.TemplateResponse("fragments/master_detail.html", context)
    else:
        return Lina541.templates.TemplateResponse("lina541/main.html", context)


@router.get("/list", response_class=HTMLResponse)
async def list_users_only(request: Request, sort: str = USER_KEY_FIELD, search: str = ""):
    conn         = Lina541.get_task_conn(request, readonly=True)
    allowed_sort = set(Lina541.SELECTOR_FIELDS)
    safe_sort    = sort if sort in allowed_sort else Lina541.DEFAULT_SORT_FIELD
    search_term  = (search or "").strip()

    if search_term:
        users = LinaUser.search_selector(search_term, safe_sort, conn=conn)
    else:
        users = LinaUser.list_all(order_by=safe_sort, fields=Lina541.SELECTOR_FIELDS, conn=conn)

    return Lina541.templates.TemplateResponse("lina541/grid.html", {"request": request, "users": users})


@router.get("/new", response_class=HTMLResponse)
async def new_user_form(request: Request):
    conn    = Lina541.get_task_conn(request, readonly=True)
    ui_meta = Lina541.get_table_ui_metadata(LinaUser, conn=conn)
    return Lina541.templates.TemplateResponse(
        "lina541/form.html",
        {
            "request":           request,
            "entity":            None,
            "action":            "create",
            "field_tooltips":    ui_meta["field_tooltips"],
            "table_description": ui_meta["table_description"],
        },
    )


@router.get("/detail/{usercodi}", response_class=HTMLResponse)
async def edit_user_form(request: Request, usercodi: str):
    conn   = Lina541.get_task_conn(request, readonly=True)
    entity = LinaUser.row_get({USER_KEY_FIELD: usercodi}, conn=conn)
    if not entity:
        raise HTTPException(404, "Usuario no encontrado")
    ui_meta = Lina541.get_table_ui_metadata(LinaUser, conn=conn)
    return Lina541.templates.TemplateResponse(
        "lina541/form.html",
        {
            "request":           request,
            "entity":            entity,
            "action":            "edit",
            "field_tooltips":    ui_meta["field_tooltips"],
            "table_description": ui_meta["table_description"],
        },
    )


@router.post("/save", response_class=HTMLResponse)
async def save_user(
    request:          Request,
    usercodi:         str = Form(...),
    username:         str = Form(...),
    userpass:         str = Form(default=""),
    userpass_confirm: str = Form(default=""),
    action:           str = Form(...),
    tab_id:           str = Form(default="", alias="_tab"),
):
    # ── Normalización ────────────────────────────────────────────
    usercodi_norm = usercodi.strip().upper()
    username_norm = username.strip()
    pass_raw      = userpass.strip()
    pass_confirm  = userpass_confirm.strip()

    # ── Validación de usercodi (BR-017) ──────────────────────────
    err_codi = _validate_usercodi(usercodi_norm)
    if err_codi:
        return HTMLResponse(content=err_codi, status_code=409)

    if not username_norm:
        return HTMLResponse(content="El nombre de usuario es obligatorio.", status_code=409)
    if len(username_norm) > 40:
        return HTMLResponse(content="El nombre no puede tener más de 40 caracteres.", status_code=409)

    # ── Validación de contraseña ─────────────────────────────────
    if action == "create" and not pass_raw:
        return HTMLResponse(content="La contraseña es obligatoria al crear un usuario.", status_code=409)

    if pass_raw:
        if pass_raw != pass_confirm:
            return HTMLResponse(content="Las contraseñas no coinciden.", status_code=409)
        err_pass = validate_password(pass_raw, usercodi_norm)
        if err_pass:
            return HTMLResponse(content=err_pass, status_code=409)

    conn         = Lina541.get_task_conn(request, readonly=False)
    empr_actual  = ctx_empr.get()

    # ── Unicidad en create ───────────────────────────────────────
    if action == "create":
        if LinaUser.row_get({USER_KEY_FIELD: usercodi_norm}, conn=conn):
            return HTMLResponse(content=f"El código '{usercodi_norm}' ya existe.", status_code=409)

    try:
        if action == "create":
            pass_hash   = hash_password(pass_raw)
            insert_data = {
                USER_KEY_FIELD:     usercodi_norm,
                USER_LABEL_FIELD:   username_norm,
                "userpass":         pass_hash,
                USER_COMPANY_FIELD: empr_actual,
            }
            if not LinaUser.row_got_parents(insert_data, conn=conn):
                return HTMLResponse(
                    content="No existen todos los registros padres requeridos para crear el usuario.",
                    status_code=409,
                )
            ok = LinaUser.row_insert(insert_data, conn=conn)
            if not ok:
                return HTMLResponse(content="No se pudo guardar.", status_code=400)

            # Propagar a todas las demás empresas en la misma transacción
            cur = conn.cursor()
            try:
                cur.execute(
                    "CALL sp_create_user_by_empr(%s, %s, %s, %s)",
                    (empr_actual, usercodi_norm, username_norm, pass_hash),
                )
            finally:
                cur.close()

        else:
            ok = LinaUser.row_update(
                {USER_KEY_FIELD: usercodi_norm},
                {USER_LABEL_FIELD: username_norm},
                conn=conn,
            )
            if not ok:
                return HTMLResponse(content="No se pudo guardar.", status_code=400)

    except IntegrityError as e:
        conn.rollback()
        if getattr(e, "errno", None) == 1062:
            return HTMLResponse(content=f"El código '{usercodi_norm}' ya existe.", status_code=409)
        return HTMLResponse(content=f"Error de integridad al guardar: {e.msg}", status_code=400)
    except Exception as e:
        conn.rollback()
        return HTMLResponse(content=f"Error al guardar: {e}", status_code=500)

    user = Lina541.get_current_user(request)
    if user and tab_id:
        sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina541.prog_code or PROG_CODE)
    elif conn:
        conn.commit()
    return HTMLResponse(content="Guardado exitosamente.")


@router.delete("/{usercodi}/delete", response_class=HTMLResponse)
async def delete_user(request: Request, usercodi: str):
    conn      = Lina541.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn      = sess_conns.get_conn(readonly=False, user_override=Lina541.get_current_user(request))
        owns_conn = True
    try:
        empr_actual = ctx_empr.get()

        # Eliminar de la empresa actual (linasafe cae en cascada desde la BD)
        ok = LinaUser.row_delete({USER_KEY_FIELD: usercodi}, conn=conn)
        if not ok:
            return HTMLResponse(
                content=f"No se pudo eliminar el usuario '{usercodi}'.",
                status_code=400,
            )

        # Eliminar de todas las demás empresas en la misma transacción
        cur = conn.cursor()
        try:
            cur.execute(
                "CALL sp_delete_user_by_empr(%s, %s)",
                (empr_actual, usercodi),
            )
        finally:
            cur.close()

        tab_id = Lina541.get_tab_id(request)
        user   = Lina541.get_current_user(request)
        if owns_conn:
            conn.commit()
        elif user and tab_id:
            sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina541.prog_code or PROG_CODE)

        return HTMLResponse(content="<script>document.body.dispatchEvent(new Event('refreshList'));</script> Eliminado.")

    except Exception as e:
        if owns_conn:
            conn.rollback()
        return HTMLResponse(content=f"Error al eliminar el usuario '{usercodi}': {e}", status_code=400)
    finally:
        if owns_conn:
            sess_conns.release_conn(conn)
