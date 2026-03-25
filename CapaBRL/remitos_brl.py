"""
Lógica de negocio para emisión y anulación de remitos de venta.
Extraído de CapaUI/lina21.py (punto 3: cross-layer entanglement).
"""
from decimal import Decimal
from CapaBRL.config import FMT_NROCOMP, LEN_TEXTO_LARGO, LEN_CONC_CAJA, DEFAULT_EMPR_CODE
from CapaDAL.dataconn import sess_conns, ctx_empr


def _insertar_renglon_recibo(cur, empr, codm, cohenume, codereng, desc, unit):
    cur.execute(
        "INSERT INTO linacode"
        "  (emprcodi, codmcodi, cohenume, codereng, codedesc, codeunit)"
        " VALUES (%s, %s, %s, %s, %s, %s)",
        (empr, codm, cohenume, codereng, desc[:LEN_TEXTO_LARGO], unit),
    )


def crear_remito_con_cobro(
    conn,
    empr:      str,
    fvhefech,
    cliecodi:  int,
    fvheobse:  str,
    lineas:    list,
    efec,
    banc,
    is_ajuste: bool,
    fvhetota,
    codm_remi: str,
    codm_reci: str,
) -> tuple:
    """
    Graba un remito de venta con su cobro asociado dentro de una transacción.

    Parámetros:
        conn       — conexión activa (sin autocommit; el llamador hace commit).
        empr       — código de empresa.
        fvhefech   — fecha del remito (date).
        cliecodi   — código de cliente (int).
        fvheobse   — observación (str, max 40).
        lineas     — lista de dicts con keys: fvdereng, articodi, fvdedesc, fvdecant, fvdeunit.
        efec       — cobro en efectivo (Decimal).
        banc       — cobro en banco (Decimal).
        is_ajuste  — True si es cliente de ajuste (unitario=0, sin cobro).
        fvhetota   — total calculado (Decimal).
        codm_remi  — código de movimiento remito (ej. "REMI").
        codm_reci  — código de movimiento recibo (ej. "RECI").

    Retorna:
        (fvhenume, cohenume)  — cohenume es 0 si is_ajuste=True o si no hubo cobro.

    Raises:
        Exception si el cliente no existe o hay error de BD.
    """
    cur = conn.cursor()
    try:
        # Validar que el cliente existe
        cur.execute(
            "SELECT cliecodi FROM linaclie WHERE emprcodi=%s AND cliecodi=%s",
            (empr, cliecodi),
        )
        if not cur.fetchone():
            raise ValueError(f"Cliente {cliecodi} no encontrado.")

        # Siguiente número de remito
        cur.execute(
            "SELECT COALESCE(MAX(fvhenume), 0) + 1 FROM linafvhe WHERE emprcodi=%s AND codmcodi=%s",
            (empr, codm_remi),
        )
        fvhenume = cur.fetchone()[0]

        # Cabecera del remito
        cur.execute(
            "INSERT INTO linafvhe"
            "  (emprcodi, codmcodi, fvhenume, fvhefech, cliecodi, fvhetota, fvheobse, fvhereci)"
            " VALUES (%s, %s, %s, %s, %s, %s, %s, 0)",
            (empr, codm_remi, fvhenume, fvhefech, cliecodi, float(fvhetota), fvheobse),
        )

        # Renglones del remito
        for ln in lineas:
            unit_val = 0.0 if is_ajuste else float(ln["fvdeunit"])
            cur.execute(
                "INSERT INTO linafvde"
                "  (emprcodi, codmcodi, fvhenume, fvdereng, fvhefech,"
                "   articodi, fvdedesc, fvdecant, fvdeunit)"
                " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                (empr, codm_remi, fvhenume, ln["fvdereng"], fvhefech,
                 ln["articodi"], ln["fvdedesc"], ln["fvdecant"], unit_val),
            )

        # Cuenta corriente: DEBE (remito)
        cur.execute(
            "INSERT INTO linactcl"
            "  (emprcodi, cliecodi, ctclfech, codmcodi, ctclnumc, ctcldebe, ctclhabe)"
            " VALUES (%s, %s, %s, %s, %s, %s, 0)",
            (empr, cliecodi, fvhefech, codm_remi, fvhenume, float(fvhetota)),
        )

        # Cobro (solo si no es ajuste y se recibió efectivo o transferencia)
        cohenume = 0
        if not is_ajuste:
            efec_f  = float(efec)
            banc_f  = float(banc)
            cobrado = efec + banc

            if cobrado > 0:
                cobrado_f = float(cobrado)

                # Siguiente número de recibo
                cur.execute(
                    "SELECT COALESCE(MAX(cohenume), 0) + 1 FROM linacohe WHERE emprcodi=%s AND codmcodi=%s",
                    (empr, codm_reci),
                )
                cohenume = cur.fetchone()[0]

                # Cabecera del recibo
                cur.execute(
                    "INSERT INTO linacohe"
                    "  (emprcodi, codmcodi, cohenume, cohefech, cliecodi,"
                    "   cohetota, coheefec, cohebanc, coheobse)"
                    " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    (empr, codm_reci, cohenume, fvhefech, cliecodi,
                     cobrado_f, efec_f, banc_f, fvheobse),
                )

                # Renglones del recibo (descripción del cobro)
                codereng = 1
                _insertar_renglon_recibo(
                    cur, empr, codm_reci, cohenume, codereng,
                    f"Recibido con {codm_remi} N° {fvhenume:{FMT_NROCOMP}} $ {cobrado_f:,.0f}",
                    cobrado_f,
                )
                if efec > 0:
                    codereng += 1
                    _insertar_renglon_recibo(
                        cur, empr, codm_reci, cohenume, codereng,
                        f"{efec_f:,.0f} en Efectivo", 0,
                    )
                if banc > 0:
                    codereng += 1
                    _insertar_renglon_recibo(
                        cur, empr, codm_reci, cohenume, codereng,
                        f"{banc_f:,.0f} en Transf. o Depósito", 0,
                    )

                # Cuenta corriente: HABER (cobro)
                cur.execute(
                    "INSERT INTO linactcl"
                    "  (emprcodi, cliecodi, ctclfech, codmcodi, ctclnumc, ctcldebe, ctclhabe)"
                    " VALUES (%s, %s, %s, %s, %s, 0, %s)",
                    (empr, cliecodi, fvhefech, codm_reci, cohenume, float(cobrado)),
                )

                conc = f"RECI Nº {cohenume:{FMT_NROCOMP}}"[:LEN_CONC_CAJA]

                # Caja (efectivo)
                if efec > 0:
                    cur.execute(
                        "INSERT INTO linacaja"
                        "  (emprcodi, cliecodi, provcodi, cajafech, cajanumc, cajaconc, cajadebe, cajahabe)"
                        " VALUES (%s, %s, 0, %s, %s, %s, 0, %s)",
                        (empr, cliecodi, fvhefech, cohenume, conc, efec_f),
                    )

                # Banco (transferencia)
                if banc > 0:
                    cur.execute(
                        "INSERT INTO linabanc"
                        "  (emprcodi, cliecodi, provcodi, bancfech, bancnumc, bancconc, bancdebe, banchabe)"
                        " VALUES (%s, %s, 0, %s, %s, %s, 0, %s)",
                        (empr, cliecodi, fvhefech, cohenume, conc, banc_f),
                    )

                # Vincular recibo al remito
                cur.execute(
                    "UPDATE linafvhe SET fvhereci=%s"
                    " WHERE emprcodi=%s AND codmcodi=%s AND fvhenume=%s",
                    (cohenume, empr, codm_remi, fvhenume),
                )

    finally:
        cur.close()

    return fvhenume, cohenume


def anular_remito(codm: str, nro: int) -> dict:
    """
    Anula un remito de venta (lógica de anulcomp en LINA22.PRG).

    Pasos (dentro de una transacción):
      1. Elimina todos los renglones (linafvde).
      2. Blanquea la cabecera (linafvhe): cliecodi=0, fvhetota=0, fvhereci=0,
         fvheobse='*** ANULADO ***'.
      3. Elimina el movimiento de cuenta corriente DEBE (linactcl).

    Retorna {"ok": True} o {"ok": False, "error": "..."}.
    """
    empr = ctx_empr.get() or DEFAULT_EMPR_CODE
    conn = sess_conns.get_conn(readonly=False)
    try:
        cur = conn.cursor(dictionary=True)
        # Leer cabecera actual
        cur.execute(
            "SELECT cliecodi, fvhefech, fvhetota, fvheobse"
            "  FROM linafvhe"
            " WHERE emprcodi=%s AND codmcodi=%s AND fvhenume=%s",
            (empr, codm, nro),
        )
        row = cur.fetchone()
        cur.close()

        if not row:
            return {"ok": False, "error": "Comprobante no encontrado."}
        if str(row.get("fvheobse") or "").startswith("*** ANULAD"):
            return {"ok": False, "error": "El comprobante ya fue anulado."}

        cliecodi = int(row["cliecodi"] or 0)
        fvhefech = row["fvhefech"]
        fvhetota = float(row["fvhetota"] or 0)

        cur = conn.cursor()
        # 1. Eliminar renglones
        cur.execute(
            "DELETE FROM linafvde"
            " WHERE emprcodi=%s AND codmcodi=%s AND fvhenume=%s",
            (empr, codm, nro),
        )
        # 2. Blanquear cabecera
        cur.execute(
            "UPDATE linafvhe"
            "   SET cliecodi=0, fvhetota=0, fvhereci=0, fvheobse=%s"
            " WHERE emprcodi=%s AND codmcodi=%s AND fvhenume=%s",
            ("*** ANULADO ***", empr, codm, nro),
        )
        # 3. Eliminar movimiento de ctcl (DEBE)
        cur.execute(
            "DELETE FROM linactcl"
            " WHERE emprcodi=%s AND cliecodi=%s AND ctclfech=%s"
            "   AND codmcodi=%s AND ctclnumc=%s AND ctcldebe=%s"
            " LIMIT 1",
            (empr, cliecodi, fvhefech, codm, nro, fvhetota),
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
