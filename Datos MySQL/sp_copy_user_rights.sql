DROP PROCEDURE IF EXISTS sp_copy_user_rights;

DELIMITER $$
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

    -- Asegura que linasafe tenga combinaciones vigentes antes de copiar permisos.
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
DELIMITER ;

-- Ejemplo de uso:
-- CALL sp_copy_user_rights('01', 'USU_ORIG', '01', 'USU_DEST');
