"""
Clase base para todos los módulos de programa (LINA111, LINA112, etc.)
Proporciona configuración global y funciones comunes inyectadas desde lina0.py
"""

import json
from typing import Optional, Callable, Dict, Any, Type
from fastapi import Request
from fastapi.responses import Response
from fastapi.templating import Jinja2Templates
from CapaDAL.dataconn import ctx_user, ctx_empr
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

    @staticmethod
    def attach_msg(response: Response, text: str, level: str = "info", extra: str = "") -> Response:
        """
        BR-006: Adjunta un evento 'lina:msg' al header HX-Trigger de la respuesta.
        El front-end captura este evento y lo muestra en la barra de mensajes.

        level: 'info' | 'warn' | 'error'
        extra: texto adicional que se mostrará en el modal de detalle.
        """
        level = level.lower() if level.lower() in ("info", "warn", "error") else "info"
        payload = json.dumps({"lina:msg": {"text": text, "level": level, "extra": extra}})
        existing = response.headers.get("HX-Trigger")
        if existing:
            try:
                merged = {**json.loads(existing), **json.loads(payload)}
                payload = json.dumps(merged)
            except Exception:
                pass
        response.headers["HX-Trigger"] = payload
        return response

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

    @staticmethod
    def get_table_ui_metadata(table_cls: Type[Any], conn=None) -> Dict[str, Any]:
        """Obtiene tooltips de columnas y descripcion de tabla desde comments de MySQL."""
        return {
            "field_tooltips": table_cls.get_column_comments(conn=conn),
            "table_description": table_cls.get_table_comment(conn=conn),
        }
