-- ============================================================
-- sp_rescta_clies: cursor de movimientos de cuenta corriente
-- de clientes para el Resumen de Cuenta Clientes (LINA271).
--
-- Parámetros (en orden):
--   p_empr       CHAR(2)    : empresa
--   p_fecini     DATE       : fecha desde (NULL = sin compactación, desde el inicio)
--   p_fecfin     DATE       : fecha hasta (requerido)
--   p_codiin     INT        : cliente desde
--   p_codifi     INT        : cliente hasta
--   p_saldo_cero TINYINT(1) : 1 = incluir clientes con saldo cero / 0 = excluirlos
--
-- Resultado ordenado: cliecodi, SA primero, luego MV por fecha/ctclid.
-- Columnas:
--   cliecodi   INT
--   cliename   VARCHAR(40)
--   linea_tipo CHAR(2)        'SA' = saldo anterior  |  'MV' = movimiento
--   ctclfech   DATE
--   concepto   VARCHAR(52)
--   ctcldebe   DECIMAL(11,2)
--   ctclhabe   DECIMAL(11,2)
--   sort_key   BIGINT         (0 para SA, ctclid para MV)
--   saldo_ant  DECIMAL(11,2)  (significativo en SA; 0 en MV)
-- ============================================================

DROP PROCEDURE IF EXISTS sp_rescta_clies;

DELIMITER //

CREATE PROCEDURE sp_rescta_clies(
    IN p_empr       CHAR(2) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_fecini     DATE,
    IN p_fecfin     DATE,
    IN p_codiin     INT,
    IN p_codifi     INT,
    IN p_saldo_cero TINYINT
)
BEGIN
    -- Fecha inferior efectiva para MV: si p_fecini es NULL usamos la menor fecha posible.
    -- (linactcl no contiene registros anteriores a cliefesa, así que el riesgo de
    --  doble-cómputo con cliesala es mínimo, pero la lógica es correcta de todas formas.)

    -- ── Fila SA por cada cliente elegible ─────────────────────
    SELECT
        c.cliecodi,
        c.cliename,
        'SA'  AS linea_tipo,
        CASE WHEN p_fecini IS NOT NULL
             THEN DATE_SUB(p_fecini, INTERVAL 1 DAY)
             ELSE c.cliefesa
        END   AS ctclfech,
        'SALDO ANTERIOR' AS concepto,
        0.00  AS ctcldebe,
        0.00  AS ctclhabe,
        0     AS sort_key,
        -- saldo_ant: base + compactación de movimientos previos a p_fecini
        COALESCE(c.cliesala, 0) + CASE
            WHEN p_fecini IS NOT NULL
            THEN COALESCE((
                     SELECT SUM(t2.ctcldebe - t2.ctclhabe)
                     FROM   linactcl t2
                     WHERE  t2.emprcodi = p_empr
                       AND  t2.cliecodi = c.cliecodi
                       AND  t2.ctclfech < p_fecini
                 ), 0)
            ELSE 0
        END   AS saldo_ant

    FROM linaclie c
    WHERE c.emprcodi = p_empr
      AND c.cliecodi BETWEEN p_codiin AND p_codifi
      -- saldo final != 0  (saldo final = cliesala + TODOS los movs hasta p_fecfin)
      AND (
          p_saldo_cero = 1
          OR ABS(
              COALESCE(c.cliesala, 0) + COALESCE((
                  SELECT SUM(t4.ctcldebe - t4.ctclhabe)
                  FROM   linactcl t4
                  WHERE  t4.emprcodi = p_empr
                    AND  t4.cliecodi = c.cliecodi
                    AND  t4.ctclfech <= p_fecfin
              ), 0)
          ) > 0.005
      )
      -- tiene saldo inicial != 0 O movimientos en el rango de salida
      AND (
          ABS(COALESCE(c.cliesala, 0) + CASE
              WHEN p_fecini IS NOT NULL
              THEN COALESCE((
                       SELECT SUM(t3.ctcldebe - t3.ctclhabe)
                       FROM   linactcl t3
                       WHERE  t3.emprcodi = p_empr
                         AND  t3.cliecodi = c.cliecodi
                         AND  t3.ctclfech < p_fecini
                   ), 0)
              ELSE 0
          END) > 0.005
          OR EXISTS (
              SELECT 1 FROM linactcl te
              WHERE  te.emprcodi = p_empr
                AND  te.cliecodi = c.cliecodi
                AND  te.ctclfech >= CASE WHEN p_fecini IS NULL THEN '1000-01-01' ELSE p_fecini END
                AND  te.ctclfech <= p_fecfin
          )
      )

    UNION ALL

    -- ── Filas MV: movimientos dentro del rango de salida ──────
    SELECT
        c2.cliecodi,
        c2.cliename,
        'MV'  AS linea_tipo,
        t.ctclfech,
        CONCAT(t.codmcodi, ' ', LPAD(t.ctclnumc, 6, '0')) AS concepto,
        COALESCE(t.ctcldebe, 0) AS ctcldebe,
        COALESCE(t.ctclhabe, 0) AS ctclhabe,
        t.ctclid AS sort_key,
        0.00 AS saldo_ant

    FROM linactcl t
    JOIN linaclie c2
      ON c2.emprcodi = t.emprcodi
     AND c2.cliecodi = t.cliecodi
    WHERE t.emprcodi = p_empr
      AND t.cliecodi BETWEEN p_codiin AND p_codifi
      AND t.ctclfech >= CASE WHEN p_fecini IS NULL THEN '1000-01-01' ELSE p_fecini END
      AND t.ctclfech <= p_fecfin
      -- excluir cliente si su saldo final es cero y p_saldo_cero=0
      AND (
          p_saldo_cero = 1
          OR ABS(
              COALESCE(c2.cliesala, 0) + COALESCE((
                  SELECT SUM(t5.ctcldebe - t5.ctclhabe)
                  FROM   linactcl t5
                  WHERE  t5.emprcodi = p_empr
                    AND  t5.cliecodi = t.cliecodi
                    AND  t5.ctclfech <= p_fecfin
              ), 0)
          ) > 0.005
      )

    ORDER BY
        cliecodi,
        CASE linea_tipo WHEN 'SA' THEN 0 ELSE 1 END,
        ctclfech,
        sort_key;

END //

DELIMITER ;
