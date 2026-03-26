-- ============================================================
--  sp_rescta_provs
--  Resumen de Cuenta Corriente de Proveedores
--
--  Parámetros:
--    p_empr       : código de empresa (CHAR 2)
--    p_fecini     : fecha inicial del rango (NULL = desde el origen)
--    p_fecfin     : fecha final del rango
--    p_codiin     : código proveedor desde (0 = todos)
--    p_codifi     : código proveedor hasta (9999 = todos)
--    p_saldo_cero : 1 = incluir saldos en cero; 0 = excluirlos
--
--  Resultado: una fila por movimiento + una fila SA (saldo anterior)
--  por cada proveedor seleccionado, ordenado por provcodi / SA primero.
--
--  Nota sobre debe/haber en linactpr:
--    ctprhabe = facturas recibidas  (aumenta lo que debemos)
--    ctprdebe = pagos realizados    (reduce lo que debemos)
--    saldo    = provsala + SUM(ctprhabe - ctprdebe)   [positivo → debemos]
-- ============================================================

DROP PROCEDURE IF EXISTS `sp_rescta_provs`;

DELIMITER ;;

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rescta_provs`(
    IN p_empr       CHAR(2) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_fecini     DATE,
    IN p_fecfin     DATE,
    IN p_codiin     INT,
    IN p_codifi     INT,
    IN p_saldo_cero TINYINT
)
BEGIN

    -- ── Fila SA por cada proveedor elegible ───────────────────
    SELECT
        p.provcodi,
        p.provname,
        'SA'  AS linea_tipo,
        CASE WHEN p_fecini IS NOT NULL
             THEN DATE_SUB(p_fecini, INTERVAL 1 DAY)
             ELSE p.provfesa
        END   AS ctprfech,
        'SALDO ANTERIOR' AS concepto,
        0.00  AS ctprdebe,
        0.00  AS ctprhabe,
        0     AS sort_key,
        -- saldo_ant: base + compactación de movimientos previos a p_fecini
        COALESCE(p.provsala, 0) + CASE
            WHEN p_fecini IS NOT NULL
            THEN COALESCE((
                     SELECT SUM(t2.ctprhabe - t2.ctprdebe)
                     FROM   linactpr t2
                     WHERE  t2.emprcodi = p_empr
                       AND  t2.provcodi = p.provcodi
                       AND  t2.ctprfech < p_fecini
                 ), 0)
            ELSE 0
        END   AS saldo_ant

    FROM linaprov p
    WHERE p.emprcodi = p_empr
      AND p.provcodi BETWEEN p_codiin AND p_codifi
      -- saldo final != 0 (saldo final = provsala + TODOS los movs hasta p_fecfin)
      AND (
          p_saldo_cero = 1
          OR ABS(
              COALESCE(p.provsala, 0) + COALESCE((
                  SELECT SUM(t4.ctprhabe - t4.ctprdebe)
                  FROM   linactpr t4
                  WHERE  t4.emprcodi = p_empr
                    AND  t4.provcodi = p.provcodi
                    AND  t4.ctprfech <= p_fecfin
              ), 0)
          ) > 0.005
      )
      -- tiene saldo inicial != 0 O movimientos en el rango de salida
      AND (
          ABS(COALESCE(p.provsala, 0) + CASE
              WHEN p_fecini IS NOT NULL
              THEN COALESCE((
                       SELECT SUM(t3.ctprhabe - t3.ctprdebe)
                       FROM   linactpr t3
                       WHERE  t3.emprcodi = p_empr
                         AND  t3.provcodi = p.provcodi
                         AND  t3.ctprfech < p_fecini
                   ), 0)
              ELSE 0
          END) > 0.005
          OR EXISTS (
              SELECT 1 FROM linactpr te
              WHERE  te.emprcodi = p_empr
                AND  te.provcodi = p.provcodi
                AND  te.ctprfech >= CASE WHEN p_fecini IS NULL THEN '1000-01-01' ELSE p_fecini END
                AND  te.ctprfech <= p_fecfin
          )
      )

    UNION ALL

    -- ── Filas MV: movimientos dentro del rango de salida ──────
    SELECT
        p2.provcodi,
        p2.provname,
        'MV'  AS linea_tipo,
        t.ctprfech,
        CONCAT(t.codmcodi, ' ', LPAD(t.ctprnumc, 6, '0')) AS concepto,
        COALESCE(t.ctprdebe, 0) AS ctprdebe,
        COALESCE(t.ctprhabe, 0) AS ctprhabe,
        t.ctprid AS sort_key,
        0.00 AS saldo_ant

    FROM linactpr t
    JOIN linaprov p2
      ON p2.emprcodi = t.emprcodi
     AND p2.provcodi = t.provcodi
    WHERE t.emprcodi = p_empr
      AND t.provcodi BETWEEN p_codiin AND p_codifi
      AND t.ctprfech >= CASE WHEN p_fecini IS NULL THEN '1000-01-01' ELSE p_fecini END
      AND t.ctprfech <= p_fecfin
      -- excluir proveedor si su saldo final es cero y p_saldo_cero=0
      AND (
          p_saldo_cero = 1
          OR ABS(
              COALESCE(p2.provsala, 0) + COALESCE((
                  SELECT SUM(t5.ctprhabe - t5.ctprdebe)
                  FROM   linactpr t5
                  WHERE  t5.emprcodi = p_empr
                    AND  t5.provcodi = t.provcodi
                    AND  t5.ctprfech <= p_fecfin
              ), 0)
          ) > 0.005
      )

    ORDER BY
        provcodi,
        CASE linea_tipo WHEN 'SA' THEN 0 ELSE 1 END,
        ctprfech,
        sort_key;

END ;;

DELIMITER ;
