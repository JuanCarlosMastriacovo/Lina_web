"""
Lógica de negocio para registro y anulación de pagos a proveedores (LINA34/LINA35).
Análogo a recibos_brl.py para la parte de compras.
"""
from decimal import Decimal
from CapaBRL.config import FMT_NROCOMP, LEN_TEXTO_LARGO, LEN_CONC_CAJA, DEFAULT_EMPR_CODE
from CapaDAL.dataconn import sess_conns, ctx_empr


def crear_pago(
    conn,
    empr:      str,
    pahefech,
    provcodi:  int,
    paheobse:  str,
    lineas:    list,
    efec,
    banc,
    pahetota,
    codm_pago: str,
) -> int:
    """
    Graba un pago a proveedor dentro de una transacción.

    lineas: lista de dicts con keys: padereng, padedesc, padeunit.
    efec, banc, pahetota: Decimal.
    Retorna pahenume (int).
    Raises: ValueError si el proveedor no existe o validación falla.
    """
    cur = conn.cursor()
    try:
        # Validar proveedor
        cur.execute(
            "SELECT provcodi FROM linaprov WHERE emprcodi=%s AND provcodi=%s",
            (empr, provcodi),
        )
        if not cur.fetchone():
            raise ValueError(f"Proveedor {provcodi} no encontrado.")

        # Siguiente número de pago
        cur.execute(
            "SELECT COALESCE(MAX(pahenume), 0) + 1 FROM linapahe"
            " WHERE emprcodi=%s AND codmcodi=%s",
            (empr, codm_pago),
        )
        pahenume = cur.fetchone()[0]

        efec_f     = float(efec)
        banc_f     = float(banc)
        pahetota_f = float(pahetota)

        # Cabecera del pago
        cur.execute(
            "INSERT INTO linapahe"
            "  (emprcodi, codmcodi, pahenume, pahefech, provcodi,"
            "   pahetota, paheefec, pahebanc, paheobse)"
            " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
            (empr, codm_pago, pahenume, pahefech, provcodi,
             pahetota_f, efec_f, banc_f, paheobse),
        )

        # Renglones de detalle
        padereng = 0
        for ln in lineas:
            padereng += 1
            cur.execute(
                "INSERT INTO linapade"
                "  (emprcodi, codmcodi, pahenume, padereng, padedesc, padeunit)"
                " VALUES (%s, %s, %s, %s, %s, %s)",
                (empr, codm_pago, pahenume, padereng,
                 str(ln["padedesc"])[:LEN_TEXTO_LARGO], float(ln["padeunit"])),
            )

        conc = f"RECI Nº {pahenume:{FMT_NROCOMP}}"[:LEN_CONC_CAJA]

        # Movimiento de caja (salida: cajadebe)
        if efec > 0:
            cur.execute(
                "INSERT INTO linacaja"
                "  (emprcodi, cliecodi, provcodi, cajafech, cajanumc, cajaconc, cajadebe, cajahabe)"
                " VALUES (%s, 0, %s, %s, %s, %s, %s, 0)",
                (empr, provcodi, pahefech, pahenume, conc, efec_f),
            )

        # Movimiento bancario (salida: bancdebe)
        if banc > 0:
            cur.execute(
                "INSERT INTO linabanc"
                "  (emprcodi, cliecodi, provcodi, bancfech, bancnumc, bancconc, bancdebe, banchabe)"
                " VALUES (%s, 0, %s, %s, %s, %s, %s, 0)",
                (empr, provcodi, pahefech, pahenume, conc, banc_f),
            )

        # Cuenta corriente: DEBE (pago reduce lo que debemos al proveedor)
        cur.execute(
            "INSERT INTO linactpr"
            "  (emprcodi, provcodi, ctprfech, codmcodi, ctprnumc, ctprdebe, ctprhabe)"
            " VALUES (%s, %s, %s, %s, %s, %s, 0)",
            (empr, provcodi, pahefech, codm_pago, pahenume, pahetota_f),
        )

    finally:
        cur.close()

    return pahenume


def anular_pago(codm: str, nro: int) -> dict:
    """
    Anula un pago a proveedor.

    Pasos (dentro de una transacción):
      1. Elimina todos los renglones (linapade).
      2. Blanquea la cabecera (linapahe): provcodi=0, pahetota=0, paheefec=0,
         pahebanc=0, paheobse='*** ANULADO ***'.
      3. Elimina el movimiento de cuenta corriente DEBE (linactpr).
      4. Elimina el movimiento de caja (linacaja) si paheefec > 0.
      5. Elimina el movimiento bancario (linabanc) si pahebanc > 0.

    Retorna {"ok": True} o {"ok": False, "error": "..."}.
    """
    empr = ctx_empr.get() or DEFAULT_EMPR_CODE
    conn = sess_conns.get_conn(readonly=False)
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT provcodi, pahefech, pahetota, paheefec, pahebanc, paheobse"
            "  FROM linapahe"
            " WHERE emprcodi=%s AND codmcodi=%s AND pahenume=%s",
            (empr, codm, nro),
        )
        row = cur.fetchone()
        cur.close()

        if not row:
            return {"ok": False, "error": "Comprobante no encontrado."}
        if str(row.get("paheobse") or "").startswith("*** ANULAD"):
            return {"ok": False, "error": "El comprobante ya fue anulado."}

        provcodi  = int(row["provcodi"] or 0)
        pahefech  = row["pahefech"]
        pahetota  = float(row["pahetota"] or 0)
        paheefec  = float(row["paheefec"] or 0)
        pahebanc  = float(row["pahebanc"] or 0)

        cur = conn.cursor()
        # 1. Eliminar renglones
        cur.execute(
            "DELETE FROM linapade"
            " WHERE emprcodi=%s AND codmcodi=%s AND pahenume=%s",
            (empr, codm, nro),
        )
        # 2. Blanquear cabecera
        cur.execute(
            "UPDATE linapahe"
            "   SET provcodi=0, pahetota=0, paheefec=0, pahebanc=0, paheobse=%s"
            " WHERE emprcodi=%s AND codmcodi=%s AND pahenume=%s",
            ("*** ANULADO ***", empr, codm, nro),
        )
        # 3. Eliminar movimiento ctpr DEBE
        cur.execute(
            "DELETE FROM linactpr"
            " WHERE emprcodi=%s AND provcodi=%s AND ctprfech=%s"
            "   AND codmcodi=%s AND ctprnumc=%s AND ctprhabe=0 AND ctprdebe=%s"
            " LIMIT 1",
            (empr, provcodi, pahefech, codm, nro, pahetota),
        )
        # 4. Eliminar movimiento de caja (efectivo)
        if paheefec > 0:
            cur.execute(
                "DELETE FROM linacaja"
                " WHERE emprcodi=%s AND provcodi=%s AND cajafech=%s"
                "   AND cajanumc=%s AND cajahabe=0 AND cajadebe=%s"
                " LIMIT 1",
                (empr, provcodi, pahefech, nro, paheefec),
            )
        # 5. Eliminar movimiento bancario (transferencia)
        if pahebanc > 0:
            cur.execute(
                "DELETE FROM linabanc"
                " WHERE emprcodi=%s AND provcodi=%s AND bancfech=%s"
                "   AND bancnumc=%s AND banchabe=0 AND bancdebe=%s"
                " LIMIT 1",
                (empr, provcodi, pahefech, nro, pahebanc),
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
