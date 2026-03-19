"""CLI para ejecutar Krpt y copiar el resultado al portapapeles."""

from __future__ import annotations

import subprocess
import sys

from krpt import Krpt


def copy_to_clipboard(text: str) -> bool:
    """Intenta copiar texto al portapapeles priorizando mecanismos nativos de Windows."""
    if sys.platform.startswith("win"):
        try:
            # Metodo mas estable en Windows PowerShell.
            completed = subprocess.run(
                ["powershell", "-NoProfile", "-Command", "$input | Set-Clipboard"],
                input=text,
                text=True,
                capture_output=True,
                check=False,
            )
            if completed.returncode == 0:
                return True
        except Exception:
            pass

        try:
            completed = subprocess.run(
                "clip",
                input=text,
                text=True,
                shell=True,
                check=False,
            )
            return completed.returncode == 0
        except Exception:
            return False

    try:
        import tkinter as tk

        root = tk.Tk()
        root.withdraw()
        root.clipboard_clear()
        root.clipboard_append(text)
        root.update()
        root.destroy()
        return True
    except Exception:
        pass

    return False


def get_clipboard_text() -> str | None:
    """Obtiene texto del portapapeles con tkinter y fallback a PowerShell en Windows."""
    try:
        import tkinter as tk

        root = tk.Tk()
        root.withdraw()
        value = root.clipboard_get()
        root.destroy()
        return str(value)
    except Exception:
        pass

    if sys.platform.startswith("win"):
        try:
            completed = subprocess.run(
                ["powershell", "-NoProfile", "-Command", "Get-Clipboard"],
                capture_output=True,
                text=True,
                check=False,
            )
            if completed.returncode == 0:
                return completed.stdout.rstrip("\r\n")
        except Exception:
            return None

    return None


def main() -> None:
    print("Modo ciclico activo. Presiona Ctrl+C para salir.")
    while True:
        k = input("\nIngresa el string k (Enter para usar portapapeles): ")
        if k == "":
            clipboard_value = get_clipboard_text()
            if clipboard_value is None:
                print("No se pudo leer el portapapeles.")
                continue
            k = clipboard_value

        result = Krpt(k)

        print("Resultado:")
        print(result)
        if result == "":
            print("(resultado vacio)")

        if copy_to_clipboard(result):
            print("Copiado al portapapeles.")
        else:
            print("No se pudo copiar al portapapeles.")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nSalida por Ctrl+C.")
