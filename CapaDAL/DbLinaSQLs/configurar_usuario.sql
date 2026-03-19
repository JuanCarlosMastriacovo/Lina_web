-- ============================================================
-- CONFIGURAR USUARIO MYSQL PARA LA BD LINA
-- ============================================================
-- Uso previsto:
-- 1. Abrir este archivo en MySQL Workbench.
-- 2. Editar las variables de la seccion CONFIGURACION OBLIGATORIA.
-- 3. Ejecutar todo el script.
--
-- Este script:
-- - crea o actualiza un usuario MySQL
-- - revoca privilegios previos
-- - otorga solo permisos CRUD sobre una base de datos
-- - muestra los GRANTS finales para verificacion
--
-- Nota:
-- - El script esta preparado para ejecutarse desde la consola SQL de Workbench.
-- - No requiere Python.
-- ============================================================

-- ============================================================
-- CONFIGURACION OBLIGATORIA: EDITAR ANTES DE EJECUTAR
-- ============================================================
SET @DATABASE = 'lina';
SET @NOMBRE_USUARIO_A_CREAR = 'literatura';
SET @PASSWORD_USUARIO_A_CREAR = 'Lina1234';

-- ============================================================
-- CONFIGURACION OPCIONAL
-- ============================================================
-- Host desde el que podra conectarse el usuario.
-- Usa 'localhost' si la app y MySQL corren en la misma maquina.
SET @HOST_PERMITIDO = 'localhost';
-- Limite de conexiones simultaneas para el usuario.
SET @MAX_USER_CONNECTIONS = 20;

-- ============================================================
-- CREAR O ACTUALIZAR USUARIO
-- ============================================================
SET @sql_create = CONCAT(
  "CREATE USER IF NOT EXISTS '", @NOMBRE_USUARIO_A_CREAR, "'@'", @HOST_PERMITIDO,
  "' IDENTIFIED BY '", @PASSWORD_USUARIO_A_CREAR, "'"
);
PREPARE stmt FROM @sql_create;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql_alter = CONCAT(
  "ALTER USER '", @NOMBRE_USUARIO_A_CREAR, "'@'", @HOST_PERMITIDO,
  "' IDENTIFIED BY '", @PASSWORD_USUARIO_A_CREAR, "' ACCOUNT UNLOCK"
);
PREPARE stmt FROM @sql_alter;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- LIMPIAR PRIVILEGIOS PREVIOS
-- ============================================================
SET @sql_revoke = CONCAT(
  "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '", @NOMBRE_USUARIO_A_CREAR,
  "'@'", @HOST_PERMITIDO, "'"
);
PREPARE stmt FROM @sql_revoke;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- OTORGAR PERMISOS CRUD + SHOW VIEW + TEMP TABLES + LOCK TABLES
-- ============================================================
SET @sql_grant_crud = CONCAT(
  "GRANT SELECT, INSERT, UPDATE, DELETE, SHOW VIEW, CREATE TEMPORARY TABLES, LOCK TABLES ON ", @DATABASE,
  ".* TO '", @NOMBRE_USUARIO_A_CREAR, "'@'", @HOST_PERMITIDO, "'"
);
PREPARE stmt FROM @sql_grant_crud;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- OPCIONAL: EJECUTAR PROCEDIMIENTOS ALMACENADOS
-- ============================================================
-- No descomentar para el uso CRUD normal de la app.
-- Solo usar si tambien necesitas ejecutar scripts de mantenimiento.
--
-- SET @sql_grant_exec = CONCAT(
--    "GRANT EXECUTE ON ", @DATABASE,
--    ".* TO '", @NOMBRE_USUARIO_A_CREAR, "'@'", @HOST_PERMITIDO, "'"
--  );
-- PREPARE stmt FROM @sql_grant_exec;
-- EXECUTE stmt;
-- DEALLOCATE PREPARE stmt;

-- ============================================================
-- LIMITAR CONEXIONES
-- ============================================================
SET @sql_limit_conn = CONCAT(
  "ALTER USER '", @NOMBRE_USUARIO_A_CREAR, "'@'", @HOST_PERMITIDO,
  "' WITH MAX_USER_CONNECTIONS ", @MAX_USER_CONNECTIONS
);
PREPARE stmt FROM @sql_limit_conn;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

FLUSH PRIVILEGES;

-- ============================================================
-- VERIFICACION FINAL
-- ============================================================
SET @sql_show_grants = CONCAT(
  "SHOW GRANTS FOR '", @NOMBRE_USUARIO_A_CREAR, "'@'", @HOST_PERMITIDO, "'"
);
PREPARE stmt FROM @sql_show_grants;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
