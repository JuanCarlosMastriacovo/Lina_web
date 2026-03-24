"""
Clase base para todos los módulos de programa (LINA111, LINA112, etc.)
Proporciona configuración global y funciones comunes inyectadas desde lina0.py
"""

from typing import Optional, Callable, Dict, Any, Type
from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.templating import Jinja2Templates
from CapaDAL.dataconn import ctx_user, ctx_empr, sess_conns
from CapaBRL import config as lina_config


class linabase:
    """Clase base para módulos de programas con configuración global e inyección de dependencias."""
    
    # Globales compartidas (configuración estática)
    templates: Optional[Jinja2Templates] = None
    prog_code: str = ""  # Código del programa actual (LINA111, LINA112, etc.)
    permisos_por_usuario_func: Optional[Callable[[str], Dict[str, Any]]] = None
    task_conn_provider_func: Optional[Callable[[str, str, bool, str], Any]] = None
    
    # Configuración global de estilo (fuente en CapaBRL/config.py)
    DEFAULT_FONT_FAMILY         = lina_config.DEFAULT_FONT_FAMILY
    DEFAULT_FONT_SIZE           = lina_config.DEFAULT_FONT_SIZE
    DEFAULT_BG_COLOR            = lina_config.DEFAULT_BG_COLOR
    DEFAULT_MENU_BG_COLOR       = lina_config.DEFAULT_MENU_BG_COLOR
    DEFAULT_MIN_VIEWPORT_WIDTH  = lina_config.DEFAULT_MIN_VIEWPORT_WIDTH
    DEFAULT_MIN_VIEWPORT_HEIGHT = lina_config.DEFAULT_MIN_VIEWPORT_HEIGHT
    PROGRAM_MIN_VIEWPORTS: Dict[str, Dict[str, int]] = lina_config.PROGRAM_MIN_VIEWPORTS
    
    @classmethod
    def get_curr_emprcodi(cls) -> str:
        """Obtiene el código de la empresa actual del contexto de sesión."""
        return ctx_empr.get()

    @classmethod
    def get_empr_info(cls) -> tuple:
        """Retorna (empr_code, empr_name) de la empresa activa en la sesión."""
        from CapaDAL.tablebase import get_table_model
        LinaEmpr  = get_table_model("linaempr")
        empr_code = ctx_empr.get() or lina_config.DEFAULT_EMPR_CODE
        empr_rec  = LinaEmpr.row_get({"emprcodi": empr_code})
        empr_name = str(empr_rec.get("emprname") or "").strip() if empr_rec else ""
        return empr_code, empr_name
    
    @classmethod
    def set_templates(cls, tmpl: Jinja2Templates) -> None:
        """Establece el motor de plantillas Jinja2."""
        cls.templates = tmpl
    
    @classmethod
    def set_prog_code(cls, code: str) -> None:
        """Establece el código del programa actual en el contexto de la clase."""
        cls.prog_code = code
    
    @classmethod
    def set_permisos_por_usuario(cls, func: Callable[[str], Dict[str, Any]]) -> None:
        """Inyecta la función de permisos desde lina0.py."""
        cls.permisos_por_usuario_func = func

    @classmethod
    def set_task_conn_provider(cls, func: Callable[[str, str, bool, str], Any]) -> None:
        """Inyecta el proveedor de conexión transaccional por tarea/tab."""
        cls.task_conn_provider_func = func

    @staticmethod
    def get_tab_id(request: Request) -> Optional[str]:
        """Obtiene el identificador de tab desde query param o header."""
        tab_id = request.query_params.get("_tab")
        if tab_id:
            return tab_id.strip()
        header_tab = request.headers.get("X-Tab-Id")
        return header_tab.strip() if header_tab else None

    @classmethod
    def get_task_conn(cls, request: Request, readonly: bool = True):
        """Obtiene la conexión de la tarea/tab actual si está disponible."""
        if not cls.task_conn_provider_func:
            return None
        user = cls.get_current_user(request)
        tab_id = cls.get_tab_id(request)
        if not user or not tab_id:
            return None
        prog = cls.prog_code or "LINA_WEB"
        return cls.task_conn_provider_func(user, tab_id, readonly, prog)
    
    @staticmethod
    def get_current_user(request: Request) -> Optional[str]:
        """Obtiene el usuario actual del contexto de sesión."""
        return ctx_user.get()
    
    @staticmethod
    def format_prog_title(prog_code: str, prog_desc: str) -> str:
        """Formatea el título de la pestaña con progcodi (trimmed) + descripción."""
        code_trimmed = prog_code.strip() if prog_code else ""
        return f"{code_trimmed} - {prog_desc}" if code_trimmed else prog_desc

    @classmethod
    def get_program_min_viewport(cls, prog_code: Optional[str]) -> Dict[str, int]:
        """Devuelve el viewport minimo configurado para un programa; si no existe, usa el global."""
        code = (prog_code or "").strip().upper()
        if code and code in cls.PROGRAM_MIN_VIEWPORTS:
            conf = cls.PROGRAM_MIN_VIEWPORTS[code]
            return {
                "width": int(conf.get("width", cls.DEFAULT_MIN_VIEWPORT_WIDTH)),
                "height": int(conf.get("height", cls.DEFAULT_MIN_VIEWPORT_HEIGHT)),
            }
        return {
            "width": cls.DEFAULT_MIN_VIEWPORT_WIDTH,
            "height": cls.DEFAULT_MIN_VIEWPORT_HEIGHT,
        }

    @classmethod
    def get_frontend_viewport_config(cls) -> Dict[str, Any]:
        """Config para front-end: minimo por defecto y overrides por programa."""
        programs: Dict[str, Dict[str, int]] = {}
        for code, conf in cls.PROGRAM_MIN_VIEWPORTS.items():
            programs[code.upper()] = {
                "width": int(conf.get("width", cls.DEFAULT_MIN_VIEWPORT_WIDTH)),
                "height": int(conf.get("height", cls.DEFAULT_MIN_VIEWPORT_HEIGHT)),
            }

        return {
            "default": {
                "width": cls.DEFAULT_MIN_VIEWPORT_WIDTH,
                "height": cls.DEFAULT_MIN_VIEWPORT_HEIGHT,
            },
            "programs": programs,
        }

    @classmethod
    async def exec_recode_int(
        cls,
        request:             Request,
        old_code:            int,
        new_code_raw:        Any,
        table_model:         Any,
        key_field:           str,
        recode_validador_cls: type,
        prog_code:           str,
        tab_id:              str = "",
    ) -> JSONResponse:
        """
        Lógica reutilizable de recode para entidades con clave entera.
        Valida, ejecuta UPDATE (respetando emprcodi si existe) y hace commit.
        """
        from mysql.connector import IntegrityError

        conn      = cls.get_task_conn(request, readonly=False)
        owns_conn = False
        if not conn:
            conn      = sess_conns.get_conn(readonly=False, user_override=cls.get_current_user(request))
            owns_conn = True

        try:
            new_code = int(new_code_raw)
        except (TypeError, ValueError):
            new_code = None

        validador = recode_validador_cls({"old_code": old_code, "new_code": new_code, "conn": conn})
        resultado = validador.validate()
        if not resultado["is_valid"]:
            msg = "\n".join(list(resultado["field_errors"].values()) + resultado["form_errors"])
            if owns_conn:
                sess_conns.release_conn(conn)
            return JSONResponse({"ok": False, "message": msg or "Datos inválidos."}, status_code=400)

        nd            = resultado["normalized_data"]
        company_field = table_model.get_company_field()
        try:
            cur = conn.cursor()
            if company_field:
                cur.execute(
                    f"UPDATE {table_model.TABLE_NAME} SET {key_field} = %s"
                    f" WHERE {company_field} = %s AND {key_field} = %s",
                    (nd["new_code"], ctx_empr.get(), nd["old_code"]),
                )
            else:
                cur.execute(
                    f"UPDATE {table_model.TABLE_NAME} SET {key_field} = %s WHERE {key_field} = %s",
                    (nd["new_code"], nd["old_code"]),
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
            if owns_conn:
                sess_conns.release_conn(conn)
            return JSONResponse({"ok": False, "message": "No se encontró el registro."}, status_code=404)

        user = cls.get_current_user(request)
        if user and tab_id and not owns_conn:
            sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=prog_code)
        else:
            conn.commit()
        if owns_conn:
            sess_conns.release_conn(conn)

        return JSONResponse({"ok": True, "new_code": nd["new_code"], "message": "Código cambiado correctamente."})

    @staticmethod
    def get_table_ui_metadata(table_cls: Type[Any], conn=None) -> Dict[str, Any]:
        """Obtiene tooltips de columnas y descripcion de tabla desde comments de MySQL."""
        return {
            "field_tooltips": table_cls.get_column_comments(conn=conn),
            "table_description": table_cls.get_table_comment(conn=conn),
        }
