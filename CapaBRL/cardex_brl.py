"""
Lógica de negocio para la ficha de cardex de artículos.
Extraído de CapaUI/lina1341.py (punto 3: cross-layer entanglement).
"""
from datetime import date, timedelta

from CapaBRL.config import DEFAULT_EMPR_CODE, FMT_NROCOMP
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import sess_conns, ctx_empr

LinaArti = get_table_model("linaarti")


def get_cardex(articodi: str, fecha_desde, fecha_hasta: date):
    """
    Calcula el cardex de un artículo en el período indicado.

    Retorna (art_info, filas) donde:
      art_info = {"articodi", "artidesc", "artipmpe", "artiprec"} o None si el artículo no existe.
      filas    = [[fecha_str, concepto, salida_str, entrada_str, saldo_str], ...]
                 La primera fila es siempre la apertura (EXISTENCIA ANTERIOR o SALDO ANTERIOR).
    """
    empr = ctx_empr.get() or DEFAULT_EMPR_CODE

    art = LinaArti.row_get({"articodi": articodi})
    if not art:
        return None, []

    artidesc = str(art.get("artidesc") or "")
    artiexan = int(art.get("artiexan") or 0)
    artiexfe = art.get("artiexfe")
    artipmpe = int(art.get("artipmpe") or 0)
    artiprec = float(art.get("artiprec") or 0)

    conn = sess_conns.get_conn(readonly=True)
    try:
        cur = conn.cursor()
        try:
            # ── Saldo de apertura ───────────────────────────────────────────
            if fecha_desde:
                cur.execute(
                    """SELECT
                           COALESCE((SELECT SUM(fcdecant) FROM linafcde
                                      WHERE emprcodi = %s AND articodi = %s
                                        AND fchefech < %s), 0)
                         - COALESCE((SELECT SUM(fvdecant) FROM linafvde
                                      WHERE emprcodi = %s AND articodi = %s
                                        AND fvhefech < %s), 0)""",
                    (empr, articodi, fecha_desde, empr, articodi, fecha_desde),
                )
                delta        = int(cur.fetchone()[0] or 0)
                saldo_ini    = artiexan + delta
                apertura_fec = fecha_desde - timedelta(days=1)
                apertura_lbl = f"SALDO AL {apertura_fec.strftime('%d/%m/%Y')}"
            else:
                saldo_ini    = artiexan
                apertura_fec = artiexfe if isinstance(artiexfe, date) else None
                apertura_lbl = "EXISTENCIA ANTERIOR"

            # ── Entradas (compras) ──────────────────────────────────────────
            params_e = [empr, articodi]
            cond_e   = ""
            if fecha_desde:
                cond_e += " AND fchefech >= %s"; params_e.append(fecha_desde)
            cond_e += " AND fchefech <= %s"; params_e.append(fecha_hasta)

            cur.execute(
                f"SELECT fchefech, codmcodi, fchenume, fcdecant "
                f"  FROM linafcde "
                f" WHERE emprcodi = %s AND articodi = %s{cond_e} "
                f" ORDER BY fchefech, fchenume",
                params_e,
            )
            entradas = [(*row, "E") for row in cur.fetchall()]

            # ── Salidas (ventas) ────────────────────────────────────────────
            params_s = [empr, articodi]
            cond_s   = ""
            if fecha_desde:
                cond_s += " AND fvhefech >= %s"; params_s.append(fecha_desde)
            cond_s += " AND fvhefech <= %s"; params_s.append(fecha_hasta)

            cur.execute(
                f"SELECT fvhefech, codmcodi, fvhenume, fvdecant "
                f"  FROM linafvde "
                f" WHERE emprcodi = %s AND articodi = %s{cond_s} "
                f" ORDER BY fvhefech, fvhenume",
                params_s,
            )
            salidas = [(*row, "S") for row in cur.fetchall()]

        finally:
            cur.close()
    finally:
        sess_conns.release_conn(conn)

    # ── Combinar, ordenar y construir filas ────────────────────────────────
    movs = sorted(entradas + salidas, key=lambda r: (r[0], r[2]))

    def fmt_fec(d):
        return d.strftime("%d/%m/%Y") if d else "---"

    saldo = saldo_ini
    filas = [[fmt_fec(apertura_fec), apertura_lbl, "", "", str(saldo)]]

    for fec, codm, nro, cant, tipo in movs:
        concepto = f"{str(codm).strip()} {int(nro):{FMT_NROCOMP}}"
        cant     = int(cant or 0)
        if tipo == "E":
            saldo  += cant
            filas.append([fmt_fec(fec), concepto, "", str(cant), str(saldo)])
        else:
            saldo  -= cant
            filas.append([fmt_fec(fec), concepto, str(cant), "", str(saldo)])

    art_info = {
        "articodi": articodi,
        "artidesc": artidesc,
        "artipmpe": artipmpe,
        "artiprec": artiprec,
    }
    return art_info, filas
