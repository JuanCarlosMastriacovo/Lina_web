"""
BR-cpbte — Recuperación e impresión de comprobantes.

Claves de entrada:
    clpr : "C" (ventas/cobros) | "P" (compras/pagos)
    codm : código de movimiento en linacodm (ej. "REMI", "RECI")
    nume : número de comprobante (int)

Uso típico:
    from CapaBRL.cpbte_brl import get_cpbte, generar_cpbte_txt, CpbteData
    datos = get_cpbte("C", "REMI", 1)
    if datos is None:
        ...  # no encontrado
"""
from dataclasses import dataclass, field
from datetime import date, datetime
from typing import List, Optional

from CapaBRL.config import DEFAULT_EMPR_CODE, FMT_NROCOMP
from CapaBRL.formatters import fmt_money
from CapaDAL.dataconn import sess_conns, ctx_empr


# ── Tipos de datos ─────────────────────────────────────────────────────────────

@dataclass
class RengRemi:
    """Renglón de un remito (artículo, cantidad, precio)."""
    reng:     int
    articodi: str
    desc:     str
    cant:     int
    unit:     float

    @property
    def subtotal(self) -> float:
        return self.cant * self.unit


@dataclass
class RengReci:
    """Renglón de un recibo (concepto, importe)."""
    reng: int
    desc: str
    unit: float


@dataclass
class CpbteData:
    """Datos completos de un comprobante listos para imprimir."""
    clpr:          str              # "C" | "P"
    codm:          str              # ej. "REMI" | "RECI"
    nume:          int
    fecha:         date
    titulo1:       str              # "Detalle de Artículos Entregados" …
    titulo2:       str              # "REMITO 000001 de Fecha 24/03/2026"
    contacto_cod:  str              # cliecodi/provcodi zfill(4)
    contacto_nom:  str              # cliename/provname
    total:         float
    obse:          str
    es_remi:       bool             # True → REMI, False → RECI
    es_ventas:     bool             # True → ventas (C), False → compras (P)
    renglones_remi: List[RengRemi] = field(default_factory=list)
    renglones_reci: List[RengReci] = field(default_factory=list)
    saldo:         Optional[float] = None   # saldo cta cte cliente (solo ventas)
    reci_vinculado_num:   Optional[int]   = None  # REMI ventas: recibo asociado
    reci_vinculado_total: Optional[float] = None


# ── Configuración de tablas por (clpr, codm) ──────────────────────────────────
#
# Cada entrada define cómo leer cabecera, detalle y contacto para esa
# combinación de tipo de comprobante.

_TABLES = {
    ("C", "REMI"): {
        "cabe_table": "linafvhe",
        "cabe_pk":    "fvhenume",
        "cabe_fech":  "fvhefech",
        "cabe_ctct":  "cliecodi",
        "cabe_total": "fvhetota",
        "cabe_obse":  "fvheobse",
        "cabe_reci":  "fvhereci",   # campo que vincula al recibo de cobro
        "deta_table": "linafvde",
        "deta_pk":    "fvhenume",
        "deta_reng":  "fvdereng",
        "deta_arti":  "articodi",
        "deta_desc":  "fvdedesc",
        "deta_cant":  "fvdecant",
        "deta_unit":  "fvdeunit",
        "ctct_table": "linaclie",
        "ctct_pk":    "cliecodi",
        "ctct_name":  "cliename",
        "titulo1":    "Detalle de Artículos Entregados",
        "titulo_doc": "REMITO",
        "es_remi":    True,
        "es_ventas":  True,
    },
    ("C", "RECI"): {
        "cabe_table": "linacohe",
        "cabe_pk":    "cohenume",
        "cabe_fech":  "cohefech",
        "cabe_ctct":  "cliecodi",
        "cabe_total": "cohetota",
        "cabe_obse":  "coheobse",
        "cabe_reci":  None,
        "deta_table": "linacode",
        "deta_pk":    "cohenume",
        "deta_reng":  "codereng",
        "deta_arti":  None,
        "deta_desc":  "codedesc",
        "deta_cant":  None,
        "deta_unit":  "codeunit",
        "ctct_table": "linaclie",
        "ctct_pk":    "cliecodi",
        "ctct_name":  "cliename",
        "titulo1":    "Pago recibido",
        "titulo_doc": "RECIBO",
        "es_remi":    False,
        "es_ventas":  True,
    },
    ("P", "REMI"): {
        "cabe_table": "linafche",
        "cabe_pk":    "fchenume",
        "cabe_fech":  "fchefech",
        "cabe_ctct":  "provcodi",
        "cabe_total": "fchetota",
        "cabe_obse":  "fcheobse",
        "cabe_reci":  None,
        "deta_table": "linafcde",
        "deta_pk":    "fchenume",
        "deta_reng":  "fcdereng",
        "deta_arti":  "articodi",
        "deta_desc":  "fcdedesc",
        "deta_cant":  "fcdecant",
        "deta_unit":  "fcdeunit",
        "ctct_table": "linaprov",
        "ctct_pk":    "provcodi",
        "ctct_name":  "provname",
        "titulo1":    "Detalle de Artículos Recibidos",
        "titulo_doc": "REMITO",
        "es_remi":    True,
        "es_ventas":  False,
    },
    ("P", "RECI"): {
        "cabe_table": "linapahe",
        "cabe_pk":    "pahenume",
        "cabe_fech":  "pahefech",
        "cabe_ctct":  "provcodi",
        "cabe_total": "pahetota",
        "cabe_obse":  "paheobse",
        "cabe_reci":  None,
        "deta_table": "linapade",
        "deta_pk":    "pahenume",
        "deta_reng":  "padereng",
        "deta_arti":  None,
        "deta_desc":  "padedesc",
        "deta_cant":  None,
        "deta_unit":  "padeunit",
        "ctct_table": "linaprov",
        "ctct_pk":    "provcodi",
        "ctct_name":  "provname",
        "titulo1":    "Pago Efectuado",
        "titulo_doc": "RECIBO",
        "es_remi":    False,
        "es_ventas":  False,
    },
}


# ── Función pública ────────────────────────────────────────────────────────────

def get_cpbte(clpr: str, codm: str, nume: int) -> Optional[CpbteData]:
    """
    Recupera todos los datos de un comprobante.

    Gestiona su propia conexión del pool (no requiere task conn).
    Retorna None si la combinación (clpr, codm, nume) no existe.
    """
    empr = ctx_empr.get() or DEFAULT_EMPR_CODE
    clpr = clpr.upper().strip()
    codm = codm.upper().strip()
    conn = sess_conns.get_conn(readonly=True)
    try:
        cur = conn.cursor(dictionary=True)
        try:
            return _fetch(empr, clpr, codm, int(nume), cur)
        finally:
            cur.close()
    finally:
        sess_conns.release_conn(conn)


# ── Implementación interna ─────────────────────────────────────────────────────

def _fetch(empr: str, clpr: str, codm: str, nume: int, cur) -> Optional[CpbteData]:
    cfg = _TABLES.get((clpr, codm))
    if cfg is None:
        return None

    # ── Cabecera ──────────────────────────────────────────────────────────────
    cur.execute(
        f"SELECT * FROM {cfg['cabe_table']}"
        f" WHERE emprcodi=%s AND codmcodi=%s AND {cfg['cabe_pk']}=%s",
        (empr, codm, nume),
    )
    cabe = cur.fetchone()
    if not cabe:
        return None

    fecha = cabe.get(cfg["cabe_fech"])
    if isinstance(fecha, datetime):
        fecha = fecha.date()

    ctct_cod = int(cabe.get(cfg["cabe_ctct"]) or 0)
    total    = float(cabe.get(cfg["cabe_total"]) or 0)
    obse     = str(cabe.get(cfg["cabe_obse"]) or "").strip()

    # ── Contacto (nombre) ────────────────────────────────────────────────────
    cur.execute(
        f"SELECT {cfg['ctct_name']} FROM {cfg['ctct_table']}"
        f" WHERE emprcodi=%s AND {cfg['ctct_pk']}=%s LIMIT 1",
        (empr, ctct_cod),
    )
    ctct_row = cur.fetchone() or {}
    ctct_nom = str(ctct_row.get(cfg["ctct_name"]) or "").strip()

    # ── Recibo vinculado (solo ventas REMI) ──────────────────────────────────
    reci_vinculado_num   = None
    reci_vinculado_total = None
    if cfg["cabe_reci"]:
        reci_raw = int(cabe.get(cfg["cabe_reci"]) or 0)
        if reci_raw:
            reci_vinculado_num = reci_raw
            cur.execute(
                "SELECT cohetota FROM linacohe"
                " WHERE emprcodi=%s AND cohenume=%s LIMIT 1",
                (empr, reci_raw),
            )
            reci_row = cur.fetchone() or {}
            reci_vinculado_total = float(reci_row.get("cohetota") or 0)

    # ── Saldo cuenta corriente (solo ventas) ─────────────────────────────────
    saldo = None
    if cfg["es_ventas"]:
        cur.execute(
            "SELECT COALESCE(SUM(ctcldebe),0) - COALESCE(SUM(ctclhabe),0) AS saldo"
            "  FROM linactcl"
            " WHERE emprcodi=%s AND cliecodi=%s",
            (empr, ctct_cod),
        )
        saldo_row = cur.fetchone() or {}
        saldo = float(saldo_row.get("saldo") or 0)

    # ── Renglones ─────────────────────────────────────────────────────────────
    cur.execute(
        f"SELECT * FROM {cfg['deta_table']}"
        f" WHERE emprcodi=%s AND codmcodi=%s AND {cfg['deta_pk']}=%s"
        f" ORDER BY {cfg['deta_reng']}",
        (empr, codm, nume),
    )
    rows = cur.fetchall()

    renglones_remi: List[RengRemi] = []
    renglones_reci: List[RengReci] = []

    if cfg["es_remi"]:
        for r in rows:
            renglones_remi.append(RengRemi(
                reng     = int(r.get(cfg["deta_reng"]) or 0),
                articodi = str(r.get(cfg["deta_arti"]) or "").strip(),
                desc     = str(r.get(cfg["deta_desc"]) or ""),
                cant     = int(r.get(cfg["deta_cant"]) or 0),
                unit     = float(r.get(cfg["deta_unit"]) or 0),
            ))
    else:
        for r in rows:
            renglones_reci.append(RengReci(
                reng = int(r.get(cfg["deta_reng"]) or 0),
                desc = str(r.get(cfg["deta_desc"]) or ""),
                unit = float(r.get(cfg["deta_unit"]) or 0),
            ))

    # ── Armar resultado ───────────────────────────────────────────────────────
    nro_fmt   = f"{nume:{FMT_NROCOMP}}"
    fecha_fmt = fecha.strftime("%d/%m/%Y") if fecha else ""
    titulo2   = f"{cfg['titulo_doc']} {nro_fmt} de Fecha {fecha_fmt}"

    return CpbteData(
        clpr          = clpr,
        codm          = codm,
        nume          = nume,
        fecha         = fecha or date.today(),
        titulo1       = cfg["titulo1"],
        titulo2       = titulo2,
        contacto_cod  = str(ctct_cod).zfill(4),
        contacto_nom  = ctct_nom,
        total         = total,
        obse          = obse,
        es_remi       = cfg["es_remi"],
        es_ventas     = cfg["es_ventas"],
        renglones_remi          = renglones_remi,
        renglones_reci          = renglones_reci,
        saldo                   = saldo,
        reci_vinculado_num      = reci_vinculado_num,
        reci_vinculado_total    = reci_vinculado_total,
    )


# ── Generación de TXT ──────────────────────────────────────────────────────────
#
# Reproduce el layout fijo de zprtc.prg:
#   REMI: Codigo(0) Descripcion(10) Cant.(51) Unitario(57) Subtotal(69)
#   RECI: Concepto(13)              Importe(55)

_SEP_REMI = "-" * 81
_SEP_RECI = "-" * 67


def _place(buf: list, col: int, text: str, width: int, rjust: bool = False) -> None:
    s = str(text or "")[:width]
    s = s.rjust(width) if rjust else s.ljust(width)
    for i, c in enumerate(s):
        if col + i < len(buf):
            buf[col + i] = c


def _remi_row(articodi: str, desc: str, cant: int, unit: float, subtotal: float) -> str:
    buf = [" "] * 81
    _place(buf,  0, articodi,                               9)
    _place(buf, 10, desc,                                  40)
    _place(buf, 51, str(cant) if cant else "",              5, rjust=True)
    _place(buf, 57, fmt_money(unit) if unit else "",       12, rjust=True)
    _place(buf, 69, fmt_money(subtotal) if subtotal else "",12, rjust=True)
    return "".join(buf)


def _remi_totals(total_cant: int, total: float) -> str:
    buf = [" "] * 81
    _place(buf,  0, "Totales",               7)
    _place(buf, 51, str(total_cant),         5, rjust=True)
    _place(buf, 69, fmt_money(total),       12, rjust=True)
    return "".join(buf)


def _reci_row(desc: str, unit: float) -> str:
    buf = [" "] * 67
    _place(buf, 13, desc,                              40)
    _place(buf, 55, fmt_money(unit) if unit else "",   12, rjust=True)
    return "".join(buf)


def _reci_total_row(total: float) -> str:
    buf = [" "] * 67
    _place(buf, 49, "Total",     5)
    _place(buf, 55, fmt_money(total), 12, rjust=True)
    return "".join(buf)


def generar_cpbte_txt(
    datos:     CpbteData,
    app_name:  str,
    empr_code: str,
    empr_name: str,
    usuario:   str,
    fecha:     str,
    hora:      str,
) -> str:
    """Genera el texto completo del comprobante en formato fijo (80 col)."""
    sep = _SEP_REMI if datos.es_remi else _SEP_RECI

    lines = [
        f"{app_name} — {empr_code} {empr_name}",
        datos.titulo1,
        datos.titulo2,
        f"Sr(es) {datos.contacto_nom} ({datos.contacto_cod})",
        f"Usuario: {usuario} — {fecha} {hora}",
        sep,
    ]

    if datos.es_remi:
        # Encabezado de columnas
        hdr = _remi_row("Codigo", "Descripcion", 0, 0, 0)
        # Reemplazar la cabecera con el texto correcto (sin valores numéricos)
        hdr_buf = [" "] * 81
        _place(hdr_buf,  0, "Codigo",      9)
        _place(hdr_buf, 10, "Descripcion", 40)
        _place(hdr_buf, 51, "Cant.",        5, rjust=True)
        _place(hdr_buf, 57, "Unitario",    12, rjust=True)
        _place(hdr_buf, 69, "Subtotal",    12, rjust=True)
        lines.append("".join(hdr_buf))
        lines.append(sep)

        total_cant = 0
        for r in datos.renglones_remi:
            lines.append(_remi_row(r.articodi, r.desc, r.cant, r.unit, r.subtotal))
            total_cant += r.cant

        lines.append(sep)

        # Separadores de doble línea
        sep2_buf = [" "] * 81
        _place(sep2_buf, 51, "-----",       5)
        _place(sep2_buf, 69, "-----------", 11)
        lines.append("".join(sep2_buf))

        lines.append(_remi_totals(total_cant, datos.total))

        sep3_buf = [" "] * 81
        _place(sep3_buf, 51, "=====",       5)
        _place(sep3_buf, 69, "===========", 11)
        lines.append("".join(sep3_buf))

        if datos.reci_vinculado_num:
            reci_nro = f"{datos.reci_vinculado_num:{FMT_NROCOMP}}"
            reci_tot = fmt_money(datos.reci_vinculado_total or 0)
            lines.append(f"Recibido pago Nro. {reci_nro} por $ {reci_tot}")

    else:
        # RECI
        hdr_buf = [" "] * 67
        _place(hdr_buf, 13, "Concepto",  40)
        _place(hdr_buf, 55, "Importe",   12, rjust=True)
        lines.append("".join(hdr_buf))
        lines.append(sep)

        for r in datos.renglones_reci:
            lines.append(_reci_row(r.desc, r.unit))

        lines.append(sep)

        sep2_buf = [" "] * 67
        _place(sep2_buf, 55, "-----------", 11)
        lines.append("".join(sep2_buf))

        lines.append(_reci_total_row(datos.total))

        sep3_buf = [" "] * 67
        _place(sep3_buf, 55, "===========", 11)
        lines.append("".join(sep3_buf))

    if datos.saldo is not None:
        lines.append(f"Saldo de su Cuenta a la fecha   $ {fmt_money(datos.saldo)}")
    if datos.obse:
        lines.append(f"Obs.: {datos.obse}")

    return "\n".join(lines) + "\n"
