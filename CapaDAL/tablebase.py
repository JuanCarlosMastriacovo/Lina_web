from typing import List, Dict, Any, Optional, Type
from .dataconn import sess_conns, ctx_empr
from CapaBRL.config import SELECTOR_MAX_ROWS
    

_TABLE_MODEL_CACHE: Dict[str, Type["TableBase"]] = {}


def _normalize_row_keys(row: Dict[str, Any]) -> Dict[str, Any]:
    """Normaliza claves de filas dictionary=True a minúsculas."""
    return {str(key).lower(): value for key, value in (row or {}).items()}

class TableBase:
    """
    Clase base para modelos de tabla DAL. Provee helpers para obtener metadatos y campos clave,
    facilitando la integración con routers y vistas tipo master-detail.
    """
    @classmethod
    def get_table_ui_metadata(cls, conn=None) -> dict:
        """
        Devuelve metadatos útiles para UI: tooltips de campos y descripción de tabla.
        """
        field_tooltips = cls.get_column_comments(conn=conn)
        # Aquí se pueden agregar tooltips literales para campos calculados/no de tabla si se requiere
        table_description = cls.get_table_comment(conn=conn)
        return {
            "field_tooltips": field_tooltips,
            "table_description": table_description,
        }

    @classmethod
    def get_code_label_fields(cls) -> tuple[str, str]:
        """
        Devuelve (campo_codigo, campo_etiqueta) recomendados para selector.
        """
        selector = cls.get_selector_fields()
        return selector[0], selector[1] if len(selector) > 1 else selector[0]

    @classmethod
    def get_company_and_key_fields(cls) -> tuple[str, str]:
        """
        Devuelve (campo_empresa, campo_clave_negocio) para uso en restricciones y queries.
        """
        return cls.get_company_field_required(), cls.get_business_key_field()
    @classmethod
    def row_get_case_insensitive(cls, field: str, value: str, conn=None) -> dict:
        """Obtiene un registro por un campo, ignorando mayúsculas/minúsculas."""
        company_field = cls.get_company_field_required()
        query = (
            f"SELECT * FROM {cls.TABLE_NAME} "
            f"WHERE {company_field} = %s AND UPPER({field}) = UPPER(%s) LIMIT 1"
        )
        _conn = conn or sess_conns.get_conn(readonly=True)
        try:
            cur = _conn.cursor(dictionary=True)
            cur.execute(query, (ctx_empr.get(), value))
            row = cur.fetchone() or {}
            cur.close()
            return row
        finally:
            if not conn:
                sess_conns.release_conn(_conn)
    @classmethod
    def search_by_fields(cls, campo_cod: str, campo_desc: str, term: str, limit: int = SELECTOR_MAX_ROWS, conn=None) -> list:
        """Busca registros con LIKE en dos campos específicos con filtro de empresa."""
        like          = f"%{term}%"
        company_field = cls.get_company_field_required()
        query = (
            f"SELECT {campo_cod}, {campo_desc} FROM {cls.TABLE_NAME} "
            f"WHERE {company_field} = %s "
            f"AND ({campo_desc} LIKE %s OR CAST({campo_cod} AS CHAR) LIKE %s) "
            f"ORDER BY {campo_cod} LIMIT {limit}"
        )
        _conn = conn or sess_conns.get_conn(readonly=True)
        try:
            cur = _conn.cursor(dictionary=True)
            cur.execute(query, (ctx_empr.get(), like, like))
            return cur.fetchall()
        finally:
            if not conn:
                sess_conns.release_conn(_conn)

    @classmethod
    def search_selector(cls, search_term: str, sort_field: str, conn=None) -> list[dict]:
        """Busca registros para selector usando LIKE en clave y etiqueta."""
        like = f"%{search_term}%"
        code_field = cls.get_business_key_field()
        label_field = cls.get_selector_fields()[1]
        query = (
            f"SELECT {code_field}, {label_field} FROM {cls.TABLE_NAME} "
            f"WHERE {cls.get_company_field_required()} = %s "
            f"AND (CAST({code_field} AS CHAR) LIKE %s OR {label_field} LIKE %s) "
            f"ORDER BY {sort_field}"
        )
        _conn = conn or sess_conns.get_conn(readonly=True)
        try:
            cur = _conn.cursor(dictionary=True)
            cur.execute(query, (ctx_empr.get(), like, like))
            return cur.fetchall()
        finally:
            if not conn:
                sess_conns.release_conn(_conn)

    @classmethod
    def has_children(cls, relation: dict, parent_values: dict, conn=None) -> bool:
        """
        Chequea si existen hijos relacionados para una relación dada.
        parent_values debe contener los campos PK requeridos (incluyendo empresa si aplica).
        """
        child_table = cls._get_table_class(relation["table"])
        where, params = cls._relation_where_and_params(relation, parent_values)
        query = f"SELECT 1 FROM {child_table.TABLE_NAME} WHERE {where} LIMIT 1"
        _conn = conn or sess_conns.get_conn(readonly=True)
        try:
            cur = _conn.cursor()
            cur.execute(query, params)
            return cur.fetchone() is not None
        finally:
            if not conn:
                sess_conns.release_conn(_conn)

    @classmethod
    def row_exists(cls, pk_values: Dict[str, Any], conn=None) -> bool:
        """
        Verifica si ya existe un registro con la PK dada.
        Uso típico: previo a una inserción, para evitar duplicados.

        Returns:
            True  → el registro YA existe   (la inserción debería abortarse)
            False → el registro no existe   (se puede insertar)
        """
        pk_values = pk_values.copy()
        _conn = conn or sess_conns.get_conn(readonly=True)
        try:
            if not cls._ensure_metadata(conn=_conn):
                raise ValueError(f"No se pudo cargar metadata para {cls.TABLE_NAME}")
            company_field = cls.get_company_field()
            if company_field and company_field in cls.PK_FIELDS and company_field not in pk_values:
                pk_values[company_field] = cls._get_empr()

            where = " AND ".join([f"{f} = %s" for f in cls.PK_FIELDS])
            query = f"SELECT 1 FROM {cls.TABLE_NAME} WHERE {where} LIMIT 1"
            cur = _conn.cursor()
            cur.execute(query, [pk_values[f] for f in cls.PK_FIELDS])
            return cur.fetchone() is not None
        except Exception as e:
            print(f"CapaDAL Error (row_exists {cls.TABLE_NAME}): {e}")
            return False
        finally:
            if not conn:
                sess_conns.release_conn(_conn)

    @classmethod
    def row_got_parents(cls, data: Dict[str, Any], conn=None) -> bool:
        """
        Verifica que existan todos los registros padre requeridos por las FK
        antes de insertar un registro hijo.
        Itera sobre FOREIGN_KEYS cargadas desde metadata.

        Si una columna FK no está presente en data (campo nullable/opcional),
        esa FK se omite — no se puede verificar lo que no se conoce.

        Returns:
            True  → todos los padres existen   (se puede insertar)
            False → al menos un padre falta    (la inserción debería abortarse)
        """
        data = data.copy()
        _conn = conn or sess_conns.get_conn(readonly=True)
        try:
            if not cls._ensure_metadata(conn=_conn):
                raise ValueError(f"No se pudo cargar metadata para {cls.TABLE_NAME}")

            for fk in cls.FOREIGN_KEYS:
                parent_table_name = fk["referenced_table"]
                child_cols        = fk["columns"]            # columnas FK en esta tabla
                parent_cols       = fk["referenced_columns"] # columnas PK en la tabla padre

                # Si alguna columna FK no está en data, se omite esta FK (campo nullable/opcional)
                if not all(col in data for col in child_cols):
                    continue

                where  = " AND ".join([f"{pc} = %s" for pc in parent_cols])
                params = [data[cc] for cc in child_cols]

                parent_model = cls._get_table_class(parent_table_name)
                query = f"SELECT 1 FROM {parent_model.TABLE_NAME} WHERE {where} LIMIT 1"
                cur = _conn.cursor()
                cur.execute(query, params)
                if cur.fetchone() is None:
                    print(f"CapaDAL: Padre inexistente en {parent_table_name} para FK {fk['constraint_name']}")
                    return False
            return True
        except Exception as e:
            print(f"CapaDAL Error (row_got_parents {cls.TABLE_NAME}): {e}")
            return False
        finally:
            if not conn:
                sess_conns.release_conn(_conn)

    @classmethod
    def update_pk(cls, old_pk: dict, new_code, conn=None) -> int:
        """Actualiza la clave primaria (PK) de un registro."""
        code_field = cls.get_business_key_field()
        company_field = cls.get_company_field_required()
        query = (
            f"UPDATE {cls.TABLE_NAME} SET {code_field} = %s "
            f"WHERE {company_field} = %s AND {code_field} = %s"
        )
        _conn = conn or sess_conns.get_conn(readonly=False)
        try:
            cur = _conn.cursor()
            cur.execute(query, (new_code, ctx_empr.get(), old_pk[code_field]))
            if not conn:
                _conn.commit()
            return cur.rowcount
        finally:
            if not conn:
                sess_conns.release_conn(_conn)
    TABLE_NAME = ""
    PK_FIELDS = [] # Lista de nombres de campos PK (ej. ["emprcodi", "usercodi"])
    CHILD_RELATIONS = [] # Relaciones: {"table": table_name, "fk": [], "on_delete": "RESTRICT", "on_update": "CASCADE"}
    TABLE_COMMENT = ""
    COLUMNS: Dict[str, Dict[str, Any]] = {}
    FOREIGN_KEYS: List[Dict[str, Any]] = []

    @classmethod
    def _ensure_metadata(cls, conn=None) -> bool:
        """Carga metadata bajo demanda si el modelo aún no la tiene."""
        if cls.COLUMNS and cls.PK_FIELDS:
            return True

        own_conn = conn is None
        _conn = conn or sess_conns.get_conn(readonly=True)
        try:
            metadata = _load_table_metadata(cls.TABLE_NAME, _conn)
            if not metadata["columns"]:
                return False
            cls.TABLE_COMMENT = metadata["table_comment"]
            cls.PK_FIELDS = metadata["pk_fields"]
            cls.COLUMNS = metadata["columns"]
            cls.FOREIGN_KEYS = metadata["foreign_keys"]
            cls.CHILD_RELATIONS = metadata["child_relations"]
            return True
        except Exception:
            return False
        finally:
            if own_conn:
                sess_conns.release_conn(_conn)

    @classmethod
    def get_column_comments(cls, conn=None) -> Dict[str, str]:
        """Obtiene COLUMN_COMMENT por columna para la tabla del modelo."""
        cls._ensure_metadata(conn=conn)
        _conn = conn or sess_conns.get_conn(readonly=True)
        try:
            cur = _conn.cursor(dictionary=True)
            cur.execute(
                """
                                SELECT column_name AS column_name,
                                             column_comment AS column_comment
                FROM information_schema.columns
                WHERE table_schema = DATABASE()
                  AND table_name = %s
                """,
                (cls.TABLE_NAME,),
            )
            rows = [_normalize_row_keys(row) for row in (cur.fetchall() or [])]
            comments: Dict[str, str] = {}
            for row in rows:
                col = str(row.get("column_name") or "").strip()
                if not col:
                    continue
                comments[col] = str(row.get("column_comment") or "").strip()
            return comments
        except Exception as e:
            print(f"CapaDAL Error (Comments {cls.TABLE_NAME}): {e}")
            return {}
        finally:
            if not conn:
                sess_conns.release_conn(_conn)

    @classmethod
    def get_table_comment(cls, conn=None) -> str:
        """Obtiene TABLE_COMMENT para la tabla del modelo."""
        if cls.TABLE_COMMENT:
            return cls.TABLE_COMMENT
        cls._ensure_metadata(conn=conn)
        if cls.TABLE_COMMENT:
            return cls.TABLE_COMMENT
        _conn = conn or sess_conns.get_conn(readonly=True)
        try:
            cur = _conn.cursor(dictionary=True)
            cur.execute(
                """
                                SELECT table_comment AS table_comment
                FROM information_schema.tables
                WHERE table_schema = DATABASE()
                  AND table_name = %s
                LIMIT 1
                """,
                (cls.TABLE_NAME,),
            )
            row = _normalize_row_keys(cur.fetchone() or {})
            return str(row.get("table_comment") or "").strip()
        except Exception as e:
            print(f"CapaDAL Error (Table Comment {cls.TABLE_NAME}): {e}")
            return ""
        finally:
            if not conn:
                sess_conns.release_conn(_conn)

    @classmethod
    def _get_table_class(cls, table_ref: Any) -> Type['TableBase']:
        """Resuelve la clase de la tabla si se pasa como string (nombre real de tabla)."""
        if isinstance(table_ref, str):
            return get_table_model(table_ref)
        return table_ref

    @classmethod
    def _get_empr(cls) -> str:
        """Obtiene el código de la empresa actual del contexto."""
        return ctx_empr.get()

    @classmethod
    def get_company_field(cls) -> Optional[str]:
        """Campo empresa detectado en la tabla (si existe)."""
        cls._ensure_metadata()
        if "emprcodi" in cls.COLUMNS:
            return "emprcodi"
        if "emprcodi" in cls.PK_FIELDS:
            return "emprcodi"
        return None

    @classmethod
    def get_company_field_required(cls) -> str:
        """Devuelve el campo empresa y falla si la tabla no lo tiene."""
        field = cls.get_company_field()
        if not field:
            # Fallback de arranque para no bloquear import; validación real ocurrirá en acceso a datos.
            return "emprcodi"
        return field

    @classmethod
    def require_column(cls, column_name: str) -> str:
        """Valida que una columna exista en metadata y devuelve su nombre."""
        cls._ensure_metadata()
        name = (column_name or "").strip()
        if not name:
            raise ValueError(f"Nombre de columna inválido para tabla {cls.TABLE_NAME}")
        if cls.COLUMNS and name not in cls.COLUMNS:
            raise ValueError(f"La columna '{name}' no existe en {cls.TABLE_NAME}")
        return name

    @classmethod
    def get_business_key_field(cls) -> str:
        """Campo clave de negocio principal (PK distinta de empresa si aplica)."""
        cls._ensure_metadata()
        company_field = cls.get_company_field()
        for field in cls.PK_FIELDS:
            if field != company_field:
                return field
        if cls.PK_FIELDS:
            return cls.PK_FIELDS[0]
        if cls.COLUMNS:
            return next(iter(cls.COLUMNS.keys()))
        raise ValueError(f"Tabla sin metadata de columnas: {cls.TABLE_NAME}")

    @classmethod
    def get_first_text_field(cls, exclude: Optional[List[str]] = None) -> Optional[str]:
        """Primer campo textual de la tabla en orden de aparición."""
        cls._ensure_metadata()
        exclude_set = set(exclude or [])
        text_types = {"char", "varchar", "text", "tinytext", "mediumtext", "longtext"}
        ordered = sorted(
            cls.COLUMNS.items(),
            key=lambda kv: int((kv[1] or {}).get("ordinal_position") or 0),
        )
        for field, meta in ordered:
            if field in exclude_set:
                continue
            data_type = str((meta or {}).get("data_type") or "").lower().strip()
            if data_type in text_types:
                return field
        for field, _ in ordered:
            if field not in exclude_set:
                return field
        return None

    @classmethod
    def get_selector_fields(cls) -> List[str]:
        """Campos recomendados para selector (codigo + etiqueta)."""
        code_field = cls.get_business_key_field()
        company_field = cls.get_company_field()
        exclude_fields = [code_field]
        if company_field and company_field != code_field:
            exclude_fields.append(company_field)
        label_field = cls.get_first_text_field(exclude=exclude_fields) or code_field
        return [code_field, label_field]

    @staticmethod
    def _relation_pk_fields(relation: Dict[str, Any]) -> List[str]:
        """Campos de la PK padre usados por una relación hija."""
        pk_fields = relation.get("pk")
        if isinstance(pk_fields, list) and pk_fields:
            return [str(f).strip() for f in pk_fields]
        fk_fields = relation.get("fk") or []
        return [str(f).strip() for f in fk_fields]

    @classmethod
    def _relation_where_and_params(cls, relation: Dict[str, Any], parent_values: Dict[str, Any]) -> tuple[str, List[Any]]:
        """Construye WHERE y parámetros para buscar hijos, usando mapping FK->PK."""
        fk_fields = [str(f).strip() for f in (relation.get("fk") or [])]
        pk_fields = cls._relation_pk_fields(relation)
        if len(fk_fields) != len(pk_fields):
            raise ValueError(f"Relación inválida en {cls.TABLE_NAME}: fk/pk desalineados")

        where_parts: List[str] = []
        params: List[Any] = []
        for fk_field, pk_field in zip(fk_fields, pk_fields):
            if pk_field not in parent_values:
                raise KeyError(f"Falta valor de PK '{pk_field}' para relación en {cls.TABLE_NAME}")
            where_parts.append(f"{fk_field} = %s")
            params.append(parent_values[pk_field])
        return " AND ".join(where_parts), params

    @classmethod
    def row_get(cls, pk_values: Dict[str, Any], conn=None) -> Dict[str, Any]:
        """Obtiene un registro por su PK completa."""
        pk_values = pk_values.copy()
        _conn = conn or sess_conns.get_conn(readonly=True)
        try:
            if not cls._ensure_metadata(conn=_conn):
                raise ValueError(f"No se pudo cargar metadata para {cls.TABLE_NAME}")
            cur = _conn.cursor(dictionary=True)
            # Asegurar campo empresa si es parte de la PK
            company_field = cls.get_company_field()
            if company_field and company_field in cls.PK_FIELDS and company_field not in pk_values:
                pk_values[company_field] = cls._get_empr()
            
            where = " AND ".join([f"{f} = %s" for f in cls.PK_FIELDS])
            query = f"SELECT * FROM {cls.TABLE_NAME} WHERE {where}"
            cur.execute(query, [pk_values[f] for f in cls.PK_FIELDS])
            row = cur.fetchone()
            return row if row else {}
        except Exception as e:
            print(f"CapaDAL Error (Get {cls.TABLE_NAME}): {e}")
            return {}
        finally:
            if not conn: sess_conns.release_conn(_conn)

    @classmethod
    def list_all(cls, filters: Optional[Dict[str, Any]] = None, order_by: Optional[str] = None, fields: Optional[List[str]] = None, conn=None, skip_company_filter: bool = False) -> List[Dict[str, Any]]:
        """Obtiene todos los registros, opcionalmente filtrados y ordenados."""
        _conn = conn or sess_conns.get_conn(readonly=False)
        try:
            if not cls._ensure_metadata(conn=_conn):
                raise ValueError(f"No se pudo cargar metadata para {cls.TABLE_NAME}")
            columns = ", ".join(fields) if fields else "*"
            query = f"SELECT {columns} FROM {cls.TABLE_NAME}"
            params = []

            # Filtro automático de empresa si aplica
            where_clauses = []
            company_field = cls.get_company_field()
            if not skip_company_filter and company_field and company_field in cls.PK_FIELDS:
                where_clauses.append(f"{company_field} = %s")
                params.append(cls._get_empr())

            if filters:
                for k, v in filters.items():
                    where_clauses.append(f"{k} = %s")
                    params.append(v)
            
            if where_clauses:
                query += " WHERE " + " AND ".join(where_clauses)
            
            if order_by:
                query += f" ORDER BY {order_by}"
                
            cur = _conn.cursor(dictionary=True)
            cur.execute(query, params)
            return cur.fetchall()
        except Exception as e:
            print(f"CapaDAL Error (List {cls.TABLE_NAME}): {e}")
            return []
        finally:
            if not conn: sess_conns.release_conn(_conn)

    @classmethod
    def row_insert(cls, data: Dict[str, Any], conn=None) -> bool:
        """Inserta un registro. La auditoría se maneja vía triggers en la BD."""
        data = data.copy()
        _conn = conn or sess_conns.get_conn(readonly=False)
        try:
            if not cls._ensure_metadata(conn=_conn):
                raise ValueError(f"No se pudo cargar metadata para {cls.TABLE_NAME}")
            company_field = cls.get_company_field()
            if company_field and company_field in cls.PK_FIELDS and company_field not in data:
                data[company_field] = cls._get_empr()
            
            columns = ", ".join(data.keys())
            placeholders = ", ".join(["%s"] * len(data))
            query = f"INSERT INTO {cls.TABLE_NAME} ({columns}) VALUES ({placeholders})"
            
            cur = _conn.cursor()
            cur.execute(query, list(data.values()))
            if not conn: _conn.commit()
            return True
        except Exception as e:
            if not conn: _conn.rollback()
            print(f"CapaDAL Error (Insert {cls.TABLE_NAME}): {e}")
            return False
        finally:
            if not conn: sess_conns.release_conn(_conn)

    @classmethod
    def row_update(cls, pk_values: Dict[str, Any], data: Dict[str, Any], conn=None) -> bool:
        """
        Actualiza un registro por su PK. 
        Si se intenta cambiar la PK, se aplica lógica de cascada según la configuración de los hijos.
        """
        pk_values = pk_values.copy()
        _conn = conn or sess_conns.get_conn(readonly=False)
        try:
            if not cls._ensure_metadata(conn=_conn):
                raise ValueError(f"No se pudo cargar metadata para {cls.TABLE_NAME}")
            # Asegurar campo empresa en PK si es necesario
            company_field = cls.get_company_field()
            if company_field and company_field in cls.PK_FIELDS and company_field not in pk_values:
                pk_values[company_field] = cls._get_empr()

            # Identificar si hay cambios en la PK
            pk_changes = {}
            for f in cls.PK_FIELDS:
                if f in data and data[f] != pk_values.get(f):
                    pk_changes[f] = data[f]

            # Si hay cambios en la PK, procesar cascada de Update
            if pk_changes:
                for relation in cls.CHILD_RELATIONS:
                    child_table = cls._get_table_class(relation["table"])
                    fk_fields = relation["fk"]
                    pk_fields = cls._relation_pk_fields(relation)
                    on_update = relation.get("on_update", "CASCADE")

                    affected_fks = [fk for fk, pk in zip(fk_fields, pk_fields) if pk in pk_changes]
                    if affected_fks:
                        if on_update == "RESTRICT":
                               if cls.has_children(relation, pk_values, conn=_conn):
                                raise Exception(f"No se puede actualizar PK: Restricción de integridad en {child_table.TABLE_NAME}")
                        elif on_update == "CASCADE":
                            where_child, where_params = cls._relation_where_and_params(relation, pk_values)
                            set_pairs = [(fk, pk) for fk, pk in zip(fk_fields, pk_fields) if pk in pk_changes]
                            set_child = ", ".join([f"{fk} = %s" for fk, _ in set_pairs])
                            set_params = [pk_changes[pk] for _, pk in set_pairs]
                            
                            query_upd_child = f"UPDATE {child_table.TABLE_NAME} SET {set_child} WHERE {where_child}"
                            cur = _conn.cursor()
                            cur.execute(query_upd_child, set_params + where_params)

            # Preparar la actualización del registro principal
            update_data = data.copy()
            set_clause = ", ".join([f"{k} = %s" for k in update_data.keys()])
            where_clause = " AND ".join([f"{f} = %s" for f in cls.PK_FIELDS])
            
            query = f"UPDATE {cls.TABLE_NAME} SET {set_clause} WHERE {where_clause}"
            params = list(update_data.values()) + [pk_values[f] for f in cls.PK_FIELDS]
            
            cur = _conn.cursor()
            cur.execute(query, params)
            if not conn: _conn.commit()
            return True
        except Exception as e:
            if not conn: _conn.rollback()
            print(f"CapaDAL Error (Update {cls.TABLE_NAME}): {e}")
            return False
        finally:
            if not conn: sess_conns.release_conn(_conn)

    @classmethod
    def row_delete(cls, pk_values: Dict[str, Any], force_cascade: bool = False, conn=None) -> bool:
        """
        Borrado con lógica de integridad.
        """
        pk_values = pk_values.copy()
        _conn = conn or sess_conns.get_conn(readonly=False)
        try:
            if not cls._ensure_metadata(conn=_conn):
                raise ValueError(f"No se pudo cargar metadata para {cls.TABLE_NAME}")
            company_field = cls.get_company_field()
            if company_field and company_field in cls.PK_FIELDS and company_field not in pk_values:
                pk_values[company_field] = cls._get_empr()

            for relation in cls.CHILD_RELATIONS:
                child_table = cls._get_table_class(relation["table"])
                on_delete = relation.get("on_delete", "RESTRICT")

                where_child, params_child = cls._relation_where_and_params(relation, pk_values)
                
                cur = _conn.cursor()
                query_check = f"SELECT 1 FROM {child_table.TABLE_NAME} WHERE {where_child} LIMIT 1"
                cur.execute(query_check, params_child)
                if cur.fetchone() is not None:
                    if not force_cascade and on_delete == "RESTRICT":
                        print(f"Error: Restricción de integridad. {cls.TABLE_NAME} tiene hijos en {child_table.TABLE_NAME}.")
                        return False
                    
                    if force_cascade or on_delete == "CASCADE":
                        cur = _conn.cursor(dictionary=True)
                        cur.execute(f"SELECT * FROM {child_table.TABLE_NAME} WHERE {where_child}", params_child)
                        children = cur.fetchall()
                        for child in children:
                            child_pk = {f: child[f] for f in child_table.PK_FIELDS}
                            if not child_table.row_delete(child_pk, force_cascade=True, conn=_conn):
                                raise Exception(f"Fallo al borrar hijo en {child_table.TABLE_NAME}")

            where_parent = " AND ".join([f"{f} = %s" for f in cls.PK_FIELDS])
            query_del = f"DELETE FROM {cls.TABLE_NAME} WHERE {where_parent}"
            cur = _conn.cursor()
            cur.execute(query_del, [pk_values[f] for f in cls.PK_FIELDS])
            
            if not conn: _conn.commit()
            return True
        except Exception as e:
            if not conn: _conn.rollback()
            print(f"CapaDAL Error (Delete {cls.TABLE_NAME}): {e}")
            return False
        finally:
            if not conn: sess_conns.release_conn(_conn)

    @classmethod
    def has_any_children(cls, pk_values: Dict[str, Any], conn=None) -> bool:
        """Verifica si existen hijos en alguna de las relaciones hijas."""
        pk_values = pk_values.copy()
        _conn = conn or sess_conns.get_conn(readonly=True)
        try:
            if not cls._ensure_metadata(conn=_conn):
                raise ValueError(f"No se pudo cargar metadata para {cls.TABLE_NAME}")
            company_field = cls.get_company_field()
            if company_field and company_field in cls.PK_FIELDS and company_field not in pk_values:
                pk_values[company_field] = cls._get_empr()

            cur = _conn.cursor()
            for relation in cls.CHILD_RELATIONS:
                child_table = cls._get_table_class(relation["table"])
                child_table_name = child_table.TABLE_NAME
                where, params = cls._relation_where_and_params(relation, pk_values)
                query = f"SELECT 1 FROM {child_table_name} WHERE {where} LIMIT 1"
                cur.execute(query, params)
                if cur.fetchone() is not None:
                    return True
            return False
        finally:
            if not conn: sess_conns.release_conn(_conn)

    @classmethod
    def get_window(cls, filtro_filas: str = "1=1", params: tuple = (), limit: int = 100, offset: int = 0, fields: List[str] = None) -> List[Dict[str, Any]]:
        """Consulta standard con filtros."""
        conn = sess_conns.get_conn(readonly=True)
        try:
            if not cls._ensure_metadata(conn=conn):
                raise ValueError(f"No se pudo cargar metadata para {cls.TABLE_NAME}")
            cur = conn.cursor(dictionary=True)
            columns = ", ".join(fields) if fields else "*"
            
            # Filtro de empresa si la tabla lo tiene
            empr_filter = ""
            full_params = params
            company_field = cls.get_company_field()
            if company_field and company_field in cls.PK_FIELDS:
                empr_filter = f"{company_field} = %s AND "
                full_params = (cls._get_empr(),) + params

            query = (
                f"SELECT {columns} FROM {cls.TABLE_NAME} "
                f"WHERE {empr_filter}({filtro_filas}) "
                f"LIMIT %s OFFSET %s"
            )
            full_params = full_params + (limit, offset)
            cur.execute(query, full_params)
            return cur.fetchall()
        finally:
            sess_conns.release_conn(conn)


def _load_table_metadata(table_name: str, conn) -> Dict[str, Any]:
    """Carga metadata de una tabla desde information_schema."""
    cur = conn.cursor(dictionary=True)

    cur.execute(
        """
        SELECT c.column_name,
               c.column_type,
               c.data_type,
               c.is_nullable,
               c.column_default,
               c.column_comment,
               c.ordinal_position,
               t.table_comment
        FROM information_schema.columns c
        JOIN information_schema.tables t
          ON t.table_schema = c.table_schema
         AND t.table_name = c.table_name
        WHERE c.table_schema = DATABASE()
          AND c.table_name = %s
        ORDER BY c.ordinal_position
        """,
        (table_name,),
    )
    column_rows = [_normalize_row_keys(row) for row in (cur.fetchall() or [])]

    cur.execute(
        """
        SELECT k.column_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage k
          ON k.constraint_schema = tc.constraint_schema
         AND k.table_name = tc.table_name
         AND k.constraint_name = tc.constraint_name
        WHERE tc.table_schema = DATABASE()
          AND tc.table_name = %s
          AND tc.constraint_type = 'PRIMARY KEY'
        ORDER BY k.ordinal_position
        """,
        (table_name,),
    )
    pk_rows = [_normalize_row_keys(row) for row in (cur.fetchall() or [])]

    cur.execute(
        """
        SELECT k.constraint_name,
               k.table_name,
               k.column_name,
               k.ordinal_position,
               k.referenced_table_name,
               k.referenced_column_name,
               rc.update_rule,
               rc.delete_rule
        FROM information_schema.key_column_usage k
        JOIN information_schema.referential_constraints rc
          ON rc.constraint_schema = k.constraint_schema
         AND rc.table_name = k.table_name
         AND rc.constraint_name = k.constraint_name
        WHERE k.table_schema = DATABASE()
          AND k.table_name = %s
          AND k.referenced_table_name IS NOT NULL
        ORDER BY k.constraint_name, k.ordinal_position
        """,
        (table_name,),
    )
    fk_rows = [_normalize_row_keys(row) for row in (cur.fetchall() or [])]

    cur.execute(
        """
        SELECT k.constraint_name,
               k.table_name AS child_table,
               k.column_name AS child_column,
               k.ordinal_position,
               k.referenced_table_name AS parent_table,
               k.referenced_column_name AS parent_column,
               rc.update_rule,
               rc.delete_rule
        FROM information_schema.key_column_usage k
        JOIN information_schema.referential_constraints rc
          ON rc.constraint_schema = k.constraint_schema
         AND rc.table_name = k.table_name
         AND rc.constraint_name = k.constraint_name
        WHERE k.table_schema = DATABASE()
          AND k.referenced_table_name = %s
        ORDER BY k.constraint_name, k.ordinal_position
        """,
        (table_name,),
    )
    incoming_rows = [_normalize_row_keys(row) for row in (cur.fetchall() or [])]
    cur.close()

    columns: Dict[str, Dict[str, Any]] = {}
    table_comment = ""
    for row in column_rows:
        col_name = str(row.get("column_name") or "").strip()
        if not col_name:
            continue
        columns[col_name] = {
            "column_type": str(row.get("column_type") or ""),
            "data_type": str(row.get("data_type") or ""),
            "is_nullable": str(row.get("is_nullable") or "YES").upper() == "YES",
            "default": row.get("column_default"),
            "comment": str(row.get("column_comment") or "").strip(),
            "ordinal_position": int(row.get("ordinal_position") or 0),
        }
        if not table_comment:
            table_comment = str(row.get("table_comment") or "").strip()

    pk_fields = [str(row.get("column_name") or "").strip() for row in pk_rows if row.get("column_name")]

    fk_map: Dict[str, Dict[str, Any]] = {}
    for row in fk_rows:
        key = str(row.get("constraint_name") or "").strip()
        if not key:
            continue
        if key not in fk_map:
            fk_map[key] = {
                "constraint_name": key,
                "table": str(row.get("table_name") or "").strip(),
                "referenced_table": str(row.get("referenced_table_name") or "").strip(),
                "columns": [],
                "referenced_columns": [],
                "on_update": str(row.get("update_rule") or "RESTRICT").upper(),
                "on_delete": str(row.get("delete_rule") or "RESTRICT").upper(),
            }
        fk_map[key]["columns"].append(str(row.get("column_name") or "").strip())
        fk_map[key]["referenced_columns"].append(str(row.get("referenced_column_name") or "").strip())

    incoming_map: Dict[str, Dict[str, Any]] = {}
    for row in incoming_rows:
        key = str(row.get("constraint_name") or "").strip()
        if not key:
            continue
        if key not in incoming_map:
            incoming_map[key] = {
                "table": str(row.get("child_table") or "").strip(),
                "fk": [],
                "pk": [],
                "on_update": str(row.get("update_rule") or "RESTRICT").upper(),
                "on_delete": str(row.get("delete_rule") or "RESTRICT").upper(),
            }
        incoming_map[key]["fk"].append(str(row.get("child_column") or "").strip())
        incoming_map[key]["pk"].append(str(row.get("parent_column") or "").strip())

    child_relations = list(incoming_map.values())

    return {
        "table_name": table_name,
        "table_comment": table_comment,
        "pk_fields": pk_fields,
        "columns": columns,
        "foreign_keys": list(fk_map.values()),
        "child_relations": child_relations,
    }


def get_table_model(table_name: str, conn=None, refresh: bool = False) -> Type[TableBase]:
    """Devuelve un modelo dinámico de tabla construido desde metadata MySQL."""
    normalized_name = (table_name or "").strip().lower()
    if not normalized_name:
        raise ValueError("table_name requerido")

    if not refresh and normalized_name in _TABLE_MODEL_CACHE:
        return _TABLE_MODEL_CACHE[normalized_name]

    own_conn = conn is None
    _conn = conn or sess_conns.get_conn(readonly=True)
    try:
        metadata = _load_table_metadata(normalized_name, _conn)
        has_metadata = bool(metadata["columns"])

        class_name = "Dyn_" + "".join(part.capitalize() for part in normalized_name.split("_"))
        model = type(
            class_name,
            (TableBase,),
            {
                "TABLE_NAME": metadata["table_name"],
                "TABLE_COMMENT": metadata["table_comment"],
                "PK_FIELDS": metadata["pk_fields"],
                "COLUMNS": metadata["columns"],
                "FOREIGN_KEYS": metadata["foreign_keys"],
                "CHILD_RELATIONS": metadata["child_relations"],
            },
        )
        if not has_metadata:
            print(f"Advertencia DAL: metadata no disponible al iniciar para tabla '{normalized_name}'. Se reintentará en el primer acceso.")
        _TABLE_MODEL_CACHE[normalized_name] = model
        return model
    finally:
        if own_conn:
            sess_conns.release_conn(_conn)


def clear_table_model_cache() -> None:
    """Limpia la cache de modelos dinámicos."""
    _TABLE_MODEL_CACHE.clear()