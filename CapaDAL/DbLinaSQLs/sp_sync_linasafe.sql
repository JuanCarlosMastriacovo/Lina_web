DELIMITER $$
CREATE DEFINER=`lina`@`%` PROCEDURE `sp_sync_linasafe`()
    MODIFIES SQL DATA
BEGIN
    -- 1. Insertar registros faltantes en linasafe para cada combinación de usuario y programa
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
        DATE_FORMAT(NOW(), '%H%i%s'), 
        'I', 'SP_SYNC', '00', 0
    FROM linauser u
    CROSS JOIN linaprog p
    LEFT JOIN linasafe s ON u.emprcodi = s.emprcodi AND u.usercodi = s.usercodi AND p.progcodi = s.progcodi
    WHERE IFNULL(s.usercodi, '') = ''
      AND TRIM(IFNULL(p.progcall, '')) <> '';

    -- 2. Eliminar registros de linasafe que:
    --    a) No tienen un usuario o programa válido (Join fallido -> '')
    --    b) El programa tiene un progcall vacío o solo espacios (nodos de menú sin acción)
    DELETE s FROM linasafe s
    LEFT JOIN linauser u ON s.emprcodi = u.emprcodi AND s.usercodi = u.usercodi
    LEFT JOIN linaprog p ON s.progcodi = p.progcodi
    WHERE IFNULL(u.usercodi, '') = '' 
       OR IFNULL(p.progcodi, '') = '' 
       OR TRIM(IFNULL(p.progcall, '')) = '';
END$$
DELIMITER ;
