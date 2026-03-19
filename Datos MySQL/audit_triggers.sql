DELIMITER //

DROP TRIGGER IF EXISTS tr_linaarti_audit_insert //
CREATE TRIGGER tr_linaarti_audit_insert BEFORE INSERT ON linaarti
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linaarti_audit_update //
CREATE TRIGGER tr_linaarti_audit_update BEFORE UPDATE ON linaarti
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linaartr_audit_insert //
CREATE TRIGGER tr_linaartr_audit_insert BEFORE INSERT ON linaartr
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linaartr_audit_update //
CREATE TRIGGER tr_linaartr_audit_update BEFORE UPDATE ON linaartr
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linabanc_audit_insert //
CREATE TRIGGER tr_linabanc_audit_insert BEFORE INSERT ON linabanc
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linabanc_audit_update //
CREATE TRIGGER tr_linabanc_audit_update BEFORE UPDATE ON linabanc
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linacaja_audit_insert //
CREATE TRIGGER tr_linacaja_audit_insert BEFORE INSERT ON linacaja
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linacaja_audit_update //
CREATE TRIGGER tr_linacaja_audit_update BEFORE UPDATE ON linacaja
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linaclie_audit_insert //
CREATE TRIGGER tr_linaclie_audit_insert BEFORE INSERT ON linaclie
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linaclie_audit_update //
CREATE TRIGGER tr_linaclie_audit_update BEFORE UPDATE ON linaclie
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linacode_audit_insert //
CREATE TRIGGER tr_linacode_audit_insert BEFORE INSERT ON linacode
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linacode_audit_update //
CREATE TRIGGER tr_linacode_audit_update BEFORE UPDATE ON linacode
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linacodm_audit_insert //
CREATE TRIGGER tr_linacodm_audit_insert BEFORE INSERT ON linacodm
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linacodm_audit_update //
CREATE TRIGGER tr_linacodm_audit_update BEFORE UPDATE ON linacodm
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linacohe_audit_insert //
CREATE TRIGGER tr_linacohe_audit_insert BEFORE INSERT ON linacohe
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linacohe_audit_update //
CREATE TRIGGER tr_linacohe_audit_update BEFORE UPDATE ON linacohe
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linactcl_audit_insert //
CREATE TRIGGER tr_linactcl_audit_insert BEFORE INSERT ON linactcl
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linactcl_audit_update //
CREATE TRIGGER tr_linactcl_audit_update BEFORE UPDATE ON linactcl
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linactpr_audit_insert //
CREATE TRIGGER tr_linactpr_audit_insert BEFORE INSERT ON linactpr
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linactpr_audit_update //
CREATE TRIGGER tr_linactpr_audit_update BEFORE UPDATE ON linactpr
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linaempr_audit_insert //
CREATE TRIGGER tr_linaempr_audit_insert BEFORE INSERT ON linaempr
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linaempr_audit_update //
CREATE TRIGGER tr_linaempr_audit_update BEFORE UPDATE ON linaempr
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linafcde_audit_insert //
CREATE TRIGGER tr_linafcde_audit_insert BEFORE INSERT ON linafcde
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linafcde_audit_update //
CREATE TRIGGER tr_linafcde_audit_update BEFORE UPDATE ON linafcde
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linafche_audit_insert //
CREATE TRIGGER tr_linafche_audit_insert BEFORE INSERT ON linafche
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linafche_audit_update //
CREATE TRIGGER tr_linafche_audit_update BEFORE UPDATE ON linafche
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linafvde_audit_insert //
CREATE TRIGGER tr_linafvde_audit_insert BEFORE INSERT ON linafvde
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linafvde_audit_update //
CREATE TRIGGER tr_linafvde_audit_update BEFORE UPDATE ON linafvde
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linafvhe_audit_insert //
CREATE TRIGGER tr_linafvhe_audit_insert BEFORE INSERT ON linafvhe
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linafvhe_audit_update //
CREATE TRIGGER tr_linafvhe_audit_update BEFORE UPDATE ON linafvhe
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linapade_audit_insert //
CREATE TRIGGER tr_linapade_audit_insert BEFORE INSERT ON linapade
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linapade_audit_update //
CREATE TRIGGER tr_linapade_audit_update BEFORE UPDATE ON linapade
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linapahe_audit_insert //
CREATE TRIGGER tr_linapahe_audit_insert BEFORE INSERT ON linapahe
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linapahe_audit_update //
CREATE TRIGGER tr_linapahe_audit_update BEFORE UPDATE ON linapahe
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linaprog_audit_insert //
CREATE TRIGGER tr_linaprog_audit_insert BEFORE INSERT ON linaprog
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linaprog_audit_update //
CREATE TRIGGER tr_linaprog_audit_update BEFORE UPDATE ON linaprog
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linaprov_audit_insert //
CREATE TRIGGER tr_linaprov_audit_insert BEFORE INSERT ON linaprov
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linaprov_audit_update //
CREATE TRIGGER tr_linaprov_audit_update BEFORE UPDATE ON linaprov
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linasafe_audit_insert //
CREATE TRIGGER tr_linasafe_audit_insert BEFORE INSERT ON linasafe
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linasafe_audit_update //
CREATE TRIGGER tr_linasafe_audit_update BEFORE UPDATE ON linasafe
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linauser_audit_insert //
CREATE TRIGGER tr_linauser_audit_insert BEFORE INSERT ON linauser
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'I';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DROP TRIGGER IF EXISTS tr_linauser_audit_update //
CREATE TRIGGER tr_linauser_audit_update BEFORE UPDATE ON linauser
FOR EACH ROW
BEGIN
    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
    SET NEW.oper = 'U';
    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
    SET NEW.wstn = '00';
    SET NEW.nume = 0;
END //

DELIMITER ;
