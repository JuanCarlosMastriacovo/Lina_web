"""
rename_prog.py
==============
Renombra un módulo de programa LINA de un código a otro.

jcm beg ************************************************************************
jcm beg ************************************************************************
jcm beg ************************************************************************

Uso:
    python miscelaneas/rename_prog.py LINA41 LINA51
    python miscelaneas/rename_prog.py LINA41 LINA51 --dry-run

jcm end ************************************************************************
jcm end ************************************************************************
jcm end ************************************************************************

Qué hace:
  1. Renombra CapaUI/linaXX.py → CapaUI/linaYY.py
  2. Renombra templates/linaXX/  → templates/linaYY/
  3. Renombra static/js/linaXX.js → static/js/linaYY.js   (si existe)
  4. Renombra static/css/linaXX.css → static/css/linaYY.css (si existe)
  5. Reemplaza texto dentro de todos los archivos afectados:
       linaXX  → linaYY  (minúsculas: rutas, IDs, nombres de función)
       LinaXX  → LinaYY  (CamelCase: nombre de clase Python)
       LINAX   → LINAYY  (mayúsculas: PROG_CODE, constantes)
  6. Imprime las sentencias SQL necesarias para actualizar linaprog y linasafe.

El script NO modifica la base de datos; ejecutar el SQL manualmente.
En --dry-run solo muestra los cambios sin aplicarlos.
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

# ── Raíz del proyecto ──────────────────────────────────────────────────────
ROOT = Path(__file__).resolve().parent.parent


# ── Helpers ────────────────────────────────────────────────────────────────

def _derive(code: str) -> tuple[str, str, str]:
    """Devuelve (UPPER, lower, Camel) a partir de 'LINA41' o 'lina41'."""
    upper  = code.strip().upper()           # LINA41
    lower  = upper.lower()                  # lina41
    camel  = lower[0].upper() + lower[1:]   # Lina41
    return upper, lower, camel


def _collect_files(lower_src: str) -> list[Path]:
    """Archivos de texto que contienen referencias al módulo fuente."""
    candidates = [
        ROOT / "CapaUI" / f"{lower_src}.py",
        ROOT / "static" / "js" / f"{lower_src}.js",
        ROOT / "static" / "css" / f"{lower_src}.css",
    ]
    files: list[Path] = [p for p in candidates if p.is_file()]

    tmpl_dir = ROOT / "templates" / lower_src
    if tmpl_dir.is_dir():
        files.extend(tmpl_dir.rglob("*"))
        files = [f for f in files if f.is_file()]

    return files


def _replace_in_file(path: Path,
                     replacements: list[tuple[str, str]],
                     dry_run: bool) -> bool:
    """Aplica lista de (old, new) al contenido del archivo. Retorna True si hubo cambios."""
    try:
        original = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return False  # binario, saltar

    modified = original
    for old, new in replacements:
        modified = modified.replace(old, new)

    if modified == original:
        return False

    print(f"  [contenido] {path.relative_to(ROOT)}")
    if not dry_run:
        path.write_text(modified, encoding="utf-8")
    return True


def _rename(src: Path, dst: Path, dry_run: bool) -> None:
    tag = "[DRY-RUN] " if dry_run else ""
    print(f"  {tag}[renombrar] {src.relative_to(ROOT)}  →  {dst.relative_to(ROOT)}")
    if not dry_run:
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(src), str(dst))


# ── Main ───────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="Renombra un módulo LINA.")
    parser.add_argument("desde", help="Código origen, ej. LINA41")
    parser.add_argument("hasta", help="Código destino, ej. LINA51")
    parser.add_argument("--dry-run", action="store_true",
                        help="Muestra los cambios sin aplicarlos")
    args = parser.parse_args()

    dry_run = args.dry_run

    src_upper, src_lower, src_camel = _derive(args.desde)
    dst_upper, dst_lower, dst_camel = _derive(args.hasta)

    if src_lower == dst_lower:
        print("ERROR: origen y destino son iguales.")
        sys.exit(1)

    # Verificar que el módulo origen existe
    src_py = ROOT / "CapaUI" / f"{src_lower}.py"
    if not src_py.is_file():
        print(f"ERROR: no se encontró {src_py.relative_to(ROOT)}")
        sys.exit(1)

    # Verificar que el destino NO existe
    dst_py = ROOT / "CapaUI" / f"{dst_lower}.py"
    if dst_py.is_file():
        print(f"ERROR: ya existe {dst_py.relative_to(ROOT)} — renombrado abortado.")
        sys.exit(1)

    print(f"\n{'[DRY-RUN] ' if dry_run else ''}Renombrando {src_upper} → {dst_upper}\n")

    # Orden de reemplazo: primero más específico (CamelCase > UPPER > lower)
    # para evitar sustituciones parciales incorrectas
    replacements = [
        (src_camel, dst_camel),   # Lina41 → Lina51
        (src_upper, dst_upper),   # LINA41 → LINA51
        (src_lower, dst_lower),   # lina41 → lina51
    ]

    # 1. Actualizar contenido de archivos ANTES de renombrar
    #    (así los paths relativos aún son válidos para encontrarlos)
    affected = _collect_files(src_lower)
    print(f"Archivos con contenido a modificar ({len(affected)}):")
    for f in affected:
        _replace_in_file(f, replacements, dry_run)

    # 2. Renombrar archivos individuales
    print("\nArchivos a renombrar:")
    for src_name, dst_name in [
        (f"{src_lower}.py",  f"{dst_lower}.py"),
        (f"{src_lower}.js",  f"{dst_lower}.js"),
        (f"{src_lower}.css", f"{dst_lower}.css"),
    ]:
        for sub in ("CapaUI", "static/js", "static/css"):
            src_path = ROOT / sub / src_name
            dst_path = ROOT / sub / dst_name
            if src_path.is_file():
                _rename(src_path, dst_path, dry_run)

    # 3. Renombrar directorio de templates
    src_tmpl = ROOT / "templates" / src_lower
    dst_tmpl = ROOT / "templates" / dst_lower
    if src_tmpl.is_dir():
        if dst_tmpl.exists():
            print(f"  AVISO: ya existe {dst_tmpl.relative_to(ROOT)}, no se renombra el directorio.")
        else:
            _rename(src_tmpl, dst_tmpl, dry_run)

    # 4. SQL para la base de datos
    print(f"""
SQL para ejecutar en la base de datos:
---------------------------------------
UPDATE linaprog SET progcodi = '{dst_upper}' WHERE progcodi = '{src_upper}';
UPDATE linasafe  SET progcodi = '{dst_upper}' WHERE progcodi = '{src_upper}';
---------------------------------------
""")

    if dry_run:
        print("(dry-run: ningún archivo fue modificado)")
    else:
        print("Renombrado completado. Reiniciar el servidor para que tome efecto.")


if __name__ == "__main__":
    main()
