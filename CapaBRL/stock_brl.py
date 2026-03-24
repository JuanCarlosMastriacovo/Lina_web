from datetime import date
from CapaBRL.config import DEFAULT_EMPR_CODE
from CapaDAL.dataconn import sess_conns, ctx_empr


def get_existencias_batch(articodis: list, fecha_hasta: date, conn=None) -> dict:
    """
    Calcula existencia de stock para una lista de artículos hasta una fecha.
    Retorna {articodi: existencia_int}.
    Gestiona su propia conexión si no se provee una.
    """
    if not articodis:
        return {}

    empr = ctx_empr.get() or DEFAULT_EMPR_CODE
    placeholders = ",".join(["%s"] * len(articodis))
    owns_conn = conn is None
    if owns_conn:
        conn = sess_conns.get_conn(readonly=True)
    try:
        cur = conn.cursor()
        try:
            cur.execute(
                f"""
                SELECT a.articodi,
                       COALESCE(a.artiexan, 0)
                       + COALESCE((SELECT SUM(e.fcdecant) FROM linafcde e
                                    WHERE e.emprcodi = %s
                                      AND e.articodi = a.articodi
                                      AND e.fchefech <= %s), 0)
                       - COALESCE((SELECT SUM(s.fvdecant) FROM linafvde s
                                    WHERE s.emprcodi = %s
                                      AND s.articodi = a.articodi
                                      AND s.fvhefech <= %s), 0)
                  FROM linaarti a
                 WHERE a.emprcodi = %s
                   AND a.articodi IN ({placeholders})
                """,
                [empr, fecha_hasta, empr, fecha_hasta, empr] + list(articodis),
            )
            return {
                str(row[0] or "").strip(): (int(row[1]) if row[1] is not None else 0)
                for row in cur.fetchall()
            }
        finally:
            cur.close()
    finally:
        if owns_conn:
            sess_conns.release_conn(conn)


def get_ventas_periodo(articodis: list, fecha_ini: date, fecha_fin: date, conn=None) -> dict:
    """
    Retorna {articodi: unidades_vendidas} para el período [fecha_ini, fecha_fin].
    Solo cuenta movimientos con fvdecant > 0.
    Gestiona su propia conexión si no se provee una.
    """
    if not articodis:
        return {}

    empr = ctx_empr.get() or DEFAULT_EMPR_CODE
    placeholders = ",".join(["%s"] * len(articodis))
    owns_conn = conn is None
    if owns_conn:
        conn = sess_conns.get_conn(readonly=True)
    try:
        cur = conn.cursor()
        try:
            cur.execute(
                f"SELECT articodi, SUM(fvdecant) "
                f"  FROM linafvde "
                f" WHERE emprcodi = %s "
                f"   AND fvdecant > 0 "
                f"   AND fvhefech >= %s AND fvhefech <= %s "
                f"   AND articodi IN ({placeholders}) "
                f" GROUP BY articodi",
                [empr, fecha_ini, fecha_fin] + list(articodis),
            )
            return {
                str(row[0] or "").strip(): int(row[1] or 0)
                for row in cur.fetchall()
            }
        finally:
            cur.close()
    finally:
        if owns_conn:
            sess_conns.release_conn(conn)


def get_existencia_articulo(empr_code: str, articodi: str, conn) -> int:
    """
    Calcula existencia de stock para un artículo específico (sin filtro de fecha).
    Requiere una conexión activa; no la cierra.
    """
    cur = conn.cursor()
    try:
        cur.execute(
            """
            SELECT COALESCE(a.artiexan, 0)
                   + COALESCE((SELECT SUM(e.fcdecant) FROM linafcde e
                                WHERE e.emprcodi = %s AND e.articodi = %s), 0)
                   - COALESCE((SELECT SUM(s.fvdecant) FROM linafvde s
                                WHERE s.emprcodi = %s AND s.articodi = %s), 0)
              FROM linaarti a
             WHERE a.emprcodi = %s AND a.articodi = %s
            """,
            (empr_code, articodi, empr_code, articodi, empr_code, articodi),
        )
        row = cur.fetchone()
        return int(row[0]) if row and row[0] is not None else 0
    finally:
        cur.close()
