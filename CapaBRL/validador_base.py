"""
validador_base.py
Módulo base reusable para validación de datos en BRL.
"""
from typing import Any, Dict, List, Optional

class BaseValidador:
    """
    Clase base para validación estructurada:
    - Normalización
    - Validación formal
    - Validación de negocio
    """
    def __init__(self, data: dict):
        self.original_data = data or {}
        self.normalized_data = {}
        self.field_errors: Dict[str, str] = {}
        self.form_errors: List[str] = []
        self.is_valid = False

    def normalize(self):
        """Normaliza los datos de entrada. Sobreescribir según entidad."""
        self.normalized_data = self.original_data.copy()

    def validate_formal(self):
        """Valida reglas formales (requerido, tipo, longitud, rango)."""
        pass

    def validate_negocio(self):
        """Valida reglas de negocio específicas."""
        pass

    def validate(self) -> dict:
        self.normalize()
        self.validate_formal()
        self.validate_negocio()
        self.is_valid = not self.field_errors and not self.form_errors
        return {
            'normalized_data': self.normalized_data,
            'field_errors': self.field_errors,
            'form_errors': self.form_errors,
            'is_valid': self.is_valid
        }
