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


class RecodeIntValidador(BaseValidador):
    """
    Validador genérico para cambio de código (recode) de entidades con clave entera.
    Subclasear y definir: table_model, key_field, code_min, code_max.
    """
    table_model = None
    key_field:  str = ""
    code_min:   int = 0
    code_max:   int = 9_999_999

    def normalize(self):
        try:
            old = int(self.original_data.get("old_code"))
        except (TypeError, ValueError):
            old = None
        try:
            new = int(self.original_data.get("new_code"))
        except (TypeError, ValueError):
            new = None
        self.normalized_data = {"old_code": old, "new_code": new}

    def validate_formal(self):
        old = self.normalized_data.get("old_code")
        new = self.normalized_data.get("new_code")
        if new is None:
            self.field_errors["new_code"] = "El nuevo código debe ser un número entero válido."
            return
        if old is None:
            self.field_errors["new_code"] = "El código actual es inválido."
            return
        if not (self.code_min <= new <= self.code_max):
            self.field_errors["new_code"] = f"El nuevo código debe estar entre {self.code_min} y {self.code_max}."
            return
        if new == old:
            self.field_errors["new_code"] = "El nuevo código debe ser distinto al actual."

    def validate_negocio(self):
        if "new_code" in self.field_errors:
            return
        conn = self.original_data.get("conn")
        new  = self.normalized_data.get("new_code")
        if self.table_model and self.key_field:
            if self.table_model.row_get({self.key_field: new}, conn=conn):
                self.field_errors["new_code"] = f"El código {new} ya existe."
