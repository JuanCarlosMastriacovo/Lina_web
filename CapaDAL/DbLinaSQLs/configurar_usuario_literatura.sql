-- Configura usuario MySQL 'literatura' con permisos minimos CRUD sobre BD lina.
-- Ajusta los valores de host y password antes de ejecutar.

-- 1) Parametros
SET @APP_HOST = 'localhost';
SET @APP_PASSWORD = 'CAMBIAR_ESTA_CLAVE_SEGURA';

-- 2) Crear o actualizar usuario
SET @sql_create = CONCAT(
  "CREATE USER IF NOT EXISTS 'literatura'@'", @APP_HOST, "' IDENTIFIED BY '", @APP_PASSWORD, "'"
);
PREPARE stmt FROM @sql_create;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql_alter = CONCAT(
  "ALTER USER 'literatura'@'", @APP_HOST, "' IDENTIFIED BY '", @APP_PASSWORD, "' ACCOUNT UNLOCK"
);
PREPARE stmt FROM @sql_alter;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3) Limpiar privilegios previos
SET @sql_revoke = CONCAT(
  "REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'literatura'@'", @APP_HOST, "'"
);
PREPARE stmt FROM @sql_revoke;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 4) Otorgar solo CRUD sobre la BD lina
SET @sql_grant_crud = CONCAT(
  "GRANT SELECT, INSERT, UPDATE, DELETE ON lina.* TO 'literatura'@'", @APP_HOST, "'"
);
PREPARE stmt FROM @sql_grant_crud;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 5) Opcional: permitir ejecutar procedimientos almacenados en lina
-- Descomenta si tu app llama procedimientos de la BD.
SET @sql_grant_exec = CONCAT(
  "GRANT EXECUTE ON lina.* TO 'literatura'@'", @APP_HOST, "'"
);
PREPARE stmt FROM @sql_grant_exec;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 6) Endurecimiento recomendado (opcional)
-- Requiere TLS para conexiones remotas; descomenta si aplica.
-- SET @sql_require_ssl = CONCAT(
--   "ALTER USER 'literatura'@'", @APP_HOST, "' REQUIRE SSL"
-- );
-- PREPARE stmt FROM @sql_require_ssl;
-- EXECUTE stmt;
-- DEALLOCATE PREPARE stmt;

-- Limitar conexiones simultaneas del usuario.
SET @sql_limit_conn = CONCAT(
  "ALTER USER 'literatura'@'", @APP_HOST, "' WITH MAX_USER_CONNECTIONS 10"
);
PREPARE stmt FROM @sql_limit_conn;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

FLUSH PRIVILEGES;

-- Verificacion rapida
SET @sql_show_grants = CONCAT("SHOW GRANTS FOR 'literatura'@'", @APP_HOST, "'");
PREPARE stmt FROM @sql_show_grants;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
