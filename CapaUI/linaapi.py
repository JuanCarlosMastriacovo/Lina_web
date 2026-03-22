from fastapi import APIRouter, Request, Query, HTTPException
from fastapi.responses import JSONResponse

from CapaBRL.linabase import linabase
from CapaDAL.tablebase import get_table_model

router = APIRouter()

# Tablas habilitadas para el selector genérico.
# Agregar aquí cada tabla maestra que deba ser buscable.
TABLAS_PERMITIDAS = {
    "linaclie",
    "linaempr",
    # agregar más tablas según se necesite
}


@router.get("/api/selector")
async def selector_buscar(
    request:      Request,
    tabla:        str = Query(...),
    campo_codigo: str = Query(...),
    campo_desc:   str = Query(...),
    buscar:       str = Query(default=""),
) -> JSONResponse:
    """
    Endpoint genérico de búsqueda para el selector modal.
    Valida tabla y campos contra metadata antes de ejecutar la consulta.
    """
    user = linabase.get_current_user(request)
    if not user:
        raise HTTPException(status_code=401, detail="No autenticado")

    # Validar tabla
    tabla_norm = (tabla or "").strip().lower()
    if tabla_norm not in TABLAS_PERMITIDAS:
        raise HTTPException(status_code=400, detail=f"Tabla '{tabla}' no permitida en el selector")

    # Cargar modelo y validar campos
    try:
        Modelo = get_table_model(tabla_norm)
        campo_codigo_val = Modelo.require_column(campo_codigo.strip().lower())
        campo_desc_val   = Modelo.require_column(campo_desc.strip().lower())
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    # Ejecutar búsqueda
    buscar_norm = (buscar or "").strip()
    try:
        if buscar_norm:
            like = f"%{buscar_norm}%"
            company_field = Modelo.get_company_field_required()
            from CapaDAL.dataconn import sess_conns, ctx_empr
            conn = sess_conns.get_conn(readonly=True)
            try:
                cur = conn.cursor(dictionary=True)
                cur.execute(
                    f"SELECT {campo_codigo_val}, {campo_desc_val} "
                    f"FROM {Modelo.TABLE_NAME} "
                    f"WHERE {company_field} = %s "
                    f"AND ({campo_desc_val} LIKE %s OR CAST({campo_codigo_val} AS CHAR) LIKE %s) "
                    f"ORDER BY {campo_codigo_val} "
                    f"LIMIT 200",
                    (ctx_empr.get(), like, like),
                )
                rows = cur.fetchall()
            finally:
                sess_conns.release_conn(conn)
        else:
            rows = Modelo.list_all(
                order_by=campo_codigo_val,
                fields=[campo_codigo_val, campo_desc_val],
            )
            rows = rows[:200]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en búsqueda: {e}")

    return JSONResponse({
        "ok":           True,
        "campo_codigo": campo_codigo_val,
        "campo_desc":   campo_desc_val,
        "rows":         [
            {
                "codigo": str(row.get(campo_codigo_val) or ""),
                "desc":   str(row.get(campo_desc_val)   or ""),
            }
            for row in (rows or [])
        ],
    })