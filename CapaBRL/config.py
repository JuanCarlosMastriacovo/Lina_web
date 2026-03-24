import os

# ==================== BASE DE DATOS ====================

MYSQL_CONFIG = {
    "host":      os.getenv("LINA_MYSQL_HOST",      "localhost"),
    "user":      os.getenv("LINA_MYSQL_USER",      "lina"),
    "password":  os.getenv("LINA_MYSQL_PASSWORD",  "Lina1234"),
    "database":  os.getenv("LINA_MYSQL_DATABASE",  "lina"),
    "pool_size": int(os.getenv("LINA_MYSQL_POOL_SIZE", "5")),
    "pool_name": os.getenv("LINA_MYSQL_POOL_NAME", "lina_pool"),
}

APP_CONFIG = {
    "app_name":        "LINA_WEB",
    "app_description": "Literatura N.A.",
    "version":         "1.0.0",
}

DEFAULT_EMPR_CODE = "01"

# ==================== CONSTANTES DE NEGOCIO ====================

CODM_REMI   = "REMI"   # Código de movimiento: Remitos de venta
CODM_RECI   = "RECI"   # Código de movimiento: Recibos de cobro
CLIE_AJUSTE = 9000     # Cliente especial para ajustes de stock (precio unitario = 0)

# Límites operativos
MAX_LINEAS_REMITO = 40   # Máximo de renglones en un remito de venta
SELECTOR_MAX_ROWS = 200  # Máximo de filas devueltas por el selector modal

# Formato de numeración de comprobantes (f"{nro:{FMT_NROCOMP}}")
FMT_NROCOMP = "06d"

# Longitudes de campo (deben coincidir con el esquema de la BD)
LEN_TEXTO_LARGO = 40   # fvheobse, fvdedesc, codedesc, etc.
LEN_CONC_CAJA   = 30   # cajaconc / bancconc

# ==================== ESTILO GLOBAL ====================

DEFAULT_FONT_FAMILY = "Microsoft Sans Serif, sans-serif"
DEFAULT_FONT_SIZE   = "8.25pt"
DEFAULT_BG_COLOR    = "cornsilk"
DEFAULT_MENU_BG_COLOR = "#87CEEB"  # Sky Blue

# Viewport mínimo recomendado para mostrar la UI completa sin recortes.
DEFAULT_MIN_VIEWPORT_WIDTH  = 1120
DEFAULT_MIN_VIEWPORT_HEIGHT = 620

# Viewport mínimo por programa (clave en mayúsculas).
PROGRAM_MIN_VIEWPORTS: dict = {
    "LINA111": {"width": 1120, "height": 620},
    "LINA131": {"width": 1120, "height": 620},
    "LINA132": {"width": 1120, "height": 620},
    "LINA21":  {"width": 1120, "height": 660},
}
