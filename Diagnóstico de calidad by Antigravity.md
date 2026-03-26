# Informe de Calidad de CÃ³digo â€” `lina_web`

> AnÃ¡lisis estÃ¡tico sin modificaciones. Solo observaciÃ³n y clasificaciÃ³n de hallazgos.

---

## Resumen ejecutivo

La aplicaciÃ³n tiene una arquitectura de tres capas bien definida (DAL / BRL / UI) con buenas prÃ¡cticas en varios aspectos: separaciÃ³n de la lÃ³gica de negocio de la capa de presentaciÃ³n, validadores reutilizables, modelos dinÃ¡micos de tabla, inyecciÃ³n de dependencias, manejo de transacciones por tab, etc.

Sin embargo, se detectaron patrones de **duplicaciÃ³n masiva**, **inconsistencias de capas** y algunos **problemas de seguridad menores** que se detallan a continuaciÃ³n.

---

## 1. DuplicaciÃ³n de cÃ³digo â€” Alta severidad ðŸ”´

### 1.1 Funciones helper copiadas en cada mÃ³dulo UI

Las funciones `_get_empr()` y `_get_fecha_sesion()` son **idÃ©nticas** en todos los mÃ³dulos que las usan, sin excepciÃ³n. Ambas ya podrÃ­an vivir en `linabase` o en un mÃ³dulo utilitario de CapaUI.

| FunciÃ³n | Archivos donde aparece copiada |
|---|---|
| `_get_empr()` | `lina21.py`, `lina24.py`, `lina31.py`, `lina34.py`, `lina42.py`, `lina44.py` |
| `_get_fecha_sesion()` | `lina21.py`, `lina24.py`, `lina31.py`, `lina34.py`, `lina41.py`, `lina43.py`, `lina44.py`, `lina271.py`, `lina272.py`, `lina371.py`, `lina372.py` (11 copias) |

**CÃ³digo duplicado** (exactamente el mismo en los 11 archivos para `_get_fecha_sesion`):
```python
def _get_fecha_sesion() -> date:
    raw = ctx_date.get()
    if raw:
        try:
            return date.fromisoformat(raw)
        except ValueError:
            pass
    return date.today()
```

`linabase` ya expone `ctx_date` indirectamente; esta funciÃ³n podrÃ­a ser un mÃ©todo de clase allÃ­ o un helper en un mÃ³dulo `ui_utils.py`.

---

### 1.2 MÃ³dulos de listados Caja / Banco casi idÃ©nticos (lina41 / lina43)

`lina41.py` (Caja) y `lina43.py` (Banco) son **virtualmente el mismo archivo**, con ~350 lÃ­neas cada uno y diferencias mÃ­nimas (nombre de tabla, campos, titulos). Incluyendo:

- `_parse_params()` â€” **idÃ©ntico** en ambos
- `_build_subtitulo()` â€” **idÃ©ntico** en ambos
- `_get_fecha_sesion()` â€” **idÃ©ntico** en ambos
- `_fmt_z()` â€” **idÃ©ntico** en ambos
- Bloques `/xlsx` â€” iguales salvo tÃ­tulo y nombre de archivo
- Bloques `/txt` â€” iguales salvo tÃ­tulo
- El `__import__("datetime")` anti-patrÃ³n â€” **presente en ambos** (ver secciÃ³n 4.1)

Lo mismo ocurre con los pares de listados de cuentas corrientes:

| Par | Diferencia |
|---|---|
| `lina231.py` / `lina331.py` | Clientes vs Proveedores |
| `lina261.py` / `lina361.py` | Idem |
| `lina271.py` / `lina371.py` | Idem |
| `lina272.py` / `lina372.py` | Idem |

Todos estos mÃ³dulos tienen la misma estructura de rutas (`/`, `/pdf`, `/xlsx`, `/txt`) y prÃ¡cticamente el mismo cÃ³digo de renderizado.

---

### 1.3 MÃ³dulos de transacciones ventas / compras (BRL)

`recibos_brl.py` y `pagos_brl.py` son anÃ¡logos con diferencias de nombre de tabla y campo. El patrÃ³n `anular_*`:

```python
# recibos_brl.py anular_recibo()
if str(row.get("coheobse") or "").startswith("*** ANULAD"):        # ventas

# pagos_brl.py anular_pago()
if str(row.get("paheobse") or "").startswith("*** ANULAD"):        # compras
```

La lÃ³gica completa de anulaciÃ³n (leer cabecera, eliminar renglones, blanquear, eliminar ctcl/ctpr, caja, banco) podrÃ­a parametrizarse en una funciÃ³n base `_anular_comprobante(cfg, ...)`.

---

### 1.4 `set_prog_code()` llamado en cada ruta del mismo mÃ³dulo

Cada endpoint del mismo mÃ³dulo llama `LINAxxx.set_prog_code(PROG_CODE)` al inicio. Como `set_prog_code` es un setter de **clase** (compartido por todos), tiene race-condition potencial en entornos multi-request y ademÃ¡s es redundante (el cÃ³digo no cambia entre requests al mismo mÃ³dulo). Por ejemplo en `lina43.py` aparece 4 veces (lÃ­neas 185, 201, 256, 342).

El patrÃ³n deberÃ­a consolidarse: o en el constructor del router, o bien eliminarlo si `PROG_CODE` ya es constante por mÃ³dulo.

---

## 2. MÃ©todo duplicado entre capas â€” Inconsistencia DAL / BRL ðŸ”´

### 2.1 `get_table_ui_metadata` existe en DOS capas

- `CapaDAL/tablebase.py` lÃ­nea 19: `TableBase.get_table_ui_metadata(cls, conn=None)`
- `CapaBRL/linabase.py` lÃ­nea 211: `linabase.get_table_ui_metadata(table_cls, conn=None)` â€” **mÃ©todo estÃ¡tico**

Ambos hacen exactamente lo mismo: devuelven `{"field_tooltips": ..., "table_description": ...}`.

Los mÃ³dulos UI llaman al de BRL (`Lina111.get_table_ui_metadata(LinaClie, conn=conn)`), que delega al de DAL. El de DAL es redundante o viceversa â€” hay que decidir cuÃ¡l es el responsable.

```python
# linabase.py:211
@staticmethod
def get_table_ui_metadata(table_cls: Type[Any], conn=None) -> Dict[str, Any]:
    return {
        "field_tooltips": table_cls.get_column_comments(conn=conn),
        "table_description": table_cls.get_table_comment(conn=conn),
    }

# tablebase.py:19  â† mismo resultado, diferente ubicaciÃ³n
@classmethod
def get_table_ui_metadata(cls, conn=None) -> dict:
    field_tooltips = cls.get_column_comments(conn=conn)
    table_description = cls.get_table_comment(conn=conn)
    return {"field_tooltips": field_tooltips, "table_description": table_description}
```

---

## 3. Entrecruzamiento de capas (Layer Crossing) ðŸŸ 

### 3.1 MÃ³dulos UI importan directamente de CapaDAL saltando BRL

MÃºltiples mÃ³dulos de CapaUI importan `from CapaDAL.config import APP_CONFIG`, cuando `APP_CONFIG` ya re-exporta desde `CapaBRL.config`. Los mÃ³dulos UI deberÃ­an importar siempre de BRL, no de DAL directamente.

Archivos afectados (19 mÃ³dulos):
`lina41.py`, `lina43.py`, `lina112.py`, `lina122.py`, `lina231.py`, `lina261.py`, `lina271.py`, `lina272.py`, `lina331.py`, `lina361.py`, `lina371.py`, `lina372.py`, `lina1331.py`, `lina1332.py`, `lina1333.py`, `lina1334.py`, `lina1335.py`, `lina1341.py`, `linacpbte.py`.

```python
# Incorrecto (CapaUI importando desde CapaDAL)
from CapaDAL.config import APP_CONFIG

# Correcto (CapaUI deberÃ­a importar desde CapaBRL)
from CapaBRL.config import APP_CONFIG
```

> **Nota:** `CapaDAL/config.py` es actualmente un shim que re-exporta desde `CapaBRL/config.py`, pero eso hace la dependencia explÃ­cita DALâ†’BRL, que es una inversiÃ³n de la dependencia correcta (DAL no deberÃ­a conocer BRL).

---

### 3.2 `tablebase.py` importa de CapaBRL

`CapaDAL/tablebase.py` lÃ­nea 3:
```python
from CapaBRL.config import SELECTOR_MAX_ROWS
```

Esto crea una **dependencia circular de capas**: DAL depende de BRL. DAL deberÃ­a ser autÃ³nomo. `SELECTOR_MAX_ROWS` deberÃ­a definirse en DAL o pasarse como parÃ¡metro.

---

### 3.3 SQL raw dentro de CapaBRL (remitos, recibos, compras, pagos, cpbte, cardex)

Todos los mÃ³dulos `*_brl.py` ejecutan SQL directamente con cursores, sin pasar por el DAL (`TableBase`). Esta es la naturaleza del mÃ³dulo â€” la lÃ³gica transaccional es compleja â€” pero implica que:

- Nombres de tablas y columnas estÃ¡n hardcodeados en BRL (`linafvhe`, `linafvde`, `linactcl`, etc.)
- Si se renombra una tabla, hay que buscar en BRL ademÃ¡s de en DAL
- No se benefician del manejo de empresa automÃ¡tico de `TableBase`

Esto no es necesariamente incorrecto en una arquitectura de negocio compleja, pero es una deuda tÃ©cnica a documentar.

---

## 4. Vicios de cÃ³digo (Code Smells) ðŸŸ¡

### 4.1 `__import__("datetime")` dentro de expresiÃ³n lambda (lina41 y lina43)

En ambos mÃ³dulos, lÃ­nea ~129:
```python
fecha_sa = (fecini - __import__("datetime").timedelta(days=1)).strftime(...)
```

`datetime` ya estÃ¡ importado al inicio del archivo como `from datetime import date, datetime`. DeberÃ­a usarse `timedelta` directamente, importÃ¡ndolo en el encabezado.

---

### 4.2 Clase vacÃ­a en cada mÃ³dulo UI

Cada mÃ³dulo UI define una clase `class LinaXXX(linabase): pass` sin ningÃºn contenido. Por ejemplo:

```python
class Lina21(linabase):
    """MÃ³dulo de EmisiÃ³n de Remitos de Venta (LINA21)."""
    pass
```

Estas clases vacÃ­as no aportan nada â€” se usan Ãºnicamente como namespace para llamar mÃ©todos heredados de `linabase`. PodrÃ­a usarse directamente `linabase` en todos los casos, o bien documentar cuÃ¡l es la intenciÃ³n de extensiÃ³n futura.

La excepciÃ³n es `Lina111` que sÃ­ agrega mÃ©todos propios, lo cual es consistente.

---

### 4.3 IndentaciÃ³n inconsistente en `TableBase`

En `tablebase.py`, los mÃ©todos `get_table_ui_metadata`, `get_code_label_fields` y `get_company_and_key_fields` (lÃ­neas 18â€“44) tienen el cuerpo con **doble indentaciÃ³n** (8 espacios en lugar de 4):

```python
@classmethod
def get_table_ui_metadata(cls, conn=None) -> dict:
        """                           â† 8 espacios de indentaciÃ³n
        Devuelve metadatos...         â† 8 espacios
        """
        field_tooltips = cls.get_column_comments(conn=conn)   â† 8 espacios
```

Esto viola PEP 8 pero es vÃ¡lido en Python. Es un error cosmÃ©tico que puede causar confusiÃ³n.

---

### 4.4 Uso de `print()` como logging

Se usan `print()` como mecanismo de logging en toda la aplicaciÃ³n:

- `tablebase.py`: 9 llamadas a `print(f"CapaDAL Error ...")`
- `linabase.py`, `lina0.py`, `remitos_brl.py`, etc.: mÃ¡s instancias

En una aplicaciÃ³n de producciÃ³n, deberÃ­a usarse el mÃ³dulo `logging` de Python con niveles configurables. Los `print()` no son persistentes, no tienen timestamps, y no se pueden silenciar o redirigir fÃ¡cilmente.

---

### 4.5 ContraseÃ±a de BD y secret key embebidos en `config.py`

```python
# CapaBRL/config.py lÃ­nea 8
"password": os.getenv("LINA_MYSQL_PASSWORD", "Lina1234"),

# CapaUI/lina0.py lÃ­nea 202
app.add_middleware(SessionMiddleware, secret_key="lina-secret-key-not-final", ...)
```

- La contraseÃ±a de BD tiene fallback hardcodeado `"Lina1234"`.
- La clave de sesiÃ³n tiene el comentario `not-final` â€” si llega a producciÃ³n asÃ­, las sesiones pueden ser forjadas.

Ambas deben requerir variable de entorno, sin fallback, o fallar al iniciar si no estÃ¡n configuradas.

---

### 4.6 Archivo de API Key en carpeta de cÃ³digo (`CapaBRL/DeepSeek API-KEY.txt`)

Este archivo no deberÃ­a estar en el repositorio de cÃ³digo. Las claves de API deben gestionarse como variables de entorno o en un gestor de secretos. Si el repo es pÃºblico o semi-pÃºblico, representa un riesgo real.

---

## 5. Dead Code / CÃ³digo sin uso aparente ðŸŸ¡

### 5.1 `carpeta miscelaneas/` â€” Scripts de utilidad sin integraciÃ³n

La carpeta `miscelaneas/` contiene scripts sueltos (`capitalize_cliename.py`, `capitalize_first_string.py`, `get_db_columns.py`, `rename_prog.py`, `krpt.py`, `krpt_cli.py`) que no son importados ni referenciados por el sistema principal. Son herramientas de migraciÃ³n/mantenimiento que deberÃ­an:
- Estar en una carpeta separada y bien documentada (ej. `tools/`)
- O removerse si ya cumplieron su propÃ³sito

---

### 5.2 `linaapi.py` â€” MÃ³dulo API genÃ©rico

`CapaUI/linaapi.py` (2508 bytes) define un router `/api`. No fue analizado en detalle, pero al no tener mÃ³dulo BRL asociado, merece verificaciÃ³n de que todos sus endpoints estÃ©n en uso.

---

### 5.3 `clear_table_model_cache()` en `tablebase.py` (lÃ­nea 879)

Esta funciÃ³n existe pero no aparece llamada en ningÃºn lugar del cÃ³digo de producciÃ³n. PodrÃ­a ser dead code o una herramienta de testing.

---

### 5.4 `ctx_prog` en `dataconn.py`

`ctx_prog: ContextVar[Optional[str]]` estÃ¡ definido y se pasa a `_set_conn_session_vars`, pero nunca se setea desde el middleware de sesiÃ³n en `lina0.py`. Solo se setea a travÃ©s de `start_task_conn`. PodrÃ­a simplificarse.

---

## 6. Inconsistencias menores ðŸŸ¢

### 6.1 `get_company_field_required()` tiene fallback silencioso

```python
# tablebase.py lÃ­nea 339
def get_company_field_required(cls) -> str:
    field = cls.get_company_field()
    if not field:
        return "emprcodi"   # â† Fallback silencioso
    return field
```

El nombre sugiere que "requiere" el campo (lanzarÃ­a excepciÃ³n si no existe), pero en realidad retorna `"emprcodi"` silenciosamente. El comentario lo llama "fallback de arranque". Nombre engaÃ±oso.

---

### 6.2 `row_get()` usa `readonly=False` en vez de `readonly=True`

```python
# tablebase.py lÃ­nea 430
_conn = conn or sess_conns.get_conn(readonly=False)  # â† DeberÃ­a ser True
```

Una lectura de un registro no requiere una conexiÃ³n de escritura. Esto puede afectar el uso del pool si hay poca diferenciaciÃ³n entre conexiones read-only y read-write.

---

### 6.3 `CODM_PAGO` tiene el mismo valor que `CODM_RECI`

```python
# CapaBRL/config.py lÃ­neas 25â€“29
CODM_RECI = "RECI"   # Recibos de cobro
CODM_PAGO = "RECI"   # Pagos a proveedores â† mismo valor que CODM_RECI
```

El comentario explica que comparten el mismo `codmcodi` diferenciando por `clpr`. Sin embargo, tener dos constantes con el mismo valor puede confundir â€” y de hecho `CODM_PAGO` no se usa en ningÃºn archivo de la BRL de pagos (`pagos_brl.py` usa el parÃ¡metro `codm_pago` directamente). Si es intencional, deberÃ­a documentarse mÃ¡s prominentemente; si no, es dead code.

---

### 6.4 Login acepta dos sets de nombres de campos de formulario

```python
# lina0.py lÃ­neas 395â€“401
user_code:       str = Form(""),
user_pass:       str = Form(""),
login_user_code: str = Form(""),
login_user_pass: str = Form(""),
...
submitted_user_code = (login_user_code or user_code or "").strip()
```

El endpoint POST `/login` acepta ambos `user_code`/`login_user_code` y combina el resultado. Esto sugiere que en algÃºn momento se renombraron los campos del formulario HTML pero se mantuvo compatibilidad hacia atrÃ¡s. DeberÃ­a unificarse.

---

### 6.5 `_insertar_renglon_recibo` definida en `remitos_brl.py`

La funciÃ³n de ayuda `_insertar_renglon_recibo()` en `remitos_brl.py` inserta en `linacode`, que es la tabla de renglones de **recibos**. EstÃ¡ en el mÃ³dulo de remitos porque el flujo de remito+cobro la necesita, pero conceptualmente pertenece a `recibos_brl.py`. El mÃ³dulo de recibos hace el mismo INSERT en lÃ­nea (dentro de `crear_recibo()`), por lo que existe duplicaciÃ³n entre la funciÃ³n helper y el cÃ³digo inline.

---

## Resumen de hallazgos

| # | CategorÃ­a | Severidad | DescripciÃ³n breve |
|---|---|---|---|
| 1.1 | DuplicaciÃ³n | ðŸ”´ Alta | `_get_empr()` y `_get_fecha_sesion()` copiadas en 11+ mÃ³dulos UI |
| 1.2 | DuplicaciÃ³n | ðŸ”´ Alta | lina41/lina43 (Caja/Banco) son el mismo archivo; pares 231/331, 261/361, 271/371, 272/372 |
| 1.3 | DuplicaciÃ³n | ðŸ”´ Alta | LÃ³gica de anulaciÃ³n de comprobantes duplicada en recibos/pagos BRL |
| 1.4 | DuplicaciÃ³n | ðŸŸ  Media | `set_prog_code()` repetido en cada endpoint del mismo mÃ³dulo |
| 2.1 | Inconsistencia | ðŸ”´ Alta | `get_table_ui_metadata` existe tanto en DAL como en BRL |
| 3.1 | Layer crossing | ðŸŸ  Media | 19 mÃ³dulos UI importan `APP_CONFIG` desde CapaDAL en vez de CapaBRL |
| 3.2 | Layer crossing | ðŸŸ  Media | `tablebase.py` (DAL) importa `SELECTOR_MAX_ROWS` desde CapaBRL |
| 3.3 | Layer crossing | ðŸŸ¡ Baja | SQL raw en BRL (complejidad transaccional justificada, pero es deuda tÃ©cnica) |
| 4.1 | Code smell | ðŸŸ¡ Baja | `__import__("datetime")` inline en lina41 y lina43 |
| 4.2 | Code smell | ðŸŸ¡ Baja | Clases vacÃ­as `class LinaXXX(linabase): pass` en ~30 mÃ³dulos |
| 4.3 | Code smell | ðŸŸ¡ Baja | IndentaciÃ³n de 8 espacios en primeros mÃ©todos de `TableBase` |
| 4.4 | Code smell | ðŸŸ  Media | `print()` como mecanismo de logging en toda la aplicaciÃ³n |
| 4.5 | Seguridad | ðŸ”´ Alta | Secret key de sesiÃ³n hardcoded `"lina-secret-key-not-final"` y fallback de password BD |
| 4.6 | Seguridad | ðŸ”´ Alta | Archivo `DeepSeek API-KEY.txt` dentro del Ã¡rbol de cÃ³digo fuente |
| 5.1 | Dead code | ðŸŸ¡ Baja | `miscelaneas/` contiene scripts sin integraciÃ³n al sistema |
| 5.2 | Dead code | ðŸŸ¡ Baja | `clear_table_model_cache()` sin usos detectados |
| 5.3 | Dead code | ðŸŸ¡ Baja | `ctx_prog` nunca se setea desde el middleware principal |
| 6.1 | Inconsistencia | ðŸŸ¡ Baja | `get_company_field_required()` tiene nombre engaÃ±oso por su fallback silencioso |
| 6.2 | Bug potencial | ðŸŸ  Media | `row_get()` solicita conexiÃ³n `readonly=False` para una operaciÃ³n de lectura |
| 6.3 | Inconsistencia | ðŸŸ¡ Baja | `CODM_PAGO == CODM_RECI` â€” constante duplicada o sin uso |
| 6.4 | Inconsistencia | ðŸŸ¡ Baja | Login acepta dos variantes de nombres de campo de formulario |
| 6.5 | DuplicaciÃ³n | ðŸŸ¡ Baja | `_insertar_renglon_recibo` en mÃ³dulo equivocado y lÃ³gica duplicada |
