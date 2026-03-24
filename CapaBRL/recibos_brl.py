"""
Lógica de negocio para emisión de recibos de cobranza (LINA24).
"""
from decimal import Decimal
from CapaBRL.config import FMT_NROCOMP, LEN_TEXTO_LARGO, LEN_CONC_CAJA


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
