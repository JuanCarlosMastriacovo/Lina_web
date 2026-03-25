"""
Lógica de negocio para emisión y anulación de recibos de cobranza (LINA24/LINA25).
"""
from decimal import Decimal
from CapaBRL.config import FMT_NROCOMP, LEN_TEXTO_LARGO, LEN_CONC_CAJA, DEFAULT_EMPR_CODE
from CapaDAL.dataconn import sess_conns, ctx_empr


def crear_recibo(
    conn,
    empr:      str,
    cohefech,
    cliecodi:  int,
    coheobse:  str,
    lineas:    list,
    efec,
    banc,
    cohetota,
    codm_reci: str,
) -> int:
    """
    Graba un recibo de cobranza standalone.

    lineas: lista de dicts con keys: codereng, codedesc, codeunit.
    efec, banc, cohetota: Decimal.
    Retorna cohenume (int).
    Raises: ValueError si el cliente no existe o validación falla.
    """
    cur = conn.cursor()
    try:
        # Validar cliente
        cur.execute(
            "SELECT cliecodi FROM linaclie WHERE emprcodi=%s AND cliecodi=%s",
            (empr, cliecodi),
        )
        if not cur.fetchone():
            raise ValueError(f"Cliente {cliecodi} no encontrado.")

        # Siguiente número de recibo
        cur.execute(
            "SELECT COALESCE(MAX(cohenume), 0) + 1 FROM linacohe"
            " WHERE emprcodi=%s AND codmcodi=%s",
            (empr, codm_reci),
        )
        cohenume = cur.fetchone()[0]

        efec_f     = float(efec)
        banc_f     = float(banc)
        cohetota_f = float(cohetota)

        # Cabecera del recibo
        cur.execute(
            "INSERT INTO linacohe"
            "  (emprcodi, codmcodi, cohenume, cohefech, cliecodi,"
            "   cohetota, coheefec, cohebanc, coheobse)"
            " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
            (empr, codm_reci, cohenume, cohefech, cliecodi,
             cohetota_f, efec_f, banc_f, coheobse),
        )

        # Renglones de detalle ingresados por el operador
        codereng = 0
        for ln in lineas:
            codereng += 1
            cur.execute(
                "INSERT INTO linacode"
                "  (emprcodi, codmcodi, cohenume, codereng, codedesc, codeunit)"
                " VALUES (%s, %s, %s, %s, %s, %s)",
                (empr, codm_reci, cohenume, codereng,
                 str(ln["codedesc"])[:LEN_TEXTO_LARGO], float(ln["codeunit"])),
            )

        # Movimientos contables de forma de pago (no se registran en linacode)
        conc = f"RECI Nº {cohenume:{FMT_NROCOMP}}"[:LEN_CONC_CAJA]

        if efec > 0:
            cur.execute(
                "INSERT INTO linacaja"
                "  (emprcodi, cliecodi, provcodi, cajafech, cajanumc, cajaconc, cajadebe, cajahabe)"
                " VALUES (%s, %s, 0, %s, %s, %s, 0, %s)",
                (empr, cliecodi, cohefech, cohenume, conc, efec_f),
            )

        if banc > 0:
            cur.execute(
                "INSERT INTO linabanc"
                "  (emprcodi, cliecodi, provcodi, bancfech, bancnumc, bancconc, bancdebe, banchabe)"
                " VALUES (%s, %s, 0, %s, %s, %s, 0, %s)",
                (empr, cliecodi, cohefech, cohenume, conc, banc_f),
            )

        # Cuenta corriente: HABER (cobro)
        cur.execute(
            "INSERT INTO linactcl"
            "  (emprcodi, cliecodi, ctclfech, codmcodi, ctclnumc, ctcldebe, ctclhabe)"
            " VALUES (%s, %s, %s, %s, %s, 0, %s)",
            (empr, cliecodi, cohefech, codm_reci, cohenume, cohetota_f),
        )

    finally:
        cur.close()

    return cohenume


def anular_recibo(codm: str, nro: int) -> dict:
    """
    Anula un recibo de cobranza (lógica de anulcomp en LINA25.PRG).

    Pasos (dentro de una transacción):
      1. Elimina todos los renglones (linacode).
      2. Blanquea la cabecera (linacohe): cliecodi=0, cohetota=0, coheefec=0,
         cohebanc=0, coheobse='*** ANULADO ***'.
      3. Elimina el movimiento de cuenta corriente HABER (linactcl).
      4. Elimina el movimiento de caja (linacaja) si coheefec > 0.
      5. Elimina el movimiento bancario (linabanc) si cohebanc > 0.

    Retorna {"ok": True} o {"ok": False, "error": "..."}.
    """
    empr = ctx_empr.get() or DEFAULT_EMPR_CODE
    conn = sess_conns.get_conn(readonly=False)
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT cliecodi, cohefech, cohetota, coheefec, cohebanc, coheobse"
            "  FROM linacohe"
            " WHERE emprcodi=%s AND codmcodi=%s AND cohenume=%s",
            (empr, codm, nro),
        )
        row = cur.fetchone()
        cur.close()

        if not row:
            return {"ok": False, "error": "Comprobante no encontrado."}
        if str(row.get("coheobse") or "").startswith("*** ANULAD"):
            return {"ok": False, "error": "El comprobante ya fue anulado."}

        cliecodi  = int(row["cliecodi"] or 0)
        cohefech  = row["cohefech"]
        cohetota  = float(row["cohetota"] or 0)
        coheefec  = float(row["coheefec"] or 0)
        cohebanc  = float(row["cohebanc"] or 0)

        cur = conn.cursor()
        # 1. Eliminar renglones
        cur.execute(
            "DELETE FROM linacode"
            " WHERE emprcodi=%s AND codmcodi=%s AND cohenume=%s",
            (empr, codm, nro),
        )
        # 2. Blanquear cabecera
        cur.execute(
            "UPDATE linacohe"
            "   SET cliecodi=0, cohetota=0, coheefec=0, cohebanc=0, coheobse=%s"
            " WHERE emprcodi=%s AND codmcodi=%s AND cohenume=%s",
            ("*** ANULADO ***", empr, codm, nro),
        )
        # 3. Eliminar movimiento ctcl HABER
        cur.execute(
            "DELETE FROM linactcl"
            " WHERE emprcodi=%s AND cliecodi=%s AND ctclfech=%s"
            "   AND codmcodi=%s AND ctclnumc=%s AND ctcldebe=0 AND ctclhabe=%s"
            " LIMIT 1",
            (empr, cliecodi, cohefech, codm, nro, cohetota),
        )
        # 4. Eliminar movimiento de caja (efectivo)
        if coheefec > 0:
            cur.execute(
                "DELETE FROM linacaja"
                " WHERE emprcodi=%s AND cliecodi=%s AND cajafech=%s"
                "   AND cajanumc=%s AND cajadebe=0 AND cajahabe=%s"
                " LIMIT 1",
                (empr, cliecodi, cohefech, nro, coheefec),
            )
        # 5. Eliminar movimiento bancario (transferencia)
        if cohebanc > 0:
            cur.execute(
                "DELETE FROM linabanc"
                " WHERE emprcodi=%s AND cliecodi=%s AND bancfech=%s"
                "   AND bancnumc=%s AND bancdebe=0 AND banchabe=%s"
                " LIMIT 1",
                (empr, cliecodi, cohefech, nro, cohebanc),
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
