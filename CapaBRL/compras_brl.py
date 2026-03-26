"""
Lógica de negocio para registración de facturas de compra.
Análogo a remitos_brl.py para la parte de compras.
"""
from CapaBRL.config import FMT_NROCOMP, LEN_TEXTO_LARGO, DEFAULT_EMPR_CODE
from CapaDAL.dataconn import sess_conns, ctx_empr


def crear_factura(
    conn,
    empr:      str,
    fchefech,
    provcodi:  int,
    fcheobse:  str,
    lineas:    list,
    fchetota,
    codm_fche: str,
) -> int:
    """
    Graba una factura de compra dentro de una transacción.

    Parámetros:
        conn       — conexión activa (sin autocommit; el llamador hace commit).
        empr       — código de empresa.
        fchefech   — fecha de la factura (date).
        provcodi   — código de proveedor (int).
        fcheobse   — observación (str, max 40).
        lineas     — lista de dicts con keys: fcdereng, articodi, fcdedesc, fcdecant, fcdeunit.
        fchetota   — total calculado (Decimal).
        codm_fche  — código de movimiento factura (ej. "FCHE").

    Retorna:
        fchenume — número de factura grabada.

    Raises:
        ValueError si el proveedor no existe o validación falla.
        Exception si hay error de BD.
    """
    cur = conn.cursor()
    try:
        # Validar que el proveedor existe
        cur.execute(
            "SELECT provcodi FROM linaprov WHERE emprcodi=%s AND provcodi=%s",
            (empr, provcodi),
        )
        if not cur.fetchone():
            raise ValueError(f"Proveedor {provcodi} no encontrado.")

        # Siguiente número de factura
        cur.execute(
            "SELECT COALESCE(MAX(fchenume), 0) + 1 FROM linafche WHERE emprcodi=%s AND codmcodi=%s",
            (empr, codm_fche),
        )
        fchenume = cur.fetchone()[0]

        # Cabecera de la factura
        cur.execute(
            "INSERT INTO linafche"
            "  (emprcodi, codmcodi, fchenume, fchefech, provcodi, fchetota, fcheobse)"
            " VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (empr, codm_fche, fchenume, fchefech, provcodi, float(fchetota), fcheobse),
        )

        # Renglones de la factura
        for ln in lineas:
            cur.execute(
                "INSERT INTO linafcde"
                "  (emprcodi, codmcodi, fchenume, fcdereng, fchefech,"
                "   articodi, fcdedesc, fcdecant, fcdeunit)"
                " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                (empr, codm_fche, fchenume, ln["fcdereng"], fchefech,
                 ln["articodi"], ln["fcdedesc"], ln["fcdecant"], float(ln["fcdeunit"])),
            )

        # Cuenta corriente: HABER (factura recibida — nosotros debemos al proveedor)
        cur.execute(
            "INSERT INTO linactpr"
            "  (emprcodi, provcodi, ctprfech, codmcodi, ctprnumc, ctprdebe, ctprhabe)"
            " VALUES (%s, %s, %s, %s, %s, 0, %s)",
            (empr, provcodi, fchefech, codm_fche, fchenume, float(fchetota)),
        )

    finally:
        cur.close()

    return fchenume


def anular_factura(codm: str, nro: int) -> dict:
    """
    Anula una factura de compra.

    Pasos (dentro de una transacción):
      1. Elimina todos los renglones (linafcde).
      2. Blanquea la cabecera (linafche): provcodi=0, fchetota=0,
         fcheobse='*** ANULADO ***'.
      3. Elimina el movimiento de cuenta corriente HABER (linactpr).

    Retorna {"ok": True} o {"ok": False, "error": "..."}.
    """
    empr = ctx_empr.get() or DEFAULT_EMPR_CODE
    conn = sess_conns.get_conn(readonly=False)
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT provcodi, fchefech, fchetota, fcheobse"
            "  FROM linafche"
            " WHERE emprcodi=%s AND codmcodi=%s AND fchenume=%s",
            (empr, codm, nro),
        )
        row = cur.fetchone()
        cur.close()

        if not row:
            return {"ok": False, "error": "Comprobante no encontrado."}
        if str(row.get("fcheobse") or "").startswith("*** ANULAD"):
            return {"ok": False, "error": "El comprobante ya fue anulado."}

        provcodi = int(row["provcodi"] or 0)
        fchefech = row["fchefech"]
        fchetota = float(row["fchetota"] or 0)

        cur = conn.cursor()
        # 1. Eliminar renglones
        cur.execute(
            "DELETE FROM linafcde"
            " WHERE emprcodi=%s AND codmcodi=%s AND fchenume=%s",
            (empr, codm, nro),
        )
        # 2. Blanquear cabecera
        cur.execute(
            "UPDATE linafche"
            "   SET provcodi=0, fchetota=0, fcheobse=%s"
            " WHERE emprcodi=%s AND codmcodi=%s AND fchenume=%s",
            ("*** ANULADO ***", empr, codm, nro),
        )
        # 3. Eliminar movimiento de ctpr (HABER)
        cur.execute(
            "DELETE FROM linactpr"
            " WHERE emprcodi=%s AND provcodi=%s AND ctprfech=%s"
            "   AND codmcodi=%s AND ctprnumc=%s AND ctprhabe=%s"
            " LIMIT 1",
            (empr, provcodi, fchefech, codm, nro, fchetota),
        )
        cur.close()
        conn.commit()
        return {"ok": True}
    except Exception as e:
        try:
            conn.rollback()
        except Exception:
            pass
        return {"ok": False, "error": str(e)}
    finally:
        sess_conns.release_conn(conn)
