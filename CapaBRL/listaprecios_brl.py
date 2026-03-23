"""
Reglas de negocio para la Lista de Precios (LINA1332).

Cada regla opera sobre las filas crudas [articodi, artidesc, artiprec (float)]
ya filtradas por rubro y recibe/devuelve la lista transformada.
"""

from __future__ import annotations
from typing import List

# Palabras clave que excluyen un artículo de la lista de precios
_DESC_EXCLUIDAS = ("NO HAY", "NO USAR")

# Rubro que se compacta en un único renglón por precio
_RUBRO_MCOM = "MCOM"
_MCOM_DESC  = "Medallas comunes"

# Descripción que se compacta en un único renglón por precio
_DESC_LASER_MATCH = "MEDALLA LASER"
_DESC_LASER_OUT   = "Medallas laser"


def aplicar_reglas(artrcodi: str, filas: List[list]) -> List[list]:
    """
    Aplica todas las reglas de negocio a las filas de un rubro.

    Parámetros
    ----------
    artrcodi : código del rubro (ej. "MCOM")
    filas    : lista de [articodi, artidesc, artiprec_float]

    Retorna la lista transformada (puede quedar vacía).
    """
    filas = _filtrar_precio_cero(filas)
    filas = _filtrar_desc_excluidas(filas)
    filas = _compactar_mcom(artrcodi, filas)
    filas = _compactar_laser(filas)
    return filas


# ── reglas individuales ────────────────────────────────────────────────────────

def _filtrar_precio_cero(filas: List[list]) -> List[list]:
    """Regla 1: omitir artículos con precio = 0."""
    return [f for f in filas if f[2] != 0]


def _filtrar_desc_excluidas(filas: List[list]) -> List[list]:
    """Regla 2: omitir artículos cuya descripción contiene 'NO HAY' o 'NO USAR'."""
    def excluir(desc: str) -> bool:
        upper = desc.upper()
        return any(kw in upper for kw in _DESC_EXCLUIDAS)

    return [f for f in filas if not excluir(f[1])]


def _compactar_mcom(artrcodi: str, filas: List[list]) -> List[list]:
    """
    Regla 3: si el rubro es MCOM, agrupar todos los artículos con el mismo precio
    en un único renglón (código en blanco, descripción fija).
    Precios distintos generan renglones distintos.
    """
    if artrcodi.upper() != _RUBRO_MCOM:
        return filas

    # Agrupar por precio
    precios: dict[float, None] = {}
    for f in filas:
        precios[f[2]] = None   # preserva orden de aparición (Python 3.7+)

    return [["", _MCOM_DESC, precio] for precio in precios]


def _compactar_laser(filas: List[list]) -> List[list]:
    """
    Regla 4: compactar en un único renglón por precio todas las filas cuya
    descripción coincide exactamente con 'Medalla laser' (sin distinguir mayúsc.).
    Las filas no-laser se mantienen en su posición original.
    """
    laser: dict[float, None] = {}
    resto: List[list] = []

    for f in filas:
        if f[1].upper() == _DESC_LASER_MATCH:
            laser[f[2]] = None
        else:
            resto.append(f)

    compactadas = [["", _DESC_LASER_OUT, precio] for precio in laser]
    return compactadas + resto
