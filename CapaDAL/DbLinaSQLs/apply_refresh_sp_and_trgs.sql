-- ============================================================
-- REFRESH DE STORED PROCEDURES Y TRIGGERS (SQL PURO)
-- Ejecutar completo desde MySQL Workbench sobre la BD lina
-- ============================================================

USE lina;

-- ------------------------------------------------------------
-- Nota sobre MySQL Error 1419 (si aparece):
-- You do not have the SUPER privilege and binary logging is enabled.
-- Debe habilitarse (con usuario admin):
--   SET GLOBAL log_bin_trust_function_creators = 1;
-- Opcional persistente:
--   SET PERSIST log_bin_trust_function_creators = 1;
-- ------------------------------------------------------------

-- Limpiar objetos previos
DROP TRIGGER IF EXISTS tr_linauser_insert;
DROP TRIGGER IF EXISTS tr_linauser_delete;
DROP TRIGGER IF EXISTS tr_linaprog_insert;
DROP TRIGGER IF EXISTS tr_linaprog_delete;
DROP TRIGGER IF EXISTS tr_linaprog_update;

DROP PROCEDURE IF EXISTS sp_copy_user_rights;
DROP PROCEDURE IF EXISTS sp_sync_linasafe;

DELIMITER $$

CREATE PROCEDURE sp_sync_linasafe()
    MODIFIES SQL DATA
BEGIN
    -- 1) Insertar faltantes en linasafe para cada usuario-programa ejecutable
    INSERT INTO linasafe (
        emprcodi, usercodi, progcodi,
        safealta, safebaja, safemodi, safecons,
        user, date, time, oper, prog, wstn, nume
    )
    SELECT
        u.emprcodi, u.usercodi, p.progcodi,
        '', '', '', '',
        'SYSTEM',
        DATE_FORMAT(NOW(), '%Y%m%d'),
        DATE_FORMAT(NOW(), '%H:%i:%s'),
        'I', 'SP_SYNC', '00', 0
    FROM linauser u
    CROSS JOIN linaprog p
    LEFT JOIN linasafe s
      ON u.emprcodi = s.emprcodi
     AND u.usercodi = s.usercodi
     AND p.progcodi = s.progcodi
    WHERE IFNULL(s.usercodi, '') = ''
      AND TRIM(IFNULL(p.progcall, '')) <> '';

    -- 2) Eliminar registros huérfanos o de programas no ejecutables
    DELETE s
      FROM linasafe s
      LEFT JOIN linauser u
        ON s.emprcodi = u.emprcodi
       AND s.usercodi = u.usercodi
      LEFT JOIN linaprog p
        ON s.progcodi = p.progcodi
    WHERE IFNULL(u.usercodi, '') = ''
       OR IFNULL(p.progcodi, '') = ''
       OR TRIM(IFNULL(p.progcall, '')) = '';
END$$

CREATE PROCEDURE sp_copy_user_rights(
    IN p_source_emprcodi VARCHAR(8)  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_source_usercodi VARCHAR(64) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_target_emprcodi VARCHAR(8)  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_target_usercodi VARCHAR(64) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
)
    MODIFIES SQL DATA
BEGIN
    DECLARE v_source_exists INT DEFAULT 0;
    DECLARE v_target_exists INT DEFAULT 0;

    SELECT COUNT(*)
      INTO v_source_exists
      FROM linauser
     WHERE emprcodi = p_source_emprcodi
       AND usercodi = p_source_usercodi;

    IF v_source_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sp_copy_user_rights: usuario origen no existe.';
    END IF;

    SELECT COUNT(*)
      INTO v_target_exists
      FROM linauser
     WHERE emprcodi = p_target_emprcodi
       AND usercodi = p_target_usercodi;

    IF v_target_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sp_copy_user_rights: usuario destino no existe.';
    END IF;

    -- Asegura combinaciones vigentes antes de copiar permisos
    CALL sp_sync_linasafe();

    UPDATE linasafe t
    JOIN linasafe s
      ON s.emprcodi = p_source_emprcodi
     AND s.usercodi = p_source_usercodi
     AND s.progcodi = t.progcodi
       SET t.safealta = s.safealta,
           t.safebaja = s.safebaja,
           t.safemodi = s.safemodi,
           t.safecons = s.safecons,
           t.user = 'SYSTEM',
           t.date = DATE_FORMAT(NOW(), '%Y%m%d'),
           t.time = DATE_FORMAT(NOW(), '%H:%i:%s'),
           t.oper = 'U',
           t.prog = 'SP_COPY_RIGHTS',
           t.wstn = '00',
           t.nume = 0
     WHERE t.emprcodi = p_target_emprcodi
       AND t.usercodi = p_target_usercodi;
END$$

CREATE TRIGGER tr_linauser_insert
AFTER INSERT ON linauser
FOR EACH ROW
BEGIN
    CALL sp_sync_linasafe();
END$$

CREATE TRIGGER tr_linauser_delete
AFTER DELETE ON linauser
FOR EACH ROW
BEGIN
    CALL sp_sync_linasafe();
END$$

CREATE TRIGGER tr_linaprog_insert
AFTER INSERT ON linaprog
FOR EACH ROW
BEGIN
    CALL sp_sync_linasafe();
END$$

CREATE TRIGGER tr_linaprog_delete
AFTER DELETE ON linaprog
FOR EACH ROW
BEGIN
    CALL sp_sync_linasafe();
END$$

CREATE TRIGGER tr_linaprog_update
AFTER UPDATE ON linaprog
FOR EACH ROW
BEGIN
    IF OLD.progcall <> NEW.progcall THEN
        CALL sp_sync_linasafe();
    END IF;
END$$

DELIMITER ;

-- Sync inicial
CALL sp_sync_linasafe();

-- Verificación rápida
SHOW PROCEDURE STATUS WHERE Db = DATABASE() AND Name IN ('sp_sync_linasafe', 'sp_copy_user_rights');
SHOW TRIGGERS LIKE 'linauser';
SHOW TRIGGERS LIKE 'linaprog';

-- Ejemplo de uso de copia de permisos:
-- CALL sp_copy_user_rights('01', 'USU_ORIGEN', '01', 'USU_DESTINO');
