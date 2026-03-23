from fastapi import APIRouter, Request, Query
from fastapi.responses import Response, HTMLResponse, RedirectResponse
from weasyprint import HTML
from jinja2 import Environment, FileSystemLoader
from pathlib import Path
from datetime import date, datetime
from io import BytesIO

import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter

from CapaBRL.linabase import linabase
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import ctx_empr
from CapaDAL.config import APP_CONFIG

# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA1333"
ROUTE_BASE = "/lina1333"

LinaArti          = get_table_model("linaarti")
LinaArtr          = get_table_model("linaartr")
LinaEmpr          = get_table_model("linaempr")
ARTICLE_KEY_FIELD = LinaArti.get_business_key_field()
ARTR_KEY_FIELD    = LinaArtr.get_business_key_field()
EMPR_CODE_FIELD   = LinaEmpr.require_column("emprcodi")
EMPR_NAME_FIELD   = LinaEmpr.require_column("emprname")

pdf_templates_dir = Path(__file__).parent.parent / "templates"
pdf_jinja_env     = Environment(loader=FileSystemLoader(str(pdf_templates_dir)))


# ==================== CLASE PRINCIPAL ====================

class Lina1333(linabase):
    """Módulo de listado de existencia valorizada (LINA1333)."""
    pass


# ==================== FUNCIONES AUXILIARES ====================

def _get_empr_info():
    empr_code = ctx_empr.get() or "01"
    empr_rec  = LinaEmpr.row_get({EMPR_CODE_FIELD: empr_code})
    empr_name = str(empr_rec.get(EMPR_NAME_FIELD) or "").strip() if empr_rec else ""
    return empr_code, empr_name


def _fmt_price(val: float) -> str:
    """Precio con punto de miles y coma decimal: 1.234,56"""
    return f"{val:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")


def _calc_exist(conn, articodi: str, fecha_hasta: date) -> int:
    """Llama a sp_calc_exist y retorna la existencia a la fecha dada."""
    cur = conn.cursor()
    try:
        cur.execute(
            "CALL sp_calc_exist(%s, %s, @_lina_e)",
            (articodi, fecha_hasta),
        )
        cur.fetchall()          # drena cualquier result set del CALL
        cur.execute("SELECT @_lina_e")
        row = cur.fetchone()
        val = row[0] if row and row[0] is not None else -1
        return int(val)
    finally:
        cur.close()


def _get_rubros(conn) -> dict:
    rubros = {}
    try:
        rubro_field_desc = LinaArtr.get_selector_fields()[1]
        for r in LinaArtr.list_all(fields=[ARTR_KEY_FIELD, rubro_field_desc], conn=conn):
            rubros[str(r.get(ARTR_KEY_FIELD) or "").strip()] = str(r.get(rubro_field_desc) or "").strip()
    except Exception:
        pass
    return rubros


def _get_filas(conn, fecha_hasta: date) -> list:
    """
    Retorna filas [artrcodi, articodi, artidesc, exis(int), artiprec(float), valor(float)]
    ordenadas por artrcodi, articodi.
    """
    arts = LinaArti.list_all(
        order_by=ARTICLE_KEY_FIELD,
        fields=["articodi", "artidesc", "artrcodi", "artiprec"],
        conn=conn,
    )

    # Ordenar por (artrcodi, articodi) en Python
    arts = sorted(arts, key=lambda a: (
        str(a.get("artrcodi") or "").strip(),
        str(a.get("articodi") or "").strip(),
    ))

    filas = []
    for a in arts:
        articodi = str(a.get("articodi") or "").strip()
        artrcodi = str(a.get("artrcodi") or "").strip()
        artidesc = str(a.get("artidesc") or "")
        artiprec = float(a.get("artiprec") or 0)
        exis     = _calc_exist(conn, articodi, fecha_hasta)
        valor    = exis * artiprec
        filas.append([artrcodi, articodi, artidesc, exis, artiprec, valor])

    return filas


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina1333_index(request: Request):
    Lina1333.set_prog_code(PROG_CODE)
    user = Lina1333.get_current_user(request)
    if not user:
        return RedirectResponse("/login")
    return Lina1333.templates.TemplateResponse(
        "lina1333/seleccion.html",
        {"request": request, "error": None, "hoy": date.today().isoformat()},
    )


@router.get("/pdf")
async def lina1333_pdf(
    request: Request,
    fecha_hasta: str = Query(default=""),
):
    Lina1333.set_prog_code(PROG_CODE)
    user = Lina1333.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    try:
        fh = date.fromisoformat(fecha_hasta) if fecha_hasta else date.today()
    except ValueError:
        fh = date.today()

    empr_code, empr_name = _get_empr_info()
    conn  = Lina1333.get_task_conn(request, readonly=True)
    filas = _get_filas(conn, fh)

    total_valor = sum(f[5] for f in filas)

    # Formatear precios para PDF (mantener exis como int)
    filas_pdf = [
        [f[0], f[1], f[2], f[3], _fmt_price(f[4]), _fmt_price(f[5])]
        for f in filas
    ]

    template = pdf_jinja_env.get_template("lina1333/main.html")
    html_str = template.render(
        app_name        = APP_CONFIG.get("app_name", ""),
        app_description = APP_CONFIG.get("app_description", ""),
        prog_code    = PROG_CODE,
        empr_code    = empr_code,
        empr_name    = empr_name,
        usuario      = user,
        titulo       = "Existencia Valorizada",
        fecha_hasta  = fh.strftime("%d/%m/%Y"),
        fecha        = date.today().strftime("%d/%m/%Y"),
        hora         = datetime.now().strftime("%H:%M"),
        filas        = filas_pdf,
        total_valor  = _fmt_price(total_valor),
    )

    pdf = HTML(string=html_str).write_pdf()
    return Response(
        content    = pdf,
        media_type = "application/pdf",
        headers    = {"Content-Disposition": "inline; filename=exist_valorizada.pdf"},
    )


@router.get("/xlsx")
async def lina1333_xlsx(
    request: Request,
    fecha_hasta: str = Query(default=""),
):
    Lina1333.set_prog_code(PROG_CODE)
    user = Lina1333.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    try:
        fh = date.fromisoformat(fecha_hasta) if fecha_hasta else date.today()
    except ValueError:
        fh = date.today()

    empr_code, empr_name = _get_empr_info()
    conn  = Lina1333.get_task_conn(request, readonly=True)
    filas = _get_filas(conn, fh)

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Exist. Valorizada"

    title_font    = Font(bold=True, size=12)
    subtitle_font = Font(size=8, color="555555")
    header_font   = Font(bold=True, color="FFFFFF", size=9)
    header_fill   = PatternFill("solid", fgColor="4472C4")
    header_align  = Alignment(horizontal="left", vertical="center")
    total_font    = Font(bold=True, size=9)
    PRICE_FMT     = '#,##0.00;-#,##0.00'

    ws.merge_cells("A1:F1")
    ws["A1"]      = "Existencia Valorizada"
    ws["A1"].font = title_font

    ws.merge_cells("A2:F2")
    ws["A2"]      = f"{APP_CONFIG.get('app_name', '')} — {empr_code} {empr_name}"
    ws["A2"].font = subtitle_font

    ws.merge_cells("A3:F3")
    ws["A3"]      = (f"Al {fh.strftime('%d/%m/%Y')} — "
                     f"Usuario: {user} — "
                     f"{date.today().strftime('%d/%m/%Y')} {datetime.now().strftime('%H:%M')}")
    ws["A3"].font = subtitle_font

    ws.append([])  # fila 4 vacía

    headers = ["Rubro", "Código", "Descripción", "Existencia", "Precio", "Valor"]
    ws.append(headers)   # fila 5
    for cell in ws[5]:
        cell.font      = header_font
        cell.fill      = header_fill
        cell.alignment = header_align

    DATA_START = 6
    for i, fila in enumerate(filas):
        row_num = DATA_START + i
        # A=artrcodi, B=articodi, C=artidesc, D=exis, E=artiprec, F=fórmula
        ws.append([fila[0], fila[1], fila[2], fila[3], fila[4], None])
        ws.cell(row=row_num, column=5).number_format = PRICE_FMT
        ws.cell(row=row_num, column=6).value         = f"=D{row_num}*E{row_num}"
        ws.cell(row=row_num, column=6).number_format = PRICE_FMT

    # Fila de total
    total_row = DATA_START + len(filas)
    ws.append(["", "", "TOTAL", "", "", f"=SUM(F{DATA_START}:F{total_row - 1})"])
    for cell in ws[total_row]:
        cell.font = total_font
    ws.cell(row=total_row, column=6).number_format = PRICE_FMT

    ws.column_dimensions["A"].width = 8
    ws.column_dimensions["B"].width = 12
    ws.column_dimensions["C"].width = 40
    ws.column_dimensions["D"].width = 12
    ws.column_dimensions["E"].width = 14
    ws.column_dimensions["F"].width = 14

    buffer = BytesIO()
    wb.save(buffer)
    buffer.seek(0)

    return Response(
        content    = buffer.read(),
        media_type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers    = {"Content-Disposition": "attachment; filename=exist_valorizada.xlsx"},
    )
