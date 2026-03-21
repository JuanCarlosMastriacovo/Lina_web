@router.post("/{artrcodi}/recode", response_class=JSONResponse)
async def recode_rubro(
    request: Request,
    artrcodi: str,
    new_code: str = Form(...),
    tab_id: str = Form(default="", alias="_tab"),
):
    conn = Lina131.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn = sess_conns.get_conn(readonly=False, user_override=Lina131.get_current_user(request))
        owns_conn = True

    # Validación con RecodeRubroValidador
    validador = RecodeRubroValidador({
        "artrcodi": artrcodi,
        "new_code": new_code,
        "conn": conn
    })
    resultado = validador.validate()
    if not resultado["is_valid"]:
        msg = '\n'.join(list(resultado["field_errors"].values()) + resultado["form_errors"])
        if owns_conn:
            sess_conns.release_conn(conn)
        return JSONResponse({"ok": False, "message": msg or "Datos inválidos."}, status_code=400)

    try:
        cur = conn.cursor()
        cur.execute(
            f"""
            UPDATE {RUBRO_TABLE}
               SET {RUBRO_KEY_FIELD} = %s
             WHERE {RUBRO_COMPANY_FIELD} = %s
               AND {RUBRO_KEY_FIELD} = %s
            """,
            (resultado['normalized_data']['new_code'], ctx_empr.get(), resultado['normalized_data']['artrcodi']),
        )
        updated = cur.rowcount
        cur.close()
    except IntegrityError as e:
        if owns_conn:
            conn.rollback()
        return JSONResponse({"ok": False, "message": f"No se pudo cambiar el código: {e.msg}"}, status_code=400)
    except Exception as e:
        if owns_conn:
            conn.rollback()
        return JSONResponse({"ok": False, "message": f"Error al cambiar código: {e}"}, status_code=500)

    if updated == 0:
        return JSONResponse({"ok": False, "message": "No se encontró el registro a recodificar."}, status_code=404)

    user = Lina131.get_current_user(request)
    if user and tab_id and not owns_conn:
        sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina131.prog_code or PROG_CODE)
    else:
        conn.commit()

    if owns_conn:
        sess_conns.release_conn(conn)

    return JSONResponse({"ok": True, "new_code": resultado['normalized_data']['new_code'], "message": "Código cambiado correctamente."})


class RecodeRubroValidador(BaseValidador):
    """Validador para el cambio de código (recode) de un rubro."""
    def normalize(self):
        # Forzar a str y upper si es posible, si no, dejar None
        artrcodi = self.original_data.get("artrcodi")
        new_code = self.original_data.get("new_code")
        if artrcodi is not None:
            artrcodi = str(artrcodi).strip().upper()
        if new_code is not None:
            new_code = str(new_code).strip().upper()
        self.normalized_data = {
            "artrcodi": artrcodi,
            "new_code": new_code,
        }

    def validate_formal(self):
        new = self.normalized_data.get("new_code")
        old = self.normalized_data.get("artrcodi")
        if not new:
            self.field_errors["new_code"] = "El nuevo código es obligatorio."
            return
        if not old:
            self.field_errors["artrcodi"] = "El código actual es inválido."
            return
        if len(new) > 9:
            self.field_errors["new_code"] = "Máximo 9 caracteres."
            return
        if new == old:
            self.field_errors["new_code"] = "El nuevo código debe ser distinto al actual."

    def validate_negocio(self):
        if "new_code" in self.field_errors:
            return
        conn = self.original_data.get("conn")
        new = self.normalized_data.get("new_code")
        if LinaArtr.row_get({RUBRO_KEY_FIELD: new}, conn=conn):
            self.field_errors["new_code"] = f"El código {new} ya existe."
from fastapi import APIRouter, Request, HTTPException, Form
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from typing import Dict, Any

from CapaBRL.linabase import linabase
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import sess_conns, ctx_empr
from mysql.connector import IntegrityError
from CapaBRL.validador_base import BaseValidador

router = APIRouter()
PROG_CODE = "LINA131"
ROUTE_BASE = "/rubros"
LinaArtr = get_table_model("linaartr")
RUBRO_TABLE = LinaArtr.TABLE_NAME
RUBRO_COMPANY_FIELD = LinaArtr.get_company_field_required()
RUBRO_KEY_FIELD = LinaArtr.get_business_key_field()
RUBRO_SELECTOR_FIELDS = LinaArtr.get_selector_fields()
RUBRO_LABEL_FIELD = RUBRO_SELECTOR_FIELDS[1]

class Lina131(linabase):
    """Módulo de gestión de rubros/artículos (LINA131) con herencia de linabase."""
    SELECTOR_FIELDS = RUBRO_SELECTOR_FIELDS
    DEFAULT_SORT_FIELD = SELECTOR_FIELDS[0]
    
    @classmethod
    def get_permisos_por_usuario(cls, user: str) -> Dict[str, Any]:
        """Obtiene los permisos del usuario para este módulo."""
        if cls.permisos_por_usuario_func:
            return cls.permisos_por_usuario_func(user)
        return {}
    
    @classmethod
    async def list_rubros_data(cls):
        """Obtiene la lista de rubros para la grilla selector."""
        return LinaArtr.list_all(order_by=cls.DEFAULT_SORT_FIELD, fields=cls.SELECTOR_FIELDS)

    @classmethod
    async def get_rubro_by_id(cls, artrcodi: str):
        """Obtiene un rubro específico usando la CapaDAL."""
        return LinaArtr.row_get({RUBRO_KEY_FIELD: artrcodi})

    @classmethod
    async def create_rubro_in_db(cls, artrcodi: str, artrdesc: str):
        """Crea un nuevo rubro usando la CapaDAL."""
        data = {
            RUBRO_KEY_FIELD: artrcodi,
            RUBRO_LABEL_FIELD: artrdesc,
        }
        return LinaArtr.row_insert(data)

    @classmethod
    async def update_rubro_in_db(cls, artrcodi: str, artrdesc: str):
        """Actualiza un rubro usando la CapaDAL."""
        return LinaArtr.row_update({RUBRO_KEY_FIELD: artrcodi}, {RUBRO_LABEL_FIELD: artrdesc})

    @classmethod
    async def delete_rubro_from_db(cls, artrcodi: str):
        """Elimina un rubro usando la CapaDAL."""
        return LinaArtr.row_delete({RUBRO_KEY_FIELD: artrcodi})

class RubroValidador(BaseValidador):
    def normalize(self):
        self.normalized_data = {
            'artrcodi': str(self.original_data.get('artrcodi', '')).strip().upper(),
            'artrdesc': str(self.original_data.get('artrdesc', '')).strip(),
        }

    def validate_formal(self):
        c = self.normalized_data.get('artrcodi', '')
        n = self.normalized_data.get('artrdesc', '')
        if not c:
            self.field_errors['artrcodi'] = 'Código obligatorio'
        elif len(c) > 9:
            self.field_errors['artrcodi'] = 'Máximo 9 caracteres'
        if not n:
            self.field_errors['artrdesc'] = 'Descripción obligatoria'
        elif len(n) > 30:
            self.field_errors['artrdesc'] = 'Máximo 30 caracteres'

    def validate_negocio(self):
        if self.original_data.get('action') == 'create':
            conn = self.original_data.get('conn')
            c = self.normalized_data.get('artrcodi')
            exists = LinaArtr.row_get({RUBRO_KEY_FIELD: c}, conn=conn)
            if exists:
                self.field_errors['artrcodi'] = f'El código {c} ya existe.'

@router.get("/", response_class=HTMLResponse)
async def list_rubros(request: Request):
    Lina131.set_prog_code(PROG_CODE)
    user = Lina131.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    perms = Lina131.get_permisos_por_usuario(user).get(Lina131.prog_code)
    if not perms or not perms.cons:
        raise HTTPException(403, "No permisos de consulta")

    conn = Lina131.get_task_conn(request, readonly=True)
    rubros = LinaArtr.list_all(order_by=Lina131.DEFAULT_SORT_FIELD, fields=Lina131.SELECTOR_FIELDS, conn=conn)
    
    # Detectar si viene de un tab (HTMX)
    is_htmx = request.headers.get("HX-Request") == "true"
    
    context = {
        "request": request, 
        "user": user, 
        "rubros": rubros, 
        "perms": perms
    }
    
    if is_htmx:
        # Contexto para fragmento
        context.update({
            "list_title": "Rubros",
            "route_new": "/rubros/new",
            "route_list": "/rubros/list",
            "grid_content": "lina131/grid.html"
        })
        return Lina131.templates.TemplateResponse("fragments/master_detail.html", context)
    else:
        return Lina131.templates.TemplateResponse("lina131/main.html", context)


@router.get("/list", response_class=HTMLResponse)
async def list_rubros_only(request: Request, sort: str = RUBRO_KEY_FIELD, search: str = ""):
    conn = Lina131.get_task_conn(request, readonly=True)
    allowed_sort = set(Lina131.SELECTOR_FIELDS)
    safe_sort = sort if sort in allowed_sort else Lina131.DEFAULT_SORT_FIELD

    search_term = (search or "").strip()
    if search_term:
        rubros = LinaArtr.search_selector(search_term, safe_sort, conn=conn)
    else:
        rubros = LinaArtr.list_all(order_by=safe_sort, fields=Lina131.SELECTOR_FIELDS, conn=conn)
    return Lina131.templates.TemplateResponse("lina131/grid.html", {"request": request, "rubros": rubros})


@router.get("/new", response_class=HTMLResponse)
async def new_rubro_form(request: Request):
    conn = Lina131.get_task_conn(request, readonly=True)
    ui_meta = Lina131.get_table_ui_metadata(LinaArtr, conn=conn)
    return Lina131.templates.TemplateResponse(
        "lina131/form.html",
        {
            "request": request,
            "rubro": None,
            "action": "create",
            "field_tooltips": ui_meta["field_tooltips"],
            "table_description": ui_meta["table_description"],
        },
    )


@router.get("/detail/{artrcodi}", response_class=HTMLResponse)
async def edit_rubro_form(request: Request, artrcodi: str):
    conn = Lina131.get_task_conn(request, readonly=True)
    rubro = LinaArtr.row_get({RUBRO_KEY_FIELD: artrcodi}, conn=conn)
    if not rubro:
        raise HTTPException(404, "Rubro no encontrado")
    ui_meta = Lina131.get_table_ui_metadata(LinaArtr, conn=conn)

    return Lina131.templates.TemplateResponse(
        "lina131/form.html",
        {
            "request": request,
            "rubro": rubro,
            "action": "edit",
            "field_tooltips": ui_meta["field_tooltips"],
            "table_description": ui_meta["table_description"],
        },
    )


@router.post("/save", response_class=HTMLResponse)
async def save_rubro(request: Request, artrcodi: str = Form(...), artrdesc: str = Form(...), action: str = Form(...), tab_id: str = Form(default="", alias="_tab")):
    conn = Lina131.get_task_conn(request, readonly=False)
    validador = RubroValidador({'artrcodi': artrcodi, 'artrdesc': artrdesc, 'action': action, 'conn': conn})
    resultado = validador.validate()
    if not resultado['is_valid']:
        msg = '\n'.join(list(resultado['field_errors'].values()) + resultado['form_errors'])
        return HTMLResponse(content=msg or 'Datos inválidos.', status_code=409)
    try:
        ok = False
        if action == "create":
            ok = LinaArtr.row_insert({RUBRO_KEY_FIELD: resultado['normalized_data']['artrcodi'], RUBRO_LABEL_FIELD: resultado['normalized_data']['artrdesc']}, conn=conn)
        else:
            ok = LinaArtr.row_update({RUBRO_KEY_FIELD: resultado['normalized_data']['artrcodi']}, {RUBRO_LABEL_FIELD: resultado['normalized_data']['artrdesc']}, conn=conn)

        if not ok:
            return HTMLResponse(content="No se pudo guardar.", status_code=400)
    except IntegrityError as e:
        conn.rollback()
        if getattr(e, "errno", None) == 1062:
            return HTMLResponse(content=f"El codigo {resultado['normalized_data']['artrcodi']} ya existe.", status_code=409)
        return HTMLResponse(content=f"Error de integridad al guardar: {e.msg}", status_code=400)
    except Exception as e:
        conn.rollback()
        return HTMLResponse(content=f"Error al guardar: {e}", status_code=500)

    user = Lina131.get_current_user(request)
    if user and tab_id:
        sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina131.prog_code or PROG_CODE)
    elif conn:
        conn.commit()
    
    return HTMLResponse(content="Guardado exitosamente.")


def _rubro_delete_restriction_message(conn, artrcodi: str) -> str | None:
    parent_values = {RUBRO_COMPANY_FIELD: ctx_empr.get(), RUBRO_KEY_FIELD: artrcodi}

    for relation in LinaArtr.CHILD_RELATIONS:
        has_related = LinaArtr.has_children(relation, parent_values, conn=conn)
        if has_related:
            child_table = LinaArtr._get_table_class(relation["table"])
            description = (getattr(child_table, "TABLE_COMMENT", "") or "").strip()
            if not description:
                description = child_table.get_table_comment(conn=conn)
            if not description:
                description = "Registros relacionados"
            return f"No se puede eliminar el rubro {artrcodi}. Existen registros hijos en tabla: {child_table.TABLE_NAME} ({description})."
    return None


@router.delete("/{artrcodi}/delete", response_class=HTMLResponse)
async def delete_rubro(request: Request, artrcodi: str):
    conn = Lina131.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn = sess_conns.get_conn(readonly=False, user_override=Lina131.get_current_user(request))
        owns_conn = True
    try:
        restriction_message = _rubro_delete_restriction_message(conn, artrcodi)
        if restriction_message:
            return HTMLResponse(content=restriction_message, status_code=409)

        ok = LinaArtr.row_delete({RUBRO_KEY_FIELD: artrcodi}, conn=conn)
        if not ok:
            restriction_message = _rubro_delete_restriction_message(conn, artrcodi)
            if restriction_message:
                return HTMLResponse(content=restriction_message, status_code=409)
            return HTMLResponse(
                content=f"No se pudo eliminar el rubro {artrcodi}. Puede tener registros relacionados o una restriccion de integridad.",
                status_code=400,
            )

        tab_id = Lina131.get_tab_id(request)
        user = Lina131.get_current_user(request)
        if owns_conn:
            conn.commit()
        elif user and tab_id:
            sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina131.prog_code or PROG_CODE)

        return HTMLResponse(content="<script>document.body.dispatchEvent(new Event('refreshList'));</script> Eliminado.")
    except Exception as e:
        if owns_conn:
            conn.rollback()
        return HTMLResponse(
            content=f"Error al eliminar el rubro {artrcodi}: {e}",
            status_code=400,
        )
    finally:
        if owns_conn:
            sess_conns.release_conn(conn)


@router.post("/{artrcodi}/recode", response_class=JSONResponse)
async def recode_rubro(
    request: Request,
    artrcodi: str,
    new_code: str = Form(...),
    tab_id: str = Form(default="", alias="_tab"),
):
    new_code = (new_code or "").strip()
    if not new_code:
        return JSONResponse({"ok": False, "message": "Debe indicar el nuevo código."}, status_code=400)
    if new_code == artrcodi:
        return JSONResponse({"ok": False, "message": "El nuevo código debe ser distinto."}, status_code=400)

    conn = Lina131.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn = sess_conns.get_conn(readonly=False, user_override=Lina131.get_current_user(request))
        owns_conn = True

    exists = LinaArtr.row_get({RUBRO_KEY_FIELD: new_code}, conn=conn)
    if exists:
        if owns_conn:
            sess_conns.release_conn(conn)
        return JSONResponse({"ok": False, "message": "El código ya existe."}, status_code=400)


    try:
        updated = LinaArtr.update_pk({RUBRO_KEY_FIELD: artrcodi}, new_code, conn=conn)
    except IntegrityError as e:
        if owns_conn:
            conn.rollback()
        return JSONResponse({"ok": False, "message": f"No se pudo cambiar el código: {e.msg}"}, status_code=400)
    except Exception as e:
        if owns_conn:
            conn.rollback()
        return JSONResponse({"ok": False, "message": f"Error al cambiar código: {e}"}, status_code=500)

    if updated == 0:
        return JSONResponse({"ok": False, "message": "No se encontró el registro a recodificar."}, status_code=404)

    user = Lina131.get_current_user(request)
    if user and tab_id and not owns_conn:
        sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina131.prog_code or PROG_CODE)
    else:
        conn.commit()

    if owns_conn:
        sess_conns.release_conn(conn)

    return JSONResponse({"ok": True, "new_code": new_code, "message": "Código cambiado correctamente."})
