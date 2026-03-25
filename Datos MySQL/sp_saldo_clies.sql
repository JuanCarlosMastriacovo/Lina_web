-- ============================================================
-- sp_saldo_clies: saldo de cuenta corriente por cliente
-- para el Listado de Saldos de Clientes (LINA272).
--
-- Parámetros:
--   p_empr     CHAR(2)  : empresa
--   p_codiin   INT      : cliente desde
--   p_codifi   INT      : cliente hasta
--   p_fecfin   DATE     : saldos a esta fecha (inclusive)
--
-- Resultado ordenado por cliecodi ASC.
-- Columnas:
--   cliecodi   INT
--   cliename   VARCHAR(40)
--   saldo      DECIMAL(11,2)   cliesala + SUM(debe-habe) hasta p_fecfin
-- ============================================================

DROP PROCEDURE IF EXISTS sp_saldo_clies;

DELIMITER //

CREATE PROCEDURE sp_saldo_clies(
    IN p_empr   CHAR(2) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_codiin INT,
    IN p_codifi INT,
    IN p_fecfin DATE
)
BEGIN
    SELECT
        c.cliecodi,
        c.cliename,
        COALESCE(c.cliesala, 0) + COALESCE((
            SELECT SUM(t.ctcldebe - t.ctclhabe)
            FROM   linactcl t
            WHERE  t.emprcodi = p_empr
              AND  t.cliecodi = c.cliecodi
              AND  t.ctclfech <= p_fecfin
        ), 0) AS saldo

    FROM  linaclie c
    WHERE c.emprcodi = p_empr
      AND c.cliecodi BETWEEN p_codiin AND p_codifi

    ORDER BY c.cliecodi;

END //

DELIMITER ;
