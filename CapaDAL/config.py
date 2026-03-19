import os


# Configuración MySQL para LINA_WEB.
# Permite sobreescribir credenciales desde variables de entorno.
MYSQL_CONFIG = {
    "host": os.getenv("LINA_MYSQL_HOST", "localhost"),
    "user": os.getenv("LINA_MYSQL_USER", "lina"),
    "password": os.getenv("LINA_MYSQL_PASSWORD", "Lina1234"),
    "database": os.getenv("LINA_MYSQL_DATABASE", "lina"),
    "pool_size": int(os.getenv("LINA_MYSQL_POOL_SIZE", "5")),
    "pool_name": os.getenv("LINA_MYSQL_POOL_NAME", "lina_pool"),
}
