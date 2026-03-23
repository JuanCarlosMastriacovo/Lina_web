from fastapi import APIRouter, Request, HTTPException, Form
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from typing import Dict, Any

from CapaBRL.linabase import linabase
from CapaDAL.tablebase import get_table_model
from CapaBRL.validador_base import BaseValidador, RecodeIntValidador
from CapaDAL.dataconn import sess_conns, ctx_empr
from mysql.connector import IntegrityError


# ==================== CONSTANTES Y ROUTER ====================

router = APIRouter()
PROG_CODE  = "LINA121"
ROUTE_BASE = "/suppliers"

LinaProv                 = get_table_model("linaprov")
SUPPLIER_TABLE           = LinaProv.TABLE_NAME
SUPPLIER_COMPANY_FIELD   = LinaProv.get_company_field_required()
SUPPLIER_KEY_FIELD       = LinaProv.get_business_key_field()
SUPPLIER_SELECTOR_FIELDS = LinaProv.get_selector_fields()
SUPPLIER_LABEL_FIELD     = SUPPLIER_SELECTOR_FIELDS[1]

# Reglas de dominio para provcodi
SUPPLIER_CODE_MIN = 0
SUPPLIER_CODE_MAX = 9999


# ==================== CLASE PRINCIPAL ====================

class Lina121(linabase):
    """Módulo de gestión de proveedores (LINA121) con herencia de linabase."""
    SELECTOR_FIELDS    = SUPPLIER_SELECTOR_FIELDS
    DEFAULT_SORT_FIELD = SELECTOR_FIELDS[0]

    @classmethod
    def get_permisos_por_usuario(cls, user: str) -> Dict[str, Any]:
        if cls.permisos_por_usuario_func:
            return cls.permisos_por_usuario_func(user)
        return {}

    @classmethod
    async def list_suppliers_data(cls):
        return LinaProv.list_all(order_by=cls.DEFAULT_SORT_FIELD, fields=cls.SELECTOR_FIELDS)

    @classmethod
    async def get_supplier_by_id(cls, provcodi: int):
        return LinaProv.row_get({SUPPLIER_KEY_FIELD: provcodi})

    @classmethod
    async def create_supplier_in_db(cls, provcodi: int, provname: str):
        data = {
            SUPPLIER_KEY_FIELD:  provcodi,
            SUPPLIER_LABEL_FIELD: provname,
            "provsala": 0,
            "provfesa": "1900-01-01",
        }
        return LinaProv.row_insert(data)

    @classmethod
    async def update_supplier_in_db(cls, provcodi: int, provname: str):
        return LinaProv.row_update({SUPPLIER_KEY_FIELD: provcodi}, {SUPPLIER_LABEL_FIELD: provname})

    @classmethod
    async def delete_supplier_from_db(cls, provcodi: int):
        return LinaProv.row_delete({SUPPLIER_KEY_FIELD: provcodi})


# ==================== VALIDADORES ====================

class ProveedorValidador(BaseValidador):
    def normalize(self):
        try:
            provcodi = int(self.original_data.get("provcodi"))
        except (TypeError, ValueError):
            provcodi = None
        self.normalized_data = {
            "provcodi": provcodi,
            "provname": str(self.original_data.get("provname", "")).strip(),
        }

    def validate_formal(self):
        c = self.normalized_data.get("provcodi")
        n = self.normalized_data.get("provname", "")
        if c is None:
            self.field_errors["provcodi"] = "Código obligatorio"
        elif not (SUPPLIER_CODE_MIN <= c <= SUPPLIER_CODE_MAX):
            self.field_errors["provcodi"] = f"El código debe estar entre {SUPPLIER_CODE_MIN} y {SUPPLIER_CODE_MAX}."
        if not n:
            self.field_errors["provname"] = "Nombre obligatorio"
        elif len(n) > 40:
            self.field_errors["provname"] = "Máximo 40 caracteres"

    def validate_negocio(self):
        if self.original_data.get("action") == "create":
            conn = self.original_data.get("conn")
            c    = self.normalized_data.get("provcodi")
            if LinaProv.row_get({SUPPLIER_KEY_FIELD: c}, conn=conn):
                self.field_errors["provcodi"] = f"El código {c} ya existe."


class RecodeProveedorValidador(RecodeIntValidador):
    table_model = LinaProv
    key_field   = SUPPLIER_KEY_FIELD
    code_min    = SUPPLIER_CODE_MIN
    code_max    = SUPPLIER_CODE_MAX


# ==================== FUNCIONES AUXILIARES ====================

def _supplier_delete_restriction_message(conn, provcodi: int) -> str | None:
    """Verifica si el proveedor tiene hijos y retorna el mensaje de restricción, o None si puede eliminarse."""
    parent_values = {SUPPLIER_COMPANY_FIELD: ctx_empr.get(), SUPPLIER_KEY_FIELD: provcodi}
    for relation in LinaProv.CHILD_RELATIONS:
        has_related = LinaProv.has_children(relation, parent_values, conn=conn)
        if has_related:
            child_table = LinaProv._get_table_class(relation["table"])
            description = (getattr(child_table, "TABLE_COMMENT", "") or "").strip()
            if not description:
                description = child_table.get_table_comment(conn=conn)
            if not description:
                description = "Registros relacionados"
            return (
                f"No se puede eliminar el proveedor {provcodi}. "
                f"Existen registros hijos en tabla: {child_table.TABLE_NAME} ({description})."
            )
    return None


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def list_suppliers(request: Request):
    Lina121.set_prog_code(PROG_CODE)
    user = Lina121.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    perms = Lina121.get_permisos_por_usuario(user).get(Lina121.prog_code)
    if not perms or not perms.cons:
        raise HTTPException(403, "No permisos de consulta")

    conn      = Lina121.get_task_conn(request, readonly=True)
    suppliers = LinaProv.list_all(order_by=Lina121.DEFAULT_SORT_FIELD, fields=Lina121.SELECTOR_FIELDS, conn=conn)
    is_htmx   = request.headers.get("HX-Request") == "true"

    context = {
        "request":   request,
        "user":      user,
        "suppliers": suppliers,
        "perms":     perms,
    }

    if is_htmx:
        context.update({
            "list_title":   "Proveedores",
            "route_new":    f"{ROUTE_BASE}/new",
            "route_list":   f"{ROUTE_BASE}/list",
            "grid_content": "lina121/grid.html",
        })
        return Lina121.templates.TemplateResponse("fragments/master_detail.html", context)
    else:
        return Lina121.templates.TemplateResponse("lina121/main.html", context)


@router.get("/list", response_class=HTMLResponse)
async def list_suppliers_only(request: Request, sort: str = SUPPLIER_KEY_FIELD, search: str = ""):
    conn         = Lina121.get_task_conn(request, readonly=True)
    allowed_sort = set(Lina121.SELECTOR_FIELDS)
    safe_sort    = sort if sort in allowed_sort else Lina121.DEFAULT_SORT_FIELD
    search_term  = (search or "").strip()

    if search_term:
        suppliers = LinaProv.search_selector(search_term, safe_sort, conn=conn)
    else:
        suppliers = LinaProv.list_all(order_by=safe_sort, fields=Lina121.SELECTOR_FIELDS, conn=conn)

    return Lina121.templates.TemplateResponse("lina121/grid.html", {"request": request, "suppliers": suppliers})


@router.get("/new", response_class=HTMLResponse)
async def new_supplier_form(request: Request):
    conn    = Lina121.get_task_conn(request, readonly=True)
    ui_meta = Lina121.get_table_ui_metadata(LinaProv, conn=conn)
    return Lina121.templates.TemplateResponse(
        "lina121/form.html",
        {
            "request":           request,
            "supplier":          None,
            "action":            "create",
            "field_tooltips":    ui_meta["field_tooltips"],
            "table_description": ui_meta["table_description"],
        },
    )


@router.get("/detail/{provcodi}", response_class=HTMLResponse)
async def edit_supplier_form(request: Request, provcodi: int):
    conn     = Lina121.get_task_conn(request, readonly=True)
    supplier = LinaProv.row_get({SUPPLIER_KEY_FIELD: provcodi}, conn=conn)
    if not supplier:
        raise HTTPException(404, "Proveedor no encontrado")
    ui_meta = Lina121.get_table_ui_metadata(LinaProv, conn=conn)
    return Lina121.templates.TemplateResponse(
        "lina121/form.html",
        {
            "request":           request,
            "supplier":          supplier,
            "action":            "edit",
            "field_tooltips":    ui_meta["field_tooltips"],
            "table_description": ui_meta["table_description"],
        },
    )


@router.post("/save", response_class=HTMLResponse)
async def save_supplier(
    request:  Request,
    provcodi: int = Form(...),
    provname: str = Form(...),
    action:   str = Form(...),
    tab_id:   str = Form(default="", alias="_tab"),
):
    conn      = Lina121.get_task_conn(request, readonly=False)
    validador = ProveedorValidador({"provcodi": provcodi, "provname": provname, "action": action, "conn": conn})
    resultado = validador.validate()
    if not resultado["is_valid"]:
        msg = "\n".join(list(resultado["field_errors"].values()) + resultado["form_errors"])
        return HTMLResponse(content=msg or "Datos inválidos.", status_code=409)

    try:
        if action == "create":
            insert_data = {
                SUPPLIER_KEY_FIELD:   resultado["normalized_data"]["provcodi"],
                SUPPLIER_LABEL_FIELD: resultado["normalized_data"]["provname"],
                "provsala":           0,
                "provfesa":           "1900-01-01",
                SUPPLIER_COMPANY_FIELD: ctx_empr.get(),
            }
            if not LinaProv.row_got_parents(insert_data, conn=conn):
                return HTMLResponse(
                    content="No existen todos los registros padres requeridos para crear el proveedor.",
                    status_code=409,
                )
            ok = LinaProv.row_insert(insert_data, conn=conn)
        else:
            ok = LinaProv.row_update(
                {SUPPLIER_KEY_FIELD: resultado["normalized_data"]["provcodi"]},
                {SUPPLIER_LABEL_FIELD: resultado["normalized_data"]["provname"]},
                conn=conn,
            )

        if not ok:
            return HTMLResponse(content="No se pudo guardar.", status_code=400)

    except IntegrityError as e:
        conn.rollback()
        if getattr(e, "errno", None) == 1062:
            return HTMLResponse(
                content=f"El codigo {resultado['normalized_data']['provcodi']} ya existe.",
                status_code=409,
            )
        return HTMLResponse(content=f"Error de integridad al guardar: {e.msg}", status_code=400)
    except Exception as e:
        conn.rollback()
        return HTMLResponse(content=f"Error al guardar: {e}", status_code=500)

    user = Lina121.get_current_user(request)
    if user and tab_id:
        sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina121.prog_code or PROG_CODE)
    elif conn:
        conn.commit()
    return HTMLResponse(content="Guardado exitosamente.")


@router.delete("/{provcodi}/delete", response_class=HTMLResponse)
async def delete_supplier(request: Request, provcodi: int):
    conn      = Lina121.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn      = sess_conns.get_conn(readonly=False, user_override=Lina121.get_current_user(request))
        owns_conn = True
    try:
        restriction_message = _supplier_delete_restriction_message(conn, provcodi)
        if restriction_message:
            return HTMLResponse(content=restriction_message, status_code=409)

        ok = LinaProv.row_delete({SUPPLIER_KEY_FIELD: provcodi}, conn=conn)
        if not ok:
            restriction_message = _supplier_delete_restriction_message(conn, provcodi)
            if restriction_message:
                return HTMLResponse(content=restriction_message, status_code=409)
            return HTMLResponse(
                content=f"No se pudo eliminar el proveedor {provcodi}. Puede tener registros relacionados o una restricción de integridad.",
                status_code=400,
            )

        tab_id = Lina121.get_tab_id(request)
        user   = Lina121.get_current_user(request)
        if owns_conn:
            conn.commit()
        elif user and tab_id:
            sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina121.prog_code or PROG_CODE)

        return HTMLResponse(content="<script>document.body.dispatchEvent(new Event('refreshList'));</script> Eliminado.")

    except Exception as e:
        if owns_conn:
            conn.rollback()
        return HTMLResponse(content=f"Error al eliminar el proveedor {provcodi}: {e}", status_code=400)
    finally:
        if owns_conn:
            sess_conns.release_conn(conn)


@router.post("/{provcodi}/recode", response_class=JSONResponse)
async def recode_supplier(
    request:  Request,
    provcodi: int,
    new_code: int = Form(...),
    tab_id:   str = Form(default="", alias="_tab"),
):
    return await Lina121.exec_recode_int(
        request, provcodi, new_code,
        LinaProv, SUPPLIER_KEY_FIELD,
        RecodeProveedorValidador,
        PROG_CODE, tab_id,
    )
