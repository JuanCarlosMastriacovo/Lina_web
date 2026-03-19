from fastapi import APIRouter, Request, HTTPException, Form
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from typing import Dict, Any

from CapaBRL.linabase import linabase
from CapaDAL.tablebase import get_table_model
from CapaBRL.validador_base import BaseValidador

from CapaDAL.dataconn import sess_conns, ctx_empr
from mysql.connector import IntegrityError

router = APIRouter()


PROG_CODE = "LINA111"
ROUTE_BASE = "/clients"
LinaClie = get_table_model("linaclie")
CLIENT_TABLE = LinaClie.TABLE_NAME
CLIENT_COMPANY_FIELD = LinaClie.get_company_field_required()
CLIENT_KEY_FIELD = LinaClie.get_business_key_field()
CLIENT_SELECTOR_FIELDS = LinaClie.get_selector_fields()
CLIENT_LABEL_FIELD = CLIENT_SELECTOR_FIELDS[1]


class Lina111(linabase):
    """Módulo de gestión de clientes (LINA111) con herencia de linabase."""
    SELECTOR_FIELDS = CLIENT_SELECTOR_FIELDS
    DEFAULT_SORT_FIELD = SELECTOR_FIELDS[0]

    @classmethod
    def get_permisos_por_usuario(cls, user: str) -> Dict[str, Any]:
        if cls.permisos_por_usuario_func:
            return cls.permisos_por_usuario_func(user)
        return {}

    @classmethod
    async def list_clients_data(cls):
        return LinaClie.list_all(order_by=cls.DEFAULT_SORT_FIELD, fields=cls.SELECTOR_FIELDS)

    @classmethod
    async def get_client_by_id(cls, cliecodi: int):
        return LinaClie.row_get({CLIENT_KEY_FIELD: cliecodi})

    @classmethod
    async def create_client_in_db(cls, cliecodi: int, cliename: str):
        data = {
            CLIENT_KEY_FIELD: cliecodi,
            CLIENT_LABEL_FIELD: cliename,
            "cliesala": 0,
            "cliefesa": '1900-01-01',
        }
        return LinaClie.row_insert(data)

    @classmethod
    async def update_client_in_db(cls, cliecodi: int, cliename: str):
        return LinaClie.row_update({CLIENT_KEY_FIELD: cliecodi}, {CLIENT_LABEL_FIELD: cliename})

    @classmethod
    async def delete_client_from_db(cls, cliecodi: int):
        return LinaClie.row_delete({CLIENT_KEY_FIELD: cliecodi})

class ClienteValidador(BaseValidador):
    def normalize(self):
        self.normalized_data = {
            'cliecodi': str(self.original_data.get('cliecodi', '')).strip().upper(),
            'cliename': str(self.original_data.get('cliename', '')).strip(),
        }

    def validate_formal(self):
        c = self.normalized_data.get('cliecodi', '')
        n = self.normalized_data.get('cliename', '')
        if not c:
            self.field_errors['cliecodi'] = 'Código obligatorio'
        elif len(c) > 15:
            self.field_errors['cliecodi'] = 'Máximo 15 caracteres'
        if not n:
            self.field_errors['cliename'] = 'Nombre obligatorio'
        elif len(n) > 40:
            self.field_errors['cliename'] = 'Máximo 40 caracteres'

    def validate_negocio(self):
        if self.original_data.get('action') == 'create':
            conn = self.original_data.get('conn')
            c = self.normalized_data.get('cliecodi')
            exists = LinaClie.row_get({CLIENT_KEY_FIELD: c}, conn=conn)
            if exists:
                self.field_errors['cliecodi'] = f'El código {c} ya existe.'

@router.get("/", response_class=HTMLResponse)
async def list_clients(request: Request):
    Lina111.set_prog_code(PROG_CODE)
    user = Lina111.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    perms = Lina111.get_permisos_por_usuario(user).get(Lina111.prog_code)
    if not perms or not perms.cons:
        raise HTTPException(403, "No permisos de consulta")

    conn = Lina111.get_task_conn(request, readonly=True)
    clients = LinaClie.list_all(order_by=Lina111.DEFAULT_SORT_FIELD, fields=Lina111.SELECTOR_FIELDS, conn=conn)

    is_htmx = request.headers.get("HX-Request") == "true"

    context = {
        "request": request,
        "user": user,
        "clients": clients,
        "perms": perms
    }

    if is_htmx:
        context.update({
            "list_title": "Clientes",
            "route_new": f"{ROUTE_BASE}/new",
            "route_list": f"{ROUTE_BASE}/list",
            "grid_content": "lina111/grid.html"
        })
        return Lina111.templates.TemplateResponse("fragments/master_detail.html", context)
    else:
        return Lina111.templates.TemplateResponse("lina111/main.html", context)


@router.get("/list", response_class=HTMLResponse)
async def list_clients_only(request: Request, sort: str = CLIENT_KEY_FIELD, search: str = ""):
    conn = Lina111.get_task_conn(request, readonly=True)
    allowed_sort = set(Lina111.SELECTOR_FIELDS)
    safe_sort = sort if sort in allowed_sort else Lina111.DEFAULT_SORT_FIELD

    search_term = (search or "").strip()
    if search_term:
        clients = LinaClie.search_selector(search_term, safe_sort, conn=conn)
    else:
        clients = LinaClie.list_all(order_by=safe_sort, fields=Lina111.SELECTOR_FIELDS, conn=conn)
    return Lina111.templates.TemplateResponse("lina111/grid.html", {"request": request, "clients": clients})


@router.get("/new", response_class=HTMLResponse)
async def new_client_form(request: Request):
    conn = Lina111.get_task_conn(request, readonly=True)
    ui_meta = Lina111.get_table_ui_metadata(LinaClie, conn=conn)
    return Lina111.templates.TemplateResponse(
        "lina111/form.html",
        {
            "request": request,
            "client": None,
            "action": "create",
            "field_tooltips": ui_meta["field_tooltips"],
            "table_description": ui_meta["table_description"],
        },
    )


@router.get("/detail/{cliecodi}", response_class=HTMLResponse)
async def edit_client_form(request: Request, cliecodi: int):
    conn = Lina111.get_task_conn(request, readonly=True)
    client = LinaClie.row_get({CLIENT_KEY_FIELD: cliecodi}, conn=conn)
    if not client:
        raise HTTPException(404, "Cliente no encontrado")
    ui_meta = Lina111.get_table_ui_metadata(LinaClie, conn=conn)
    return Lina111.templates.TemplateResponse(
        "lina111/form.html",
        {
            "request": request,
            "client": client,
            "action": "edit",
            "field_tooltips": ui_meta["field_tooltips"],
            "table_description": ui_meta["table_description"],
        },
    )


@router.post("/save", response_class=HTMLResponse)
async def save_client(request: Request, cliecodi: int = Form(...), cliename: str = Form(...), action: str = Form(...), tab_id: str = Form(default="", alias="_tab")):
    conn = Lina111.get_task_conn(request, readonly=False)
    validador = ClienteValidador({'cliecodi': cliecodi, 'cliename': cliename, 'action': action, 'conn': conn})
    resultado = validador.validate()
    if not resultado['is_valid']:
        msg = '\n'.join(list(resultado['field_errors'].values()) + resultado['form_errors'])
        return HTMLResponse(content=msg or 'Datos inválidos.', status_code=409)
    try:
        ok = False
        if action == "create":
            ok = LinaClie.row_insert({
                CLIENT_KEY_FIELD: resultado['normalized_data']['cliecodi'],
                CLIENT_LABEL_FIELD: resultado['normalized_data']['cliename'],
                "cliesala": 0,
                "cliefesa": '1900-01-01'
            }, conn=conn)
        else:
            ok = LinaClie.row_update({CLIENT_KEY_FIELD: resultado['normalized_data']['cliecodi']}, {CLIENT_LABEL_FIELD: resultado['normalized_data']['cliename']}, conn=conn)

        if not ok:
            return HTMLResponse(content="No se pudo guardar.", status_code=400)
    except IntegrityError as e:
        conn.rollback()
        if getattr(e, "errno", None) == 1062:
            return HTMLResponse(content=f"El codigo {resultado['normalized_data']['cliecodi']} ya existe.", status_code=409)
        return HTMLResponse(content=f"Error de integridad al guardar: {e.msg}", status_code=400)
    except Exception as e:
        conn.rollback()
        return HTMLResponse(content=f"Error al guardar: {e}", status_code=500)

    user = Lina111.get_current_user(request)
    if user and tab_id:
        sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina111.prog_code or PROG_CODE)
    elif conn:
        conn.commit()
    return HTMLResponse(content="Guardado exitosamente.")


def _client_delete_restriction_message(conn, cliecodi: int) -> str | None:
    parent_values = {CLIENT_COMPANY_FIELD: ctx_empr.get(), CLIENT_KEY_FIELD: cliecodi}
    for relation in LinaClie.CHILD_RELATIONS:
        has_related = LinaClie.has_children(relation, parent_values, conn=conn)
        if has_related:
            child_table = LinaClie._get_table_class(relation["table"])
            description = (getattr(child_table, "TABLE_COMMENT", "") or "").strip()
            if not description:
                description = child_table.get_table_comment(conn=conn)
            if not description:
                description = "Registros relacionados"
            return f"No se puede eliminar el cliente {cliecodi}. Existen registros hijos en tabla: {child_table.TABLE_NAME} ({description})."
    return None


@router.delete("/{cliecodi}/delete", response_class=HTMLResponse)
async def delete_client(request: Request, cliecodi: int):
    conn = Lina111.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn = sess_conns.get_conn(readonly=False, user_override=Lina111.get_current_user(request))
        owns_conn = True
    try:
        restriction_message = _client_delete_restriction_message(conn, cliecodi)
        if restriction_message:
            return HTMLResponse(content=restriction_message, status_code=409)

        ok = LinaClie.row_delete({CLIENT_KEY_FIELD: cliecodi}, conn=conn)
        if not ok:
            restriction_message = _client_delete_restriction_message(conn, cliecodi)
            if restriction_message:
                return HTMLResponse(content=restriction_message, status_code=409)
            return HTMLResponse(
                content=f"No se pudo eliminar el cliente {cliecodi}. Puede tener registros relacionados o una restriccion de integridad.",
                status_code=400,
            )

        tab_id = Lina111.get_tab_id(request)
        user = Lina111.get_current_user(request)
        if owns_conn:
            conn.commit()
        elif user and tab_id:
            sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina111.prog_code or PROG_CODE)

        return HTMLResponse(content="<script>document.body.dispatchEvent(new Event('refreshList'));</script> Eliminado.")
    except Exception as e:
        if owns_conn:
            conn.rollback()
        return HTMLResponse(
            content=f"Error al eliminar el cliente {cliecodi}: {e}",
            status_code=400,
        )
    finally:
        if owns_conn:
            sess_conns.release_conn(conn)


@router.post("/{cliecodi}/recode", response_class=JSONResponse)
async def recode_client(
    request: Request,
    cliecodi: int,
    new_code: int = Form(...),
    tab_id: str = Form(default="", alias="_tab"),
):
    if new_code == cliecodi:
        return JSONResponse({"ok": False, "message": "El nuevo código debe ser distinto."}, status_code=400)

    conn = Lina111.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn = sess_conns.get_conn(readonly=False, user_override=Lina111.get_current_user(request))
        owns_conn = True

    exists = LinaClie.row_get({"cliecodi": new_code}, conn=conn)
    if exists:
        if owns_conn:
            sess_conns.release_conn(conn)
        return JSONResponse({"ok": False, "message": "El código ya existe."}, status_code=400)

    try:
        cur = conn.cursor()
        cur.execute(
            """
            UPDATE linaclie
               SET cliecodi = %s
             WHERE emprcodi = %s
               AND cliecodi = %s
            """,
            (new_code, ctx_empr.get(), cliecodi),
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

    user = Lina111.get_current_user(request)
    if user and tab_id and not owns_conn:
        sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina111.prog_code or "LINA111")
    else:
        conn.commit()

    if owns_conn:
        sess_conns.release_conn(conn)

    return JSONResponse({"ok": True, "new_code": new_code, "message": "Código cambiado correctamente."})
