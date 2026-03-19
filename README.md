# lina_web - App web para menú LINA

Esta aplicación presenta el menú de LINA en el navegador, conectando a MySQL.

## Estructura

- `CapaUI/lina0.py`: App FastAPI + lógica de seguridad y menú
- `CapaUI/lina111.py`: Módulo de gestión de clientes
- `CapaUI/lina131.py`: Módulo de gestión de rubros
- `CapaDAL/config.py`: Configuración MySQL
- `CapaDAL/DbLinaSQLs/apply_refresh_sp_and_trgs.sql`: Refresh de SP/Triggers de sincronización LINASAFE
- `CapaDAL/DbLinaSQLs/setup_audit_triggers.sql`: Generación/aplicación de triggers de auditoría
- `CapaDAL/DbLinaSQLs/configurar_usuario.sql`: Alta/ajuste de usuario y privilegios MySQL
- `CapaDAL/DbLinaSQLs/README_SQL.md`: Guía operativa SQL pura
- `templates/`: Plantillas HTML
- `static/`: Archivos estáticos

## Requisitos

Ver requirements.txt

## Ejecutar

```bash
python -m CapaUI.lina0
o
uvicorn CapaUI.lina0:app --reload
```

## Credenciales MySQL

La app puede tomar las credenciales MySQL desde variables de entorno. Si no están definidas, usa los valores por defecto actuales de la configuración.

```powershell
$env:LINA_MYSQL_HOST = "localhost"
$env:LINA_MYSQL_USER = "literatura"
$env:LINA_MYSQL_PASSWORD = "TU_CLAVE_DE_LITERATURA"
$env:LINA_MYSQL_DATABASE = "lina"
uvicorn CapaUI.lina0:app --reload
```

## Scripts de base de datos (SQL puro)

```sql
-- Ejecutar desde MySQL Workbench:
SOURCE CapaDAL/DbLinaSQLs/configurar_usuario.sql;
SOURCE CapaDAL/DbLinaSQLs/apply_refresh_sp_and_trgs.sql;
SOURCE CapaDAL/DbLinaSQLs/setup_audit_triggers.sql;
```

Ver detalle operativo en `CapaDAL/DbLinaSQLs/README_SQL.md`.

Acceso: http://127.0.0.1:8000