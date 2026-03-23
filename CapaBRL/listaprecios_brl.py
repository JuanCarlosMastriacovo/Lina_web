"""
Reglas de negocio para LINA1332 - Lista de Precios.

Cada fila de entrada es: [articodi: str, artidesc: str, artiprec: float]
"""

_EXCLUIR_DESC = ("NO HAY", "NO USAR")
_RUBRO_MCOM   = "MCOM"
_DESC_LASER   = "MEDALLA LASER"


def aplicar_reglas(artrcodi: str, filas: list) -> list:
    """
    Aplica las reglas de negocio sobre las filas de un grupo (rubro).

    Reglas (en orden):
      1. Omitir artículos con precio = 0.
      2. Omitir artículos cuya descripción contenga "NO HAY" o "NO USAR".
      3. Si el rubro es MCOM: compactar todos en un único renglón
         (cod='', desc='Todas las medallas comunes', precio predominante).
      4. Compactar artículos con descripción exacta "MEDALLA LASER" y mismo precio
         en un único renglón (cod='', desc='Medallas laser').

    Retorna la lista de filas filtrada/compactada.
    """
    # Reglas 1 y 2
    filas = [
        f for f in filas
        if f[2] != 0
        and not any(excl in (f[1] or "").upper() for excl in _EXCLUIR_DESC)
    ]

    # Regla 3: compactar rubro MCOM
    if artrcodi.upper() == _RUBRO_MCOM and filas:
        precio = _precio_predominante([f[2] for f in filas])
        return [["", "Todas las medallas comunes", precio]]

    # Regla 4: compactar "Medalla laser" con mismo precio
    laser = [f for f in filas if (f[1] or "").upper().strip() == _DESC_LASER]
    if laser:
        resto  = [f for f in filas if (f[1] or "").upper().strip() != _DESC_LASER]
        precio = _precio_predominante([f[2] for f in laser])
        resto.append(["", "Medallas laser", precio])
        filas  = resto

    return filas


def _precio_predominante(precios: list) -> float:
    """Devuelve el precio más frecuente; en empate, el menor."""
    from collections import Counter
    conteo   = Counter(precios)
    max_freq = max(conteo.values())
    return min(p for p, c in conteo.items() if c == max_freq)
