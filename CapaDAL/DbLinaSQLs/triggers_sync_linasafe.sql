DELIMITER //

-- Triggers para linauser
CREATE TRIGGER tr_linauser_insert AFTER INSERT ON linauser
FOR EACH ROW
BEGIN
    CALL sp_sync_linasafe();
END //

CREATE TRIGGER tr_linauser_delete AFTER DELETE ON linauser
FOR EACH ROW
BEGIN
    CALL sp_sync_linasafe();
END //

-- Triggers para linaprog
CREATE TRIGGER tr_linaprog_insert AFTER INSERT ON linaprog
FOR EACH ROW
BEGIN
    CALL sp_sync_linasafe();
END //

CREATE TRIGGER tr_linaprog_delete AFTER DELETE ON linaprog
FOR EACH ROW
BEGIN
    CALL sp_sync_linasafe();
END //

CREATE TRIGGER tr_linaprog_update AFTER UPDATE ON linaprog
FOR EACH ROW
BEGIN
    -- Si cambia el progcall, sincronizamos linasafe (sin usar NULL)
    IF OLD.progcall <> NEW.progcall THEN
        CALL sp_sync_linasafe();
    END IF;
END //

DELIMITER ;
