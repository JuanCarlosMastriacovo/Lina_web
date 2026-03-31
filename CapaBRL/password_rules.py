"""
BR-017 — Reglas de contraseña compartidas entre lina541 (ABM usuarios) y
lina542 (cambio de contraseña propia).
"""
import re
import hashlib

# Contraseñas obviamente débiles (secuencias, repeticiones)
OBVIOUS_PASSWORDS = {
    "12345678", "123456789", "1234567890",
    "abcdefgh", "abcdefghi", "qwertyui",
    "password", "contraseña", "passpass",
}


def hash_password(raw: str) -> str:
    """SHA-256 hex digest (minúsculas) de la contraseña en texto plano."""
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def verify_password(raw: str, stored_hash: str) -> bool:
    """
    Compara texto plano contra el hash almacenado.
    Case-insensitive: el hash puede ser upper (MySQL SHA2) o lower (Python).
    """
    return hash_password(raw).lower() == stored_hash.lower()


def validate_password(raw: str, usercodi: str) -> str | None:
    """
    Valida complejidad de contraseña según BR-017.
    Retorna mensaje de error o None si es válida.
    """
    if len(raw) < 8:
        return "La contraseña debe tener al menos 8 caracteres."
    has_upper  = bool(re.search(r'[A-Z]', raw))
    has_lower  = bool(re.search(r'[a-z]', raw))
    has_digit  = bool(re.search(r'\d',    raw))
    has_symbol = bool(re.search(r'[^A-Za-z0-9]', raw))
    if (has_upper + has_lower + has_digit + has_symbol) < 3:
        return (
            "La contraseña debe contener al menos 3 de los 4 grupos: "
            "mayúsculas, minúsculas, números y símbolos."
        )
    if raw.upper() == usercodi.upper():
        return "La contraseña no puede ser igual al código de usuario."
    if raw.lower() in OBVIOUS_PASSWORDS:
        return "La contraseña es demasiado obvia. Elija una más segura."
    return None
