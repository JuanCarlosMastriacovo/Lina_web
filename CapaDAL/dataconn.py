import mysql.connector
from mysql.connector import pooling
from typing import Dict, Optional
from contextvars import ContextVar
import threading
from CapaDAL.config import MYSQL_CONFIG

# Contexto de sesión aislado (Thread-safe y Asgi-safe)
ctx_user: ContextVar[Optional[str]] = ContextVar("ctx_user", default=None)
ctx_empr: ContextVar[str] = ContextVar("ctx_empr", default="01")
ctx_prog: ContextVar[Optional[str]] = ContextVar("ctx_prog", default=None)
ctx_date: ContextVar[str] = ContextVar("ctx_date", default="")

class DataConn:
    def __init__(self):
        """
        Inicializa el pool de conexiones a MySQL.
        """
        try:
            pool_name = MYSQL_CONFIG.get("pool_name", "lina_pool")
            pool_size = MYSQL_CONFIG.get("pool_size", 20)
            config = dict(MYSQL_CONFIG)
            config.pop("pool_name", None)
            config.pop("pool_size", None)
            self.pool = mysql.connector.pooling.MySQLConnectionPool(
                pool_name=pool_name,
                pool_size=pool_size,
                autocommit=False,
                **config
            )
        except Exception as e:
            print(f"Error al crear el pool de conexiones: {e}")
            self.pool = None
        self._task_conns: Dict[str, mysql.connector.pooling.PooledMySQLConnection] = {}
        self._task_lock = threading.Lock()

    def _task_key(self, user: Optional[str], task_id: str) -> str:
        user_key = (user or "SYSTEM").strip().upper()
        return f"{user_key}|{task_id.strip()}"

    def _set_conn_session_vars(self, conn, user: Optional[str], prog: Optional[str]) -> None:
        prog_value = (prog or ctx_prog.get() or "LINA_WEB").strip() or "LINA_WEB"
        user_value = (user or "SYSTEM").strip() or "SYSTEM"
        cur = conn.cursor()
        cur.execute("SET @lina_user = %s, @lina_prog = %s", (user_value, prog_value))
        cur.close()

    def get_conn(self, readonly: bool = True, user_override: Optional[str] = None):
        """
        Obtiene una conexión de la base de datos del pool.
        """
        if self.pool is None:
            raise Exception("El pool de conexiones no está inicializado.")

        user = user_override or ctx_user.get()
        prog = ctx_prog.get() or "LINA_WEB"

        conn = self.pool.get_connection()
        try:
            self._set_conn_session_vars(conn, user, prog)
        except Exception as e:
            print(f"Error setting session variables: {e}")
        
        return conn

    def start_task_conn(self, task_id: str, user: Optional[str], prog: Optional[str] = None):
        """Abre (o reutiliza) una conexión transaccional atada a una tarea/pestaña."""
        if self.pool is None:
            raise Exception("El pool de conexiones no está inicializado.")
        key = self._task_key(user, task_id)
        with self._task_lock:
            existing = self._task_conns.get(key)
            if existing:
                return existing
            conn = self.pool.get_connection()
            self._set_conn_session_vars(conn, user, prog)
            self._task_conns[key] = conn
            return conn

    def get_task_conn(self, task_id: str, user: Optional[str], prog: Optional[str] = None):
        """Obtiene la conexión de una tarea; la crea si no existe."""
        key = self._task_key(user, task_id)
        with self._task_lock:
            conn = self._task_conns.get(key)
        if conn:
            return conn
        return self.start_task_conn(task_id=task_id, user=user, prog=prog)

    def close_task_conn(self, task_id: str, user: Optional[str], commit: bool = False) -> bool:
        """Cierra la conexión de una tarea aplicando commit o rollback."""
        key = self._task_key(user, task_id)
        with self._task_lock:
            conn = self._task_conns.pop(key, None)
        if not conn:
            return False
        try:
            if commit:
                conn.commit()
            else:
                conn.rollback()
        except Exception:
            pass
        finally:
            try:
                conn.close()
            except Exception:
                pass
        return True

    def commit_and_restart_task_conn(self, task_id: str, user: Optional[str], prog: Optional[str] = None) -> bool:
        """Hace commit de la transacción actual del tab y abre una nueva limpia."""
        closed = self.close_task_conn(task_id=task_id, user=user, commit=True)
        if not closed:
            return False
        self.start_task_conn(task_id=task_id, user=user, prog=prog)
        return True

    def close_all_task_conns(self, user: Optional[str], commit: bool = False) -> int:
        """Cierra todas las conexiones de tarea de un usuario (logout/cierre de sesión)."""
        user_key = (user or "SYSTEM").strip().upper() + "|"
        with self._task_lock:
            keys = [k for k in self._task_conns.keys() if k.startswith(user_key)]
        closed = 0
        for key in keys:
            task_id = key.split("|", 1)[1]
            if self.close_task_conn(task_id=task_id, user=user, commit=commit):
                closed += 1
        return closed

    def close_session_conn(self, user: str):
        """Compatibilidad: cierra todas las conexiones de tareas abiertas del usuario."""
        self.close_all_task_conns(user=user, commit=False)

    def release_conn(self, conn: mysql.connector.pooling.PooledMySQLConnection):
        """
        Limpia el estado de la transacción y devuelve la conexión al pool.
        """
        try:
            # Asegurar que no queden transacciones abiertas que bloqueen el aislamiento
            conn.rollback()
            conn.close()
        except Exception:
            pass

# Instancia única global de la base de datos
sess_conns = DataConn()
