from fastapi import APIRouter, Request, HTTPException, Form
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from typing import Dict, Any

from CapaBRL.linabase import linabase
from CapaDAL.tablebase import get_table_model
from CapaBRL.validador_base import BaseValidador
from CapaDAL.dataconn import sess_conns, ctx_empr
from mysql.connector import IntegrityError


# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA132"
ROUTE_BASE = "/lina132"

LinaArti = get_table_model("linaarti")
LinaArtr = get_table_model("linaartr")

ARTICLE_TABLE           = LinaArti.TABLE_NAME
ARTICLE_COMPANY_FIELD   = LinaArti.get_company_field_required()
ARTICLE_KEY_FIELD       = LinaArti.get_business_key_field()
ARTICLE_SELECTOR_FIELDS = ["articodi", "artidesc"]
ARTICLE_LABEL_FIELD     = ARTICLE_SELECTOR_FIELDS[1]
print("KEY:", ARTICLE_KEY_FIELD)
print("LABEL:", ARTICLE_LABEL_FIELD)
print("SELECTOR:", ARTICLE_SELECTOR_FIELDS)
ARTICLE_CODE_MIN = 0
ARTICLE_CODE_MAX = 999999


# ==================== CLASE PRINCIPAL ====================

class Lina132(linabase):
    """Módulo de gestión de artículos (LINA132)."""

    SELECTOR_FIELDS    = ARTICLE_SELECTOR_FIELDS
    DEFAULT_SORT_FIELD = SELECTOR_FIELDS[0]

    @classmethod
    def get_permisos_por_usuario(cls, user: str) -> Dict[str, Any]:
        if cls.permisos_por_usuario_func:
            return cls.permisos_por_usuario_func(user)
        return {}

    @classmethod
    async def list_articles_data(cls):
        return LinaArti.list_all(order_by=cls.DEFAULT_SORT_FIELD, fields=cls.SELECTOR_FIELDS)

    @classmethod
    async def get_article_by_id(cls, articodi: str):
        return LinaArti.row_get({ARTICLE_KEY_FIELD: articodi})

    @classmethod
    async def delete_article_from_db(cls, articodi: str):
        return LinaArti.row_delete({ARTICLE_KEY_FIELD: articodi})


# ==================== VALIDADORES ====================

class ArticuloValidador(BaseValidador):

    def normalize(self):
        self.normalized_data = {
            "articodi": str(self.original_data.get("articodi", "")).strip(),
            "artidesc": str(self.original_data.get("artidesc", "")).strip(),
            "artrcodi": self.original_data.get("artrcodi"),
            "artipmpe":  self.original_data.get("artipmpe"),
            "artiprec": self.original_data.get("artiprec"),
        }

    def validate_formal(self):
        c    = self.normalized_data.get("articodi", "")
        d    = self.normalized_data.get("artidesc", "")
        r    = self.normalized_data.get("artrcodi")
        pmp  = self.normalized_data.get("artipmpe")
        prec = self.normalized_data.get("artiprec")

        if not c:
            self.field_errors["articodi"] = "Código obligatorio"
        if not d:
            self.field_errors["artidesc"] = "Descripción obligatoria"
        elif len(d) > 40:
            self.field_errors["artidesc"] = "Máximo 40 caracteres"
        if r is None or str(r).strip() == "":
            self.field_errors["artrcodi"] = "Rubro obligatorio"
        if pmp is None or str(pmp).strip() == "":
            self.field_errors["artipmpe"] = "PMP obligatorio"
        else:
            try:
                if int(pmp) < 0:
                    self.field_errors["artipmpe"] = "PMP debe ser >= 0"
            except (ValueError, TypeError):
                self.field_errors["artipmpe"] = "PMP debe ser un número entero"
        if prec is None or str(prec).strip() == "":
            self.field_errors["artiprec"] = "Precio obligatorio"
        else:
            try:
                if float(prec) < 0:
                    self.field_errors["artiprec"] = "Precio debe ser >= 0"
            except (ValueError, TypeError):
                self.field_errors["artiprec"] = "Precio debe ser un número"

    def validate_negocio(self):
        conn = self.original_data.get("conn")
        if self.original_data.get("action") == "create":
            c = self.normalized_data.get("articodi")
            if LinaArti.row_get({ARTICLE_KEY_FIELD: c}, conn=conn):
                self.field_errors["articodi"] = f"El código {c} ya existe."
        r = self.normalized_data.get("artrcodi")
        if r and not LinaArtr.row_get({"artrcodi": r}, conn=conn):
            self.field_errors["artrcodi"] = f"El rubro {r} no existe."


class RecodeArticuloValidador(BaseValidador):
    """Validador para el cambio de código (recode) de un artículo."""

    def normalize(self):
        self.normalized_data = {
            "articodi": str(self.original_data.get("articodi", "")).strip(),
            "new_code": str(self.original_data.get("new_code", "")).strip(),
        }

    def validate_formal(self):
        old = self.normalized_data.get("articodi", "")
        new = self.normalized_data.get("new_code", "")
        if not new:
            self.field_errors["new_code"] = "El nuevo código no puede estar vacío."
            return
        if len(new) > 9:
            self.field_errors["new_code"] = "Máximo 9 caracteres."
            return
        if not old:
            self.field_errors["articodi"] = "El código actual es inválido."
            return
        if new == old:
            self.field_errors["new_code"] = "El nuevo código debe ser distinto al actual."

    def validate_negocio(self):
        if "new_code" in self.field_errors:
            return
        conn    = self.original_data.get("conn")
        new     = self.normalized_data.get("new_code")
        if LinaArti.row_get({ARTICLE_KEY_FIELD: new}, conn=conn):
            self.field_errors["new_code"] = f"El código {new} ya existe."


# ==================== FUNCIONES AUXILIARES ====================

def _article_delete_restriction_message(conn, articodi: str) -> str | None:
    parent_values = {ARTICLE_COMPANY_FIELD: ctx_empr.get(), ARTICLE_KEY_FIELD: articodi}
    for relation in LinaArti.CHILD_RELATIONS:
        has_related = LinaArti.has_children(relation, parent_values, conn=conn)
        if has_related:
            child_table = LinaArti._get_table_class(relation["table"])
            description = (getattr(child_table, "TABLE_COMMENT", "") or "").strip()
            if not description:
                description = child_table.get_table_comment(conn=conn)
            if not description:
                description = "Registros relacionados"
            return (
                f"No se puede eliminar el artículo {articodi}. "
                f"Existen registros hijos en tabla: {child_table.TABLE_NAME} ({description})."
            )
    return None


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def list_articles(request: Request):
    Lina132.set_prog_code(PROG_CODE)
    user = Lina132.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    perms = Lina132.get_permisos_por_usuario(user).get(Lina132.prog_code)
    if not perms or not perms.cons:
        raise HTTPException(403, "No permisos de consulta")

    conn     = Lina132.get_task_conn(request, readonly=True)
    articles = LinaArti.list_all(order_by=Lina132.DEFAULT_SORT_FIELD, fields=Lina132.SELECTOR_FIELDS, conn=conn)
    is_htmx  = request.headers.get("HX-Request") == "true"

    context = {
        "request":  request,
        "user":     user,
        "articles": articles,
        "perms":    perms,
    }

    if is_htmx:
        context.update({
            "list_title":   "Artículos",
            "route_new":    f"{ROUTE_BASE}/new",
            "route_list":   f"{ROUTE_BASE}/list",
            "grid_content": "lina132/grid.html",
        })
        return Lina132.templates.TemplateResponse("fragments/master_detail.html", context)
    return Lina132.templates.TemplateResponse("lina132/main.html", context)


@router.get("/list", response_class=HTMLResponse)
async def list_articles_only(request: Request, sort: str = ARTICLE_KEY_FIELD, search: str = ""):
    conn         = Lina132.get_task_conn(request, readonly=True)
    allowed_sort = set(Lina132.SELECTOR_FIELDS)
    safe_sort    = sort if sort in allowed_sort else Lina132.DEFAULT_SORT_FIELD
    search_term  = (search or "").strip()

    if search_term:
        articles = LinaArti.search_selector(search_term, safe_sort, conn=conn)
    else:
        articles = LinaArti.list_all(order_by=safe_sort, fields=Lina132.SELECTOR_FIELDS, conn=conn)

    return Lina132.templates.TemplateResponse(
        "lina132/grid.html", {"request": request, "articles": articles}
    )


@router.get("/new", response_class=HTMLResponse)
async def new_article_form(request: Request):
    conn    = Lina132.get_task_conn(request, readonly=True)
    ui_meta = Lina132.get_table_ui_metadata(LinaArti, conn=conn)
    return Lina132.templates.TemplateResponse(
        "lina132/form.html",
        {
            "request":           request,
            "article":           None,
            "artrdesc":          "",
            "action":            "create",
            "field_tooltips":    ui_meta["field_tooltips"],
            "table_description": ui_meta["table_description"],
        },
    )


@router.get("/detail/{articodi}", response_class=HTMLResponse)
async def edit_article_form(request: Request, articodi: str):
    conn    = Lina132.get_task_conn(request, readonly=True)
    article = LinaArti.row_get({ARTICLE_KEY_FIELD: articodi}, conn=conn)
    if not article:
        raise HTTPException(404, "Artículo no encontrado")
    artrcodi = article.get("artrcodi")
    artr_rec = LinaArtr.row_get({"artrcodi": artrcodi}, conn=conn) if artrcodi else None
    artrdesc = artr_rec.get("artrdesc", "") if artr_rec else ""
    ui_meta  = Lina132.get_table_ui_metadata(LinaArti, conn=conn)
    return Lina132.templates.TemplateResponse(
        "lina132/form.html",
        {
            "request":           request,
            "article":           article,
            "artrdesc":          artrdesc,
            "action":            "edit",
            "field_tooltips":    ui_meta["field_tooltips"],
            "table_description": ui_meta["table_description"],
        },
    )


@router.get("/artr/desc")
async def artr_desc(request: Request, artrcodi: str = ""):
    """Devuelve la descripción de un rubro dado su código."""
    conn = Lina132.get_task_conn(request, readonly=True)
    if not artrcodi or not artrcodi.strip():
        return JSONResponse({"artrdesc": ""})
    rec      = LinaArtr.row_get({"artrcodi": artrcodi.strip()}, conn=conn)
    artrdesc = rec.get("artrdesc", "") if rec else ""
    return JSONResponse({"artrdesc": str(artrdesc).strip()})


@router.post("/save", response_class=HTMLResponse)
async def save_article(
    request:  Request,
    articodi: str = Form(...),
    artidesc: str = Form(...),
    artrcodi: str = Form(...),
    artipmpe:  str = Form(...),
    artiprec: str = Form(...),
    action:   str = Form(...),
    tab_id:   str = Form(default="", alias="_tab"),
):
    # ---- DEBUG: mostrar datos recibidos ----
    print(f"DEBUG save_article: action={action!r} articodi={articodi!r} "
          f"artidesc={artidesc!r} artrcodi={artrcodi!r} "
          f"artipmpe={artipmpe!r} artiprec={artiprec!r} tab_id={tab_id!r}")

    conn      = Lina132.get_task_conn(request, readonly=False)
    validador = ArticuloValidador({
        "articodi": articodi,
        "artidesc": artidesc,
        "artrcodi": artrcodi,
        "artipmpe":  artipmpe,
        "artiprec": artiprec,
        "action":   action,
        "conn":     conn,
    })
    resultado = validador.validate()

    print(f"DEBUG validacion: is_valid={resultado['is_valid']} "
          f"field_errors={resultado['field_errors']} "
          f"form_errors={resultado['form_errors']}")

    if not resultado["is_valid"]:
        msg = "\n".join(list(resultado["field_errors"].values()) + resultado["form_errors"])
        return HTMLResponse(content=msg or "Datos inválidos.", status_code=409)

    nd = resultado["normalized_data"]
    try:
        if action == "create":
            insert_data = {
                ARTICLE_KEY_FIELD:     nd["articodi"],
                ARTICLE_LABEL_FIELD:   nd["artidesc"],
                "artrcodi":            nd["artrcodi"],
                "artipmpe":             int(nd["artipmpe"]),
                "artiprec":            float(nd["artiprec"]),
                ARTICLE_COMPANY_FIELD: ctx_empr.get(),
            }
            print(f"DEBUG insert_data: {insert_data}")
            got_parents = LinaArti.row_got_parents(insert_data, conn=conn)
            print(f"DEBUG row_got_parents: {got_parents}")
            if not got_parents:
                return HTMLResponse(
                    content="No existen todos los registros padres requeridos para crear el artículo.",
                    status_code=409,
                )
            ok = LinaArti.row_insert(insert_data, conn=conn)
            print(f"DEBUG row_insert result: {ok}")
        else:
            update_data = {
                ARTICLE_LABEL_FIELD: nd["artidesc"],
                "artrcodi":          nd["artrcodi"],
                "artipmpe":           int(nd["artipmpe"]),
                "artiprec":          float(nd["artiprec"]),
            }
            print(f"DEBUG update_data: {update_data}")
            ok = LinaArti.row_update(
                {ARTICLE_KEY_FIELD: nd["articodi"]},
                update_data,
                conn=conn,
            )
            print(f"DEBUG row_update result: {ok}")

        if not ok:
            return HTMLResponse(content="No se pudo guardar.", status_code=400)

    except IntegrityError as e:
        conn.rollback()
        if getattr(e, "errno", None) == 1062:
            return HTMLResponse(content=f"El código {nd['articodi']} ya existe.", status_code=409)
        return HTMLResponse(content=f"Error de integridad al guardar: {e.msg}", status_code=400)
    except Exception as e:
        conn.rollback()
        print(f"DEBUG excepcion en save: {e}")
        return HTMLResponse(content=f"Error al guardar: {e}", status_code=500)

    user = Lina132.get_current_user(request)
    if user and tab_id:
        sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina132.prog_code or PROG_CODE)
    elif conn:
        conn.commit()
    return HTMLResponse(content="Guardado exitosamente.")


@router.delete("/{articodi}/delete", response_class=HTMLResponse)
async def delete_article(request: Request, articodi: str):
    conn      = Lina132.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn      = sess_conns.get_conn(readonly=False, user_override=Lina132.get_current_user(request))
        owns_conn = True
    try:
        restriction_message = _article_delete_restriction_message(conn, articodi)
        if restriction_message:
            return HTMLResponse(content=restriction_message, status_code=409)

        ok = LinaArti.row_delete({ARTICLE_KEY_FIELD: articodi}, conn=conn)
        if not ok:
            restriction_message = _article_delete_restriction_message(conn, articodi)
            if restriction_message:
                return HTMLResponse(content=restriction_message, status_code=409)
            return HTMLResponse(
                content=f"No se pudo eliminar el artículo {articodi}. Puede tener registros relacionados.",
                status_code=400,
            )

        tab_id = Lina132.get_tab_id(request)
        user   = Lina132.get_current_user(request)
        if owns_conn:
            conn.commit()
        elif user and tab_id:
            sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina132.prog_code or PROG_CODE)

        return HTMLResponse(content="<script>document.body.dispatchEvent(new Event('refreshList'));</script> Eliminado.")

    except Exception as e:
        if owns_conn:
            conn.rollback()
        return HTMLResponse(content=f"Error al eliminar el artículo {articodi}: {e}", status_code=400)
    finally:
        if owns_conn:
            sess_conns.release_conn(conn)


@router.post("/{articodi}/recode", response_class=JSONResponse)
async def recode_article(
    request:  Request,
    articodi: str,
    new_code: str = Form(...),
    tab_id:   str = Form(default="", alias="_tab"),
):
    conn      = Lina132.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn      = sess_conns.get_conn(readonly=False, user_override=Lina132.get_current_user(request))
        owns_conn = True

    validador = RecodeArticuloValidador({"articodi": articodi, "new_code": new_code, "conn": conn})
    resultado = validador.validate()
    if not resultado["is_valid"]:
        msg = "\n".join(list(resultado["field_errors"].values()) + resultado["form_errors"])
        if owns_conn:
            sess_conns.release_conn(conn)
        return JSONResponse({"ok": False, "message": msg or "Datos inválidos."}, status_code=400)

    nd = resultado["normalized_data"]
    try:
        cur = conn.cursor()
        cur.execute(
            "UPDATE linaarti SET articodi = %s WHERE emprcodi = %s AND articodi = %s",
            (nd["new_code"], ctx_empr.get(), nd["articodi"]),
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

    user = Lina132.get_current_user(request)
    if user and tab_id and not owns_conn:
        sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=Lina132.prog_code or PROG_CODE)
    else:
        conn.commit()

    if owns_conn:
        sess_conns.release_conn(conn)

    return JSONResponse({"ok": True, "new_code": nd["new_code"], "message": "Código cambiado correctamente."})
            