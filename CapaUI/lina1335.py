from fastapi import APIRouter, Request, Query
from fastapi.responses import Response, HTMLResponse, RedirectResponse
from weasyprint import HTML
from jinja2 import Environment, FileSystemLoader
from pathlib import Path
from datetime import date, datetime
from io import BytesIO

import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment

from CapaBRL.linabase import linabase
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import ctx_empr, sess_conns
from CapaDAL.config import APP_CONFIG

# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA1335"
ROUTE_BASE = "/lina1335"

LinaArti          = get_table_model("linaarti")
LinaEmpr          = get_table_model("linaempr")
ARTICLE_KEY_FIELD = LinaArti.get_business_key_field()
EMPR_CODE_FIELD   = LinaEmpr.require_column("emprcodi")
EMPR_NAME_FIELD   = LinaEmpr.require_column("emprname")

pdf_templates_dir = Path(__file__).parent.parent / "templates"
pdf_jinja_env     = Environment(loader=FileSystemLoader(str(pdf_templates_dir)))


# ==================== CLASE PRINCIPAL ====================

class Lina1335(linabase):
    """Módulo de ventas de artículos por período (LINA1335)."""
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


def _get_filas(fecha_ini: date, fecha_fin: date) -> list:
    """
    Retorna filas [articodi, artidesc, vendidas, artiprec, valor, artipmpe, existencia]
    para TODOS los artículos (vendidas=0 si no hubo ventas en el período),
    ordenadas por valor DESC, luego articodi ASC.

    Existencia calculada al fecha_fin usando la misma lógica que lina1333/1334.
    """
    # list_all gestiona su propia conexión del pool (aplica filtro de empresa)
    arts = LinaArti.list_all(
        order_by=ARTICLE_KEY_FIELD,
        fields=["articodi", "artidesc", "artiprec", "artipmpe"],
    )
    if not arts:
        return []

    articodis    = [str(a.get("articodi") or "").strip() for a in arts]
    placeholders = ",".join(["%s"] * len(articodis))

    conn = sess_conns.get_conn(readonly=True)
    try:
        cur = conn.cursor()
        try:
            # Unidades vendidas por artículo en el período
            cur.execute(
                f"SELECT articodi, SUM(fvdecant) "
                f"  FROM linafvde "
                f" WHERE fvdecant > 0 "
                f"   AND fvhefech >= %s AND fvhefech <= %s "
                f"   AND articodi IN ({placeholders}) "
                f" GROUP BY articodi",
                [fecha_ini, fecha_fin] + articodis,
            )
            venta_map = {
                str(row[0] or "").strip(): int(row[1] or 0)
                for row in cur.fetchall()
            }

            # Existencia al fecha_fin (cardex)
            cur.execute(
                f"""SELECT a.articodi,
                           COALESCE(a.artiexan, 0)
                           + COALESCE((SELECT SUM(e.fcdecant) FROM linafcde e
                                        WHERE e.articodi = a.articodi
                                          AND e.fchefech <= %s), 0)
                           - COALESCE((SELECT SUM(s.fvdecant) FROM linafvde s
                                        WHERE s.articodi = a.articodi
                                          AND s.fvhefech <= %s), 0)
                      FROM linaarti a
                     WHERE a.articodi IN ({placeholders})""",
                [fecha_fin, fecha_fin] + articodis,
            )
            exist_map = {
                str(row[0] or "").strip(): (int(row[1]) if row[1] is not None else 0)
                for row in cur.fetchall()
            }
        finally:
            cur.close()
    finally:
        sess_conns.release_conn(conn)

    filas = []
    for a in arts:
        articodi = str(a.get("articodi") or "").strip()
        artidesc = str(a.get("artidesc") or "")
        artiprec = float(a.get("artiprec") or 0)
        artipmpe = int(a.get("artipmpe") or 0)
        vendidas = venta_map.get(articodi, 0)
        valor    = vendidas * artiprec
        exis     = exist_map.get(articodi, 0)
        filas.append([articodi, artidesc, vendidas, artiprec, valor, artipmpe, exis])

    # Orden: valor DESC, luego código ASC (igual que FoxPro IdxValo desc)
    filas.sort(key=lambda f: (-f[4], f[0]))
    return filas


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina1335_index(request: Request):
    Lina1335.set_prog_code(PROG_CODE)
    user = Lina1335.get_current_user(request)
    if not user:
        return RedirectResponse("/login")
    hoy = date.today().isoformat()
    return Lina1335.templates.TemplateResponse(
        "lina1335/seleccion.html",
        {"request": request, "error": None, "hoy": hoy},
    )


@router.get("/pdf")
async def lina1335_pdf(
    request: Request,
    fecha_ini: str = Query(default=""),
    fecha_fin: str = Query(default=""),
):
    Lina1335.set_prog_code(PROG_CODE)
    user = Lina1335.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    hoy = date.today()
    try:
        fi = date.fromisoformat(fecha_ini) if fecha_ini else hoy
    except ValueError:
        fi = hoy
    try:
        ff = date.fromisoformat(fecha_fin) if fecha_fin else hoy
    except ValueError:
        ff = hoy

    if fi > ff:
        return Lina1335.templates.TemplateResponse(
            "lina1335/seleccion.html",
            {"request": request, "error": "La fecha inicial no puede ser mayor que la final.", "hoy": hoy.isoformat()},
        )

    empr_code, empr_name = _get_empr_info()
    filas = _get_filas(fi, ff)

    total_valor = sum(f[4] for f in filas)

    filas_pdf = [
        [f[0], f[1], f[2], _fmt_price(f[3]), _fmt_price(f[4]), f[5], f[6]]
        for f in filas
    ]

    template = pdf_jinja_env.get_template("lina1335/main.html")
    html_str = template.render(
        app_name        = APP_CONFIG.get("app_name", ""),
        app_description = APP_CONFIG.get("app_description", ""),
        prog_code   = PROG_CODE,
        empr_code   = empr_code,
        empr_name   = empr_name,
        usuario     = user,
        titulo      = "Ventas de Artículos por Período",
        fecha_ini   = fi.strftime("%d/%m/%Y"),
        fecha_fin   = ff.strftime("%d/%m/%Y"),
        fecha       = hoy.strftime("%d/%m/%Y"),
        hora        = datetime.now().strftime("%H:%M"),
        filas       = filas_pdf,
        total_valor = _fmt_price(total_valor),
    )

    pdf = HTML(string=html_str).write_pdf()
    return Response(
        content    = pdf,
        media_type = "application/pdf",
        headers    = {"Content-Disposition": "inline; filename=ventas_articulos.pdf"},
    )


@router.get("/xlsx")
async def lina1335_xlsx(
    request: Request,
    fecha_ini: str = Query(default=""),
    fecha_fin: str = Query(default=""),
):
    Lina1335.set_prog_code(PROG_CODE)
    user = Lina1335.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    hoy = date.today()
    try:
        fi = date.fromisoformat(fecha_ini) if fecha_ini else hoy
    except ValueError:
        fi = hoy
    try:
        ff = date.fromisoformat(fecha_fin) if fecha_fin else hoy
    except ValueError:
        ff = hoy

    if fi > ff:
        return Lina1335.templates.TemplateResponse(
            "lina1335/seleccion.html",
            {"request": request, "error": "La fecha inicial no puede ser mayor que la final.", "hoy": hoy.isoformat()},
        )

    empr_code, empr_name = _get_empr_info()
    filas = _get_filas(fi, ff)

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Ventas por Período"

    title_font    = Font(bold=True, size=12)
    subtitle_font = Font(size=8, color="555555")
    header_font   = Font(bold=True, color="FFFFFF", size=9)
    header_fill   = PatternFill("solid", fgColor="4472C4")
    header_align  = Alignment(horizontal="left", vertical="center")
    total_font    = Font(bold=True, size=9)
    PRICE_FMT     = '#,##0.00;-#,##0.00'

    ncols    = 7
    last_col = openpyxl.utils.get_column_letter(ncols)

    ws.merge_cells(f"A1:{last_col}1")
    ws["A1"]      = "Ventas de Artículos por Período"
    ws["A1"].font = title_font

    ws.merge_cells(f"A2:{last_col}2")
    ws["A2"]      = f"{APP_CONFIG.get('app_name', '')} — {empr_code} {empr_name}"
    ws["A2"].font = subtitle_font

    ws.merge_cells(f"A3:{last_col}3")
    ws["A3"]      = (f"Desde {fi.strftime('%d/%m/%Y')} hasta {ff.strftime('%d/%m/%Y')} — "
                     f"Usuario: {user} — "
                     f"{hoy.strftime('%d/%m/%Y')} {datetime.now().strftime('%H:%M')}")
    ws["A3"].font = subtitle_font

    ws.append([])   # fila 4 vacía

    headers = ["Código", "Descripción", "Vendidas", "Precio", "Valor Vta.", "PMP", "Existencia"]
    ws.append(headers)   # fila 5
    for cell in ws[5]:
        cell.font      = header_font
        cell.fill      = header_fill
        cell.alignment = header_align

    DATA_START = 6
    for i, fila in enumerate(filas):
        row_num = DATA_START + i
        # A=articodi B=artidesc C=vendidas D=artiprec E=valor F=artipmpe G=exis
        ws.append([fila[0], fila[1], fila[2], fila[3], None, fila[5], fila[6]])
        ws.cell(row=row_num, column=4).number_format = PRICE_FMT
        ws.cell(row=row_num, column=5).value         = f"=C{row_num}*D{row_num}"
        ws.cell(row=row_num, column=5).number_format = PRICE_FMT

    total_row = DATA_START + len(filas)
    last_data = total_row - 1
    ws.append(["", "TOTAL", "", "", f"=SUM(E{DATA_START}:E{last_data})", "", ""])
    for cell in ws[total_row]:
        cell.font = total_font
    ws.cell(row=total_row, column=5).number_format = PRICE_FMT

    ws.column_dimensions["A"].width = 12
    ws.column_dimensions["B"].width = 42
    ws.column_dimensions["C"].width = 12
    ws.column_dimensions["D"].width = 14
    ws.column_dimensions["E"].width = 16
    ws.column_dimensions["F"].width = 8
    ws.column_dimensions["G"].width = 12

    buffer = BytesIO()
    wb.save(buffer)
    buffer.seek(0)

    return Response(
        content    = buffer.read(),
        media_type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers    = {"Content-Disposition": "attachment; filename=ventas_articulos.xlsx"},
    )
