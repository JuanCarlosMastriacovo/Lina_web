"""
BR-014 — Generador de listados en formato TXT de ancho fijo.

Uso:
    from CapaBRL.txt_brl import generar_txt, col

    columnas = [
        col("Código",      6, "R"),
        col("Descripción", 40, "L"),
        col("Importe",     12, "R"),
    ]
    txt = generar_txt(
        titulo    = "Listado de Clientes",
        subtitulo = "Clientes 0000 al 9999",
        columnas  = columnas,
        filas     = filas,          # list of lists; cada valor debe ser str
        app_name  = APP_CONFIG["app_name"],
        empr_code = empr_code,
        empr_name = empr_name,
        usuario   = usuario,
        fecha     = "24/03/2026",
        hora      = "10:30",
    )

Cada valor en `filas` se convierte a str si no lo es ya.
El llamador es responsable de pre-formatear números (fmt_money, zfill, etc.)
antes de pasar las filas.
"""
from typing import NamedTuple


class col(NamedTuple):
    """Definición de columna para generar_txt."""
    header: str    # texto del encabezado de columna
    width:  int    # ancho fijo en caracteres
    align:  str    # "L" izquierda  |  "R" derecha  |  "C" centrado


_SEP_COL = "  "   # separador entre columnas


def _fmt_cel(val, width: int, align: str) -> str:
    """Ajusta val a width caracteres, truncando si excede."""
    s = str(val) if val is not None else ""
    if len(s) > width:
        s = s[:width]
    if align == "R":
        return s.rjust(width)
    if align == "C":
        return s.center(width)
    return s.ljust(width)


def _sep_line(columnas: list) -> str:
    total = sum(c.width for c in columnas) + len(_SEP_COL) * (len(columnas) - 1)
    return "-" * total


def generar_txt(
    titulo:    str,
    subtitulo: str,
    columnas:  list,          # list[col]
    filas:     list,          # list[list[str]]  — valores ya formateados
    app_name:  str,
    empr_code: str,
    empr_name: str,
    usuario:   str,
    fecha:     str,
    hora:      str,
    totales:   list = None,   # fila opcional de totales (mismo largo que columnas)
) -> str:
    """
    Genera el texto completo del listado.

    Estructura de salida:
        <app_name> — <empr_code> <empr_name>
        <titulo>
        <subtitulo>
        Usuario: <usuario> — <fecha> <hora>
        ----...
        Col1  Col2  ...
        ----...
        fila1
        fila2
        ...
        ----...
        [totales]
        [----...]
        Total: N registros
    """
    sep = _sep_line(columnas)
    lines = [
        f"{app_name} — {empr_code} {empr_name}",
        titulo,
    ]
    if subtitulo:
        lines.append(subtitulo)
    lines.append(f"Usuario: {usuario} — {fecha} {hora}")
    lines.append(sep)

    # Encabezado de columnas (el header respeta la alineación de la columna)
    lines.append(_SEP_COL.join(_fmt_cel(c.header, c.width, c.align) for c in columnas))
    lines.append(sep)

    # Filas de datos
    for fila in filas:
        lines.append(_SEP_COL.join(
            _fmt_cel(v, c.width, c.align)
            for v, c in zip(fila, columnas)
        ))

    lines.append(sep)

    if totales:
        lines.append(_SEP_COL.join(
            _fmt_cel(v, c.width, c.align)
            for v, c in zip(totales, columnas)
        ))
        lines.append(sep)

    n = len(filas)
    lines.append(f"Total: {n} registro{'s' if n != 1 else ''}")

    return "\n".join(lines) + "\n"


def generar_txt_grupos(
    titulo:    str,
    subtitulo: str,
    columnas:  list,          # list[col]
    grupos:    list,          # list[{"label": str, "filas": list[list[str]]}]
    app_name:  str,
    empr_code: str,
    empr_name: str,
    usuario:   str,
    fecha:     str,
    hora:      str,
) -> str:
    """
    Variante de generar_txt para datos agrupados (ej. lista de precios por rubro).

    Estructura de salida:
        <encabezado>
        ----...
        Col1  Col2  ...
        ----...
        Grupo A
        fila1
        fila2

        Grupo B
        ...
        ----...
        Total: N registros
    """
    sep = _sep_line(columnas)
    lines = [
        f"{app_name} — {empr_code} {empr_name}",
        titulo,
    ]
    if subtitulo:
        lines.append(subtitulo)
    lines.append(f"Usuario: {usuario} — {fecha} {hora}")
    lines.append(sep)

    lines.append(_SEP_COL.join(_fmt_cel(c.header, c.width, c.align) for c in columnas))
    lines.append(sep)

    total_filas = 0
    for i, grupo in enumerate(grupos):
        if i > 0:
            lines.append("")
        lines.append(grupo["label"])
        for fila in grupo["filas"]:
            lines.append(_SEP_COL.join(
                _fmt_cel(v, c.width, c.align)
                for v, c in zip(fila, columnas)
            ))
            total_filas += 1

    lines.append(sep)
    lines.append(f"Total: {total_filas} registro{'s' if total_filas != 1 else ''}")

    return "\n".join(lines) + "\n"
