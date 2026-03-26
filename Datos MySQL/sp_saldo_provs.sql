-- ============================================================
--  sp_saldo_provs
--  Saldos de Cuenta Corriente de Proveedores a una fecha dada
--
--  Parámetros:
--    p_empr   : código de empresa (CHAR 2)
--    p_codiin : código proveedor desde (0 = todos)
--    p_codifi : código proveedor hasta (9999 = todos)
--    p_fecfin : fecha de corte
--
--  Resultado: una fila por proveedor con su saldo al p_fecfin.
--    saldo positivo = debemos al proveedor
--    saldo = provsala + SUM(ctprhabe - ctprdebe) hasta p_fecfin
-- ============================================================

DROP PROCEDURE IF EXISTS `sp_saldo_provs`;

DELIMITER ;;

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_saldo_provs`(
    IN p_empr   CHAR(2) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_codiin INT,
    IN p_codifi INT,
    IN p_fecfin DATE
)
BEGIN
    SELECT
        p.provcodi,
        p.provname,
        COALESCE(p.provsala, 0) + COALESCE((
            SELECT SUM(t.ctprhabe - t.ctprdebe)
            FROM   linactpr t
            WHERE  t.emprcodi = p_empr
              AND  t.provcodi = p.provcodi
              AND  t.ctprfech <= p_fecfin
        ), 0) AS saldo

    FROM  linaprov p
    WHERE p.emprcodi = p_empr
      AND p.provcodi BETWEEN p_codiin AND p_codifi

    ORDER BY p.provcodi;

END ;;

DELIMITER ;
