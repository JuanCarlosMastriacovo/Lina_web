# Script para capitalizar la primera letra de cada palabra y dejar el resto en minúsculas
# Uso: puedes importar la función o ejecutarla sobre una lista de strings

def capitalize_first(s: str) -> str:
    """Convierte un string a solo la primera letra en mayúscula y el resto en minúscula."""
    if not s:
        return s
    return s[0].upper() + s[1:].lower()

if __name__ == "__main__":
    # Ejemplo de uso interactivo
    ejemplos = [
        "EJEMPLO",
        "otro ejemplo",
        "GRUPO",
        "áÉÍÓÚñ",
        "",
        None
    ]
    for texto in ejemplos:
        print(f"'{texto}' -> '{capitalize_first(texto) if texto is not None else None}'")
