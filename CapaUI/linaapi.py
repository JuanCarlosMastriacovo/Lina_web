from fastapi import APIRouter, Request, Query, HTTPException
from fastapi.responses import JSONResponse

from CapaBRL.linabase import linabase
from CapaBRL.config import SELECTOR_MAX_ROWS
from CapaDAL.tablebase import get_table_model

router = APIRouter()

# Tablas habilitadas para el selector genérico.
# Agregar aquí cada tabla maestra que deba ser buscable.
TABLAS_PERMITIDAS = {
    "linaclie",
    "linaempr",
    "linaarti",
    "linaartr"
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
            rows = Modelo.search_by_fields(campo_codigo_val, campo_desc_val, buscar_norm)
        else:
            rows = Modelo.list_all(
                order_by=campo_codigo_val,
                fields=[campo_codigo_val, campo_desc_val],
            )
            rows = rows[:SELECTOR_MAX_ROWS]
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