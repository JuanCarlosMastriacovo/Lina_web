from __future__ import annotations

from dataclasses import dataclass, field
from datetime import date
import hashlib
import importlib
from pathlib import Path
import re
from typing import Dict, List, Optional, Any

from fastapi import FastAPI, Form, HTTPException, Request, Body
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware

from CapaDAL.dataconn import sess_conns, ctx_user, ctx_empr, ctx_date
from CapaBRL.linabase import linabase
from CapaDAL.tablebase import get_table_model

LinaUser = get_table_model("linauser")
LinaProg = get_table_model("linaprog")
LinaSafe = get_table_model("linasafe")
LinaEmpr = get_table_model("linaempr")

# Nombres de columna explícitos, validados contra metadata MySQL.
USER_COMPANY_FIELD = LinaUser.get_company_field_required()
USER_CODE_FIELD = LinaUser.require_column("usercodi")
USER_PASS_FIELD = LinaUser.require_column("userpass")

PROG_CODE_FIELD = LinaProg.require_column("progcodi")
PROG_DESC_FIELD = LinaProg.require_column("progdesc")
PROG_CALL_FIELD = LinaProg.require_column("progcall")

SAFE_USER_FIELD = LinaSafe.require_column("usercodi")
SAFE_PROG_FIELD = LinaSafe.require_column("progcodi")
SAFE_ALTA_FIELD = LinaSafe.require_column("safealta")
SAFE_BAJA_FIELD = LinaSafe.require_column("safebaja")
SAFE_MODI_FIELD = LinaSafe.require_column("safemodi")
SAFE_CONS_FIELD = LinaSafe.require_column("safecons")

EMPR_CODE_FIELD = LinaEmpr.require_column("emprcodi")
EMPR_NAME_FIELD = LinaEmpr.require_column("emprname")

# ==================== SEGURIDAD Y AUTENTICACIÓN ====================

@dataclass(frozen=True)
class SafeKey:
    user: str
    prog: str


@dataclass(frozen=True)
class Permisos:
    alta: bool
    baja: bool
    modi: bool
    cons: bool


def permisos_por_usuario(user: str) -> Dict[str, Permisos]:
    """Devuelve un diccionario PROGCODI -> Permisos para el usuario dado usando la CapaDAL."""
    try:
        rows = LinaSafe.list_all(filters={SAFE_USER_FIELD: user}, order_by=SAFE_PROG_FIELD)
        perms: Dict[str, Permisos] = {}
        for rec in rows:
            prog = str(rec.get(SAFE_PROG_FIELD) or "").strip()
            if not prog:
                continue
            alta = (str(rec.get(SAFE_ALTA_FIELD) or "").strip().upper() == "X")
            baja = (str(rec.get(SAFE_BAJA_FIELD) or "").strip().upper() == "X")
            modi = (str(rec.get(SAFE_MODI_FIELD) or "").strip().upper() == "X")
            cons = (str(rec.get(SAFE_CONS_FIELD) or "").strip().upper() == "X")
            perms[prog] = Permisos(alta=alta, baja=baja, modi=modi, cons=cons)
        return perms
    except Exception as e:
        print(f"Error cargando permisos: {e}")
        return {}


# ==================== MENÚ Y APLICACIÓN ====================


@dataclass
class MenuItem:
    code: str
    title: str
    call_type: str  # ej. "", "PRG", "py", etc.
    children: List["MenuItem"] = field(default_factory=list)
    parent: Optional["MenuItem"] = None

    @property
    def is_action(self) -> bool:
        # Es ejecutable si tiene algún call_type (no vacío)
        return bool(self.call_type.strip())


def build_menu_tree(registros: List[dict]) -> List[MenuItem]:
    items_by_code: Dict[str, MenuItem] = {}

    for rec in registros:
        code = str(rec.get(PROG_CODE_FIELD) or "").strip()
        if not code:
            continue
        title = str(rec.get(PROG_DESC_FIELD) or "").strip()
        call_type = str(rec.get(PROG_CALL_FIELD) or "").strip().upper()
        items_by_code[code] = MenuItem(code=code, title=title, call_type=call_type)

    for code in sorted(items_by_code.keys(), key=len):
        item = items_by_code[code]
        parent: Optional[MenuItem] = None
        for i in range(len(code) - 1, 0, -1):
            prefix = code[:i]
            if prefix in items_by_code:
                parent = items_by_code[prefix]
                break
        if parent:
            item.parent = parent
            parent.children.append(item)

    roots = [it for it in items_by_code.values() if it.parent is None]
    roots.sort(key=lambda x: x.code)
    for r in roots:
        r.children.sort(key=lambda x: x.code)
    return roots


def get_current_user(request: Request) -> Optional[str]:
    user = request.session.get("user_code")
    if isinstance(user, str) and user:
        return user
    return None


def get_user_by_code_case_insensitive(user_code: str) -> Dict[str, Any]:
    """Obtiene usuario por código ignorando mayúsculas/minúsculas."""
    clean_code = (user_code or "").strip()
    if not clean_code:
        return {}
    return LinaUser.row_get_case_insensitive(USER_CODE_FIELD, clean_code)


app = FastAPI(title="LINA Web")

@app.middleware("http")
async def session_context_middleware(request: Request, call_next):
    """Middleware para inyectar el usuario, empresa y fecha de la sesión en el contexto global."""
    try:
        user = request.session.get("user_code")
        empr = request.session.get("empr_code", "01")
        session_date = request.session.get("session_date", "")
    except Exception:
        # Si la sesión no está lista todavía
        user = None
        empr = "01"
        session_date = ""

    token_user = ctx_user.set(user)
    token_empr = ctx_empr.set(empr)
    token_date = ctx_date.set(session_date or date.today().isoformat())
    try:
        response = await call_next(request)
        return response
    finally:
        ctx_user.reset(token_user)
        ctx_empr.reset(token_empr)
        ctx_date.reset(token_date)

# El SessionMiddleware debe estar ANTES que el middleware de contexto (en ejecución)
# En FastAPI/Starlette, los middlewares se ejecutan en el orden inverso al que se añaden.
# Por lo tanto, lo añadimos DESPUÉS del middleware de contexto para que sea el primero en procesar la petición.
app.add_middleware(SessionMiddleware, secret_key="lina-secret-key-not-final", max_age=None)

templates = Jinja2Templates(directory=str(Path(__file__).parent.parent / "templates"))
static_dir = Path(__file__).parent.parent / "static"
static_dir.mkdir(parents=True, exist_ok=True)
app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")

# --- Globals para el Menú ---

def get_menu_roots_global():
    """Carga el árbol de menú desde la base de datos."""
    try:
        registros = LinaProg.list_all(order_by=PROG_CODE_FIELD)
        return build_menu_tree(registros)
    except Exception as e:
        print(f"Error cargando menú: {e}")
        return []

templates.env.globals["get_menu_roots"] = get_menu_roots_global

# --- Días de la semana en español (abreviados 3 letras) ---
_DIAS_ES = ["LUN", "MAR", "MIÉ", "JUE", "VIE", "SÁB", "DOM"]

def format_fecha_sesion(fecha_iso: str) -> str:
    """Formatea 'YYYY-MM-DD' a 'LUN 16/03/2026' en español."""
    try:
        d = date.fromisoformat(fecha_iso)
        dia = _DIAS_ES[d.weekday()]
        return f"{dia} {d.day:02d}/{d.month:02d}/{d.year}"
    except Exception:
        return fecha_iso

def get_empr_info_global() -> dict:
    """Devuelve código y nombre de la empresa activa (vía ctx_empr)."""
    try:
        empr_code = ctx_empr.get()
        rec = LinaEmpr.row_get({EMPR_CODE_FIELD: empr_code})
        if rec:
            return {
                "code": str(rec.get(EMPR_CODE_FIELD) or "").strip(),
                "name": str(rec.get(EMPR_NAME_FIELD) or "").strip(),
            }
    except Exception:
        pass
    return {"code": ctx_empr.get(), "name": ""}


def get_empr_options_global() -> List[dict]:
    """Devuelve la lista de empresas disponibles para la sesión."""
    try:
        rows = LinaEmpr.list_all(order_by=EMPR_CODE_FIELD)
        options: List[dict] = []
        for rec in rows:
            code = str(rec.get(EMPR_CODE_FIELD) or "").strip()
            name = str(rec.get(EMPR_NAME_FIELD) or "").strip()
            if not code:
                continue
            options.append({"code": code, "name": name})
        return options
    except Exception:
        return []

def get_session_date_global() -> str:
    """Devuelve la fecha de sesión formateada en español."""
    return format_fecha_sesion(ctx_date.get() or date.today().isoformat())


def get_session_date_iso_global() -> str:
    """Devuelve la fecha de sesión en formato ISO (YYYY-MM-DD)."""
    return ctx_date.get() or date.today().isoformat()

templates.env.globals["get_empr_info"] = get_empr_info_global
templates.env.globals["get_empr_options"] = get_empr_options_global
templates.env.globals["get_session_date"] = get_session_date_global
templates.env.globals["get_session_date_iso"] = get_session_date_iso_global

def parse_hotkey(title: str):
    """Extrae la hotkey (carácter tras \\<) y formatea el título con <u>."""
    if "\\<" in title:
        parts = title.split("\\<", 1)
        if len(parts[1]) > 0:
            hk = parts[1][0]
            rest = parts[1][1:]
            # Retornamos la hotkey (en minúsculas para comparar) y el HTML formateado
            return hk.lower(), f"{parts[0]}<u>{hk}</u>{rest}"
    return None, title

templates.env.globals["parse_hotkey"] = parse_hotkey
templates.env.globals["MIN_VIEWPORT_CONFIG"] = linabase.get_frontend_viewport_config()

# Inicializar configuración global (sin routers aún)
linabase.set_templates(templates)


def task_conn_provider(user: str, tab_id: str, readonly: bool, prog: str):
    """Proveedor de conexión transaccional por tab para linabase."""
    return sess_conns.get_task_conn(task_id=tab_id, user=user, prog=prog)


linabase.set_task_conn_provider(task_conn_provider)

def discover_program_modules() -> Dict[str, Dict[str, str]]:
    """Descubre módulos CapaUI/linaNNN.py y retorna su configuración de enrutamiento."""
    modules: Dict[str, Dict[str, str]] = {}
    ui_dir = Path(__file__).parent
    for file_path in sorted(ui_dir.glob("lina[0-9][0-9][0-9].py")):
        module_name = file_path.stem.lower()
        module_path = f"CapaUI.{module_name}"
        try:
            module = importlib.import_module(module_path)
            router = getattr(module, "router", None)
            if router is None:
                continue

            prog_code = str(getattr(module, "PROG_CODE", module_name.upper()) or "").strip().upper()
            if not prog_code:
                continue

            route = str(getattr(module, "ROUTE_BASE", f"/{module_name}") or "").strip()
            if not route:
                route = f"/{module_name}"
            if not route.startswith("/"):
                route = f"/{route}"

            key = prog_code.lower()
            modules[key] = {
                "route": route,
                "module": module_name,
                "prog_code": prog_code,
            }
        except Exception as e:
            print(f"Error cargando módulo {module_path}: {e}")
    return modules


def register_program_routers(app_instance: FastAPI, modules: Dict[str, Dict[str, str]]) -> None:
    """Incluye routers descubiertos dinámicamente en la aplicación."""
    for key, config in modules.items():
        module_path = f"CapaUI.{config['module']}"
        try:
            module = importlib.import_module(module_path)
            router = getattr(module, "router", None)
            if router is None:
                continue
            app_instance.include_router(router, prefix=config["route"], tags=[key])
        except Exception as e:
            print(f"Error registrando router {module_path}: {e}")


PROGRAM_MODULES = discover_program_modules()

# Pasar PROGRAM_MODULES a las plantillas para que navbar pueda usarlo
templates.env.globals["PROGRAM_MODULES"] = PROGRAM_MODULES

# Cargar e incluir routers de módulos disponibles
register_program_routers(app, PROGRAM_MODULES)

# Inyectar funciones de seguridad en los módulos de programas
linabase.set_permisos_por_usuario(permisos_por_usuario)


@app.get("/login", response_class=HTMLResponse)
async def login_form(request: Request) -> HTMLResponse:
    if get_current_user(request):
        return RedirectResponse(url="/", status_code=302) # type: ignore
    response = templates.TemplateResponse(
        "login.html",
        {"request": request, "error": None},
    )
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    return response


@app.post("/login", response_class=HTMLResponse)
async def login_submit(
    request: Request,
    user_code: str = Form(""),
    user_pass: str = Form(""),
    login_user_code: str = Form(""),
    login_user_pass: str = Form(""),
) -> HTMLResponse:
    submitted_user_code = (login_user_code or user_code or "").strip()
    submitted_user_pass = (login_user_pass or user_pass or "").strip()

    def login_error_response(message: str, status_code: int = 400) -> HTMLResponse:
        response = templates.TemplateResponse(
            "login.html",
            {
                "request": request,
                "error": message,
                "login_user_code": submitted_user_code,
            },
            status_code=status_code,
        )
        response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "0"
        return response

    if not submitted_user_code:
        return login_error_response("Debe ingresar el código de usuario.")

    if len(submitted_user_code) < 8 or len(submitted_user_code) > 32:
        return login_error_response("El código de usuario debe tener entre 8 y 32 caracteres.")

    # Buscar solo el usuario que intenta ingresar (más eficiente)
    user_rec = get_user_by_code_case_insensitive(submitted_user_code)
    
    if not user_rec:
        return login_error_response("Usuario no encontrado (se ignoran mayúsculas/minúsculas).")

    stored_pass_raw = str(user_rec.get(USER_PASS_FIELD) or "")
    stored_pass = stored_pass_raw.rstrip()
    provided_pass = submitted_user_pass.rstrip()

    if len(stored_pass) < 8:
        return login_error_response("La contraseña almacenada no cumple la política vigente (mínimo 8).")

    if len(provided_pass) < 8:
        return login_error_response("La contraseña debe tener al menos 8 caracteres.")

    # Compatibilidad: si userpass ya está en SHA-256 (hex), comparamos contra hash del input.
    # Si no, comparamos en texto plano legacy (transición).
    is_sha256_hex = bool(re.fullmatch(r"[0-9a-fA-F]{64}", stored_pass))
    provided_hash = hashlib.sha256(provided_pass.encode("utf-8")).hexdigest().upper()
    valid_password = (provided_hash == stored_pass.upper()) if is_sha256_hex else (provided_pass == stored_pass)

    if not provided_pass or not valid_password:
        return login_error_response("Contraseña inválida.")

    final_user_code = str(user_rec[USER_CODE_FIELD]).strip()
    user_company_code = str(user_rec.get(USER_COMPANY_FIELD) or "").strip()
    if not user_company_code:
        # Fallback de compatibilidad: si el usuario no trae empresa, tomar la primera disponible.
        empr_rows = LinaEmpr.list_all(order_by=EMPR_CODE_FIELD, fields=[EMPR_CODE_FIELD])
        if empr_rows:
            user_company_code = str(empr_rows[0].get(EMPR_CODE_FIELD) or "").strip()
    if not user_company_code:
        user_company_code = "01"

    request.session["user_code"] = final_user_code
    request.session["empr_code"] = user_company_code
    request.session["session_date"] = date.today().isoformat()
    
    return RedirectResponse(url="/", status_code=302) # type: ignore


@app.get("/logout")
async def logout(request: Request) -> RedirectResponse:
    user = get_current_user(request)
    if user:
        sess_conns.close_all_task_conns(user=user, commit=False)
    request.session.clear()
    response = RedirectResponse(url="/login", status_code=302)
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    return response


def _get_tab_states(request: Request) -> Dict[str, dict]:
    states = request.session.get("tab_states")
    if isinstance(states, dict):
        return states
    return {}


def _save_tab_states(request: Request, states: Dict[str, dict]) -> None:
    request.session["tab_states"] = states


@app.post("/api/tabs/open")
async def tab_open(
    request: Request,
    payload: dict = Body(...),
) -> JSONResponse:
    user = get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    tab_id = str(payload.get("tabId") or "").strip()
    prog_code = str(payload.get("progCode") or "LINA_WEB").strip().upper()
    readonly = bool(payload.get("readonly", True))
    if not tab_id:
        return JSONResponse({"ok": False, "error": "tabId requerido"}, status_code=400)

    sess_conns.start_task_conn(task_id=tab_id, user=user, prog=prog_code)
    states = _get_tab_states(request)
    states[tab_id] = {
        "prog": prog_code,
        "readonly": readonly,
    }
    _save_tab_states(request, states)
    return JSONResponse({"ok": True, "tabId": tab_id, "readonly": readonly})


@app.post("/api/tabs/mark-write")
async def tab_mark_write(
    request: Request,
    payload: dict = Body(...),
) -> JSONResponse:
    user = get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    tab_id = str(payload.get("tabId") or "").strip()
    if not tab_id:
        return JSONResponse({"ok": False, "error": "tabId requerido"}, status_code=400)

    states = _get_tab_states(request)
    state = states.get(tab_id)
    if state:
        state["readonly"] = False
        states[tab_id] = state
        _save_tab_states(request, states)

    return JSONResponse({"ok": True, "tabId": tab_id, "readonly": False})


@app.post("/api/tabs/close")
async def tab_close(
    request: Request,
    payload: dict = Body(...),
) -> JSONResponse:
    user = get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    tab_id = str(payload.get("tabId") or "").strip()
    commit = bool(payload.get("commit", False))
    if not tab_id:
        return JSONResponse({"ok": False, "error": "tabId requerido"}, status_code=400)

    closed = sess_conns.close_task_conn(task_id=tab_id, user=user, commit=commit)

    states = _get_tab_states(request)
    states.pop(tab_id, None)
    _save_tab_states(request, states)

    return JSONResponse({"ok": True, "tabId": tab_id, "closed": closed, "commit": commit})


@app.post("/api/tabs/close-all")
async def tab_close_all(
    request: Request,
    payload: dict = Body(default={}),
) -> JSONResponse:
    user = get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    tab_entries = payload.get("tabs") if isinstance(payload, dict) else None
    if not isinstance(tab_entries, list):
        tab_entries = []

    closed_items = []
    seen_ids = set()

    for item in tab_entries:
        if not isinstance(item, dict):
            continue
        tab_id = str(item.get("tabId") or "").strip()
        if not tab_id or tab_id in seen_ids:
            continue
        seen_ids.add(tab_id)
        commit = bool(item.get("commit", False))
        closed = sess_conns.close_task_conn(task_id=tab_id, user=user, commit=commit)
        closed_items.append({"tabId": tab_id, "closed": closed, "commit": commit})

    states = _get_tab_states(request)
    for tab_id in seen_ids:
        states.pop(tab_id, None)
    _save_tab_states(request, states)

    return JSONResponse({"ok": True, "closed": closed_items})


@app.post("/api/session/date")
async def set_session_date(
    request: Request,
    payload: dict = Body(...),
) -> JSONResponse:
    user = get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    raw_date = str(payload.get("session_date") or "").strip() if isinstance(payload, dict) else ""
    if not raw_date:
        return JSONResponse({"ok": False, "error": "Fecha de sesión requerida"}, status_code=400)

    try:
        session_date = date.fromisoformat(raw_date).isoformat()
    except ValueError:
        return JSONResponse({"ok": False, "error": "Fecha de sesión inválida"}, status_code=400)

    request.session["session_date"] = session_date
    return JSONResponse(
        {
            "ok": True,
            "session_date": session_date,
            "session_date_display": format_fecha_sesion(session_date),
        }
    )


@app.post("/api/session/company")
async def set_session_company(
    request: Request,
    payload: dict = Body(...),
) -> JSONResponse:
    user = get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    company_code = str(payload.get("empr_code") or "").strip() if isinstance(payload, dict) else ""
    if not company_code:
        return JSONResponse({"ok": False, "error": "Empresa requerida"}, status_code=400)

    rec = LinaEmpr.row_get({EMPR_CODE_FIELD: company_code})
    if not rec:
        return JSONResponse({"ok": False, "error": "Empresa inválida"}, status_code=400)

    final_code = str(rec.get(EMPR_CODE_FIELD) or "").strip()
    final_name = str(rec.get(EMPR_NAME_FIELD) or "").strip()
    request.session["empr_code"] = final_code
    return JSONResponse(
        {
            "ok": True,
            "empr_code": final_code,
            "empr_name": final_name,
            "empr_display": f"{final_code} · {final_name}" if final_name else final_code,
        }
    )


@app.get("/", response_class=HTMLResponse)
async def home(request: Request) -> HTMLResponse:
    user = get_current_user(request)
    if not user:
        return RedirectResponse(url="/login", status_code=302)# type: ignore

    return templates.TemplateResponse(
        "menu.html",
        {
            "request": request,
            "user": user,
        },
    )


@app.get("/prog/{code}", response_class=HTMLResponse)
async def ejecutar_programa(request: Request, code: str) -> HTMLResponse:
    user = get_current_user(request)
    if not user:
        return RedirectResponse(url="/login", status_code=302) # type: ignore

    # Buscar el registro de programa usando CapaDAL
    rec = LinaProg.row_get({PROG_CODE_FIELD: code.upper()})

    if not rec:
        raise HTTPException(status_code=404, detail="Programa no encontrado en LINAPROG")

    call_type = str(rec.get(PROG_CALL_FIELD) or "").strip().upper() # type: ignore
    desc = str(rec.get(PROG_DESC_FIELD) or "").strip() # type: ignore

    # Detectar si viene de HTMX (para cargar en tabs)
    is_htmx = request.headers.get("HX-Request") == "true"
    
    if not call_type:
        # Nodo de menú sin acción: lo tratamos como no ejecutable
        context = {
            "request": request,
            "user": user,
            "code": code,
            "desc": desc,
            "permisos": None,
            "error": "Esta opción es solo un nodo de menú y no es ejecutable.",
        }
        if is_htmx:
            return templates.TemplateResponse("fragments/program_error.html", context)
        return templates.TemplateResponse("program.html", context)

    # Revisar permisos en LINASAFE, pero sin ocultar el menú:
    perms_por_prog: Dict[str, Permisos] = permisos_por_usuario(user)
    permisos = perms_por_prog.get(code.upper())

    if not permisos or not permisos.cons:
        context = {
            "request": request,
            "user": user,
            "code": code,
            "desc": desc,
            "permisos": permisos,
            "error": "No tiene permiso de consulta (SAFECONS) para esta opción.",
        }
        if is_htmx:
            return templates.TemplateResponse("fragments/program_error.html", context)
        return templates.TemplateResponse(
            "program.html",
            context,
            status_code=403,
        )

    # Verificar si el programa está en el mapeo de módulos ejecutables
    prog_lower = code.lower()
    if prog_lower in PROGRAM_MODULES:
        config = PROGRAM_MODULES[prog_lower]
        # Establecer el código del programa actual
        linabase.set_prog_code(code.upper())
        # Redirigir a la ruta definida para este programa (agregar / si es necesario)
        route = config['route']
        if not route.endswith('/'):
            route += '/'
        if is_htmx:
            # Para HTMX, no redirigir sino hacer HTMX swap directo
            return RedirectResponse(url=route, status_code=302)
        return RedirectResponse(url=route, status_code=302)

    # Si no está en el mapeo, es solo un nodo de menú informativo
    context = {
        "request": request,
        "user": user,
        "code": code,
        "desc": desc,
        "permisos": permisos,
        "error": "Este programa no tiene un módulo asociado.",
    }
    if is_htmx:
        return templates.TemplateResponse("fragments/program_error.html", context)
    return templates.TemplateResponse("program.html", context)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
