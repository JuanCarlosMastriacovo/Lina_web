# CapaDAL/DbLinaSQLs - Operacion SQL pura

Este directorio centraliza scripts SQL para administrar SP, triggers y permisos.

## Politica vigente

- Para SP/triggers/permisos usar SQL puro ejecutado desde MySQL Workbench o cliente `mysql`.
- Evitar `python -> sql` para estos procesos.

## Scripts principales

1. `configurar_usuario.sql`
- Crea/actualiza usuario MySQL de app.
- Revoca privilegios previos y otorga permisos requeridos.
- Variables obligatorias al inicio del script:
  - `@DATABASE`
  - `@NOMBRE_USUARIO_A_CREAR`
  - `@PASSWORD_USUARIO_A_CREAR`

2. `apply_refresh_sp_and_trgs.sql`
- Refresca SP y triggers de seguridad:
  - `sp_sync_linasafe`
  - `sp_copy_user_rights`
  - triggers de `linauser` y `linaprog`
- Ejecuta `CALL sp_sync_linasafe()` al final.

3. `setup_audit_triggers.sql`
- Refresca triggers de auditoria para las tablas definidas.
- Crea/ejecuta `sp_setup_audit_triggers()` para generar triggers de forma dinamica.

## Orden recomendado de ejecucion

1. `configurar_usuario.sql` (si corresponde cambios de usuario/permisos)
2. `apply_refresh_sp_and_trgs.sql`
3. `setup_audit_triggers.sql`

## Ejecucion desde MySQL Workbench

1. Abrir el script `.sql`.
2. Revisar variables parametrizables al inicio.
3. Ejecutar todo el script.

## Ejecucion por consola (opcional)

```bash
mysql -u root -p -e "SOURCE CapaDAL/DbLinaSQLs/apply_refresh_sp_and_trgs.sql"
mysql -u root -p -e "SOURCE CapaDAL/DbLinaSQLs/setup_audit_triggers.sql"
```

## Nota sobre Error MySQL 1419

Si aparece:
`You do not have the SUPER privilege and binary logging is enabled`

ejecutar con usuario administrador:

```sql
SET GLOBAL log_bin_trust_function_creators = 1;
-- opcional persistente
SET PERSIST log_bin_trust_function_creators = 1;
```
