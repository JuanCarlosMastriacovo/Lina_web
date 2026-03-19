-- ============================================================
-- SETUP AUDIT TRIGGERS (SQL PURO)
-- Ejecutar completo desde MySQL Workbench sobre la BD lina
-- ============================================================

USE lina;

-- Nota sobre MySQL Error 1419 (si aparece):
-- You do not have the SUPER privilege and binary logging is enabled.
-- Debe habilitarse (con usuario admin):
--   SET GLOBAL log_bin_trust_function_creators = 1;
-- Opcional persistente:
--   SET PERSIST log_bin_trust_function_creators = 1;

DROP PROCEDURE IF EXISTS sp_setup_audit_triggers;

DELIMITER $$

CREATE PROCEDURE sp_setup_audit_triggers()
    MODIFIES SQL DATA
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_table VARCHAR(64);

    DECLARE cur_tables CURSOR FOR
        SELECT table_name
        FROM (
            SELECT 'linaarti' AS table_name UNION ALL
            SELECT 'linaartr' UNION ALL
            SELECT 'linabanc' UNION ALL
            SELECT 'linacaja' UNION ALL
            SELECT 'linaclie' UNION ALL
            SELECT 'linacode' UNION ALL
            SELECT 'linacodm' UNION ALL
            SELECT 'linacohe' UNION ALL
            SELECT 'linactcl' UNION ALL
            SELECT 'linactpr' UNION ALL
            SELECT 'linaempr' UNION ALL
            SELECT 'linafcde' UNION ALL
            SELECT 'linafche' UNION ALL
            SELECT 'linafvde' UNION ALL
            SELECT 'linafvhe' UNION ALL
            SELECT 'linapade' UNION ALL
            SELECT 'linapahe' UNION ALL
            SELECT 'linaprog' UNION ALL
            SELECT 'linaprov' UNION ALL
            SELECT 'linasafe' UNION ALL
            SELECT 'linauser'
        ) t;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur_tables;

    read_loop: LOOP
        FETCH cur_tables INTO v_table;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        SET @sql_drop_insert = CONCAT('DROP TRIGGER IF EXISTS tr_', v_table, '_audit_insert');
        PREPARE stmt FROM @sql_drop_insert;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @sql_drop_update = CONCAT('DROP TRIGGER IF EXISTS tr_', v_table, '_audit_update');
        PREPARE stmt FROM @sql_drop_update;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @sql_create_insert = CONCAT(
            'CREATE TRIGGER tr_', v_table, '_audit_insert BEFORE INSERT ON ', v_table,
            ' FOR EACH ROW SET ',
            'NEW.user = IFNULL(@lina_user, ''SYSTEM''), ',
            'NEW.date = DATE_FORMAT(NOW(), ''%Y%m%d''), ',
            'NEW.time = DATE_FORMAT(NOW(), ''%H:%i:%s''), ',
            'NEW.oper = ''I'', ',
            'NEW.prog = IFNULL(@lina_prog, ''UNKNOWN''), ',
            'NEW.wstn = ''00'', ',
            'NEW.nume = 0'
        );
        PREPARE stmt FROM @sql_create_insert;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @sql_create_update = CONCAT(
            'CREATE TRIGGER tr_', v_table, '_audit_update BEFORE UPDATE ON ', v_table,
            ' FOR EACH ROW SET ',
            'NEW.user = IFNULL(@lina_user, ''SYSTEM''), ',
            'NEW.date = DATE_FORMAT(NOW(), ''%Y%m%d''), ',
            'NEW.time = DATE_FORMAT(NOW(), ''%H:%i:%s''), ',
            'NEW.oper = ''U'', ',
            'NEW.prog = IFNULL(@lina_prog, ''UNKNOWN''), ',
            'NEW.wstn = ''00'', ',
            'NEW.nume = 0'
        );
        PREPARE stmt FROM @sql_create_update;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur_tables;
END$$

DELIMITER ;

CALL sp_setup_audit_triggers();

-- Opcional: eliminar el helper y dejar solo los triggers creados.
-- DROP PROCEDURE IF EXISTS sp_setup_audit_triggers;

-- Verificacion rapida
SHOW TRIGGERS LIKE 'lina%';
