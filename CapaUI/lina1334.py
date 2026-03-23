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
PROG_CODE  = "LINA1334"
ROUTE_BASE = "/lina1334"

LinaArti          = get_table_model("linaarti")
LinaEmpr          = get_table_model("linaempr")
ARTICLE_KEY_FIELD = LinaArti.get_business_key_field()
EMPR_CODE_FIELD   = LinaEmpr.require_column("emprcodi")
EMPR_NAME_FIELD   = LinaEmpr.require_column("emprname")

pdf_templates_dir = Path(__file__).parent.parent / "templates"
pdf_jinja_env     = Environment(loader=FileSystemLoader(str(pdf_templates_dir)))


# ==================== CLASE PRINCIPAL ====================

class Lina1334(linabase):
    """Módulo de artículos bajo PMP (LINA1334)."""
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


def _get_filas(fecha_hasta: date) -> list:
    """
    Retorna filas [artrcodi, articodi, artidesc, exis, artipmpe, faltan, artiprec, valor]
    solo para artículos con artipmpe > 0 y exis < artipmpe, ordenados por artrcodi+articodi.
    """
    arts = LinaArti.list_all(
        order_by=ARTICLE_KEY_FIELD,
        fields=["articodi", "artidesc", "artrcodi", "artiprec", "artipmpe"],
    )
    if not arts:
        return []

    articodis    = [str(a.get("articodi") or "").strip() for a in arts]
    placeholders = ",".join(["%s"] * len(articodis))

    conn = sess_conns.get_conn(readonly=True)
    try:
        cur = conn.cursor()
        try:
            cur.execute(
                f"""
                SELECT a.articodi,
                       COALESCE(a.artiexan, 0)
                       + COALESCE((SELECT SUM(e.fcdecant) FROM linafcde e
                                    WHERE e.articodi = a.articodi
                                      AND e.fchefech <= %s), 0)
                       - COALESCE((SELECT SUM(s.fvdecant) FROM linafvde s
                                    WHERE s.articodi = a.articodi
                                      AND s.fvhefech <= %s), 0)
                  FROM linaarti a
                 WHERE a.articodi IN ({placeholders})
                """,
                [fecha_hasta, fecha_hasta] + articodis,
            )
            exist_map = {
                str(row[0] or "").strip(): (int(row[1]) if row[1] is not None else 0)
                for row in cur.fetchall()
            }
        finally:
            cur.close()
    finally:
        sess_conns.release_conn(conn)

    arts_sorted = sorted(arts, key=lambda a: (
        str(a.get("artrcodi") or "").strip(),
        str(a.get("articodi") or "").strip(),
    ))

    filas = []
    for a in arts_sorted:
        articodi = str(a.get("articodi") or "").strip()
        artrcodi = str(a.get("artrcodi") or "").strip()
        artidesc = str(a.get("artidesc") or "")
        artiprec = float(a.get("artiprec") or 0)
        artipmpe = int(a.get("artipmpe") or 0)
        exis     = exist_map.get(articodi, 0)

        if artipmpe <= 0 or exis >= artipmpe:
            continue

        faltan = artipmpe - exis
        valor  = faltan * artiprec
        filas.append([artrcodi, articodi, artidesc, exis, artipmpe, faltan, artiprec, valor])

    return filas


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina1334_index(request: Request):
    Lina1334.set_prog_code(PROG_CODE)
    user = Lina1334.get_current_user(request)
    if not user:
        return RedirectResponse("/login")
    return Lina1334.templates.TemplateResponse(
        "lina1334/seleccion.html",
        {"request": request, "error": None, "hoy": date.today().isoformat()},
    )


@router.get("/pdf")
async def lina1334_pdf(
    request: Request,
    fecha_hasta: str = Query(default=""),
):
    Lina1334.set_prog_code(PROG_CODE)
    user = Lina1334.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    try:
        fh = date.fromisoformat(fecha_hasta) if fecha_hasta else date.today()
    except ValueError:
        fh = date.today()

    empr_code, empr_name = _get_empr_info()
    filas = _get_filas(fh)

    total_valor = sum(f[7] for f in filas)

    filas_pdf = [
        [f[0], f[1], f[2], f[3], f[4], f[5], _fmt_price(f[6]), _fmt_price(f[7])]
        for f in filas
    ]

    template = pdf_jinja_env.get_template("lina1334/main.html")
    html_str = template.render(
        app_name        = APP_CONFIG.get("app_name", ""),
        app_description = APP_CONFIG.get("app_description", ""),
        prog_code    = PROG_CODE,
        empr_code    = empr_code,
        empr_name    = empr_name,
        usuario      = user,
        titulo       = "Artículos Bajo Punto Mínimo de Pedido",
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
        headers    = {"Content-Disposition": "inline; filename=articulos_bajo_pmp.pdf"},
    )


@router.get("/xlsx")
async def lina1334_xlsx(
    request: Request,
    fecha_hasta: str = Query(default=""),
):
    Lina1334.set_prog_code(PROG_CODE)
    user = Lina1334.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    try:
        fh = date.fromisoformat(fecha_hasta) if fecha_hasta else date.today()
    except ValueError:
        fh = date.today()

    empr_code, empr_name = _get_empr_info()
    filas = _get_filas(fh)

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Bajo PMP"

    title_font    = Font(bold=True, size=12)
    subtitle_font = Font(size=8, color="555555")
    header_font   = Font(bold=True, color="FFFFFF", size=9)
    header_fill   = PatternFill("solid", fgColor="4472C4")
    header_align  = Alignment(horizontal="left", vertical="center")
    total_font    = Font(bold=True, size=9)
    PRICE_FMT     = '#,##0.00;-#,##0.00'

    ncols    = 8
    last_col = openpyxl.utils.get_column_letter(ncols)

    ws.merge_cells(f"A1:{last_col}1")
    ws["A1"]      = "Artículos Bajo Punto Mínimo de Pedido"
    ws["A1"].font = title_font

    ws.merge_cells(f"A2:{last_col}2")
    ws["A2"]      = f"{APP_CONFIG.get('app_name', '')} — {empr_code} {empr_name}"
    ws["A2"].font = subtitle_font

    ws.merge_cells(f"A3:{last_col}3")
    ws["A3"]      = (f"Al {fh.strftime('%d/%m/%Y')} — "
                     f"Usuario: {user} — "
                     f"{date.today().strftime('%d/%m/%Y')} {datetime.now().strftime('%H:%M')}")
    ws["A3"].font = subtitle_font

    ws.append([])  # fila 4 vacía

    headers = ["Rubro", "Código", "Descripción", "Existencia", "PMP", "Faltan", "Precio", "Valor"]
    ws.append(headers)   # fila 5
    for cell in ws[5]:
        cell.font      = header_font
        cell.fill      = header_fill
        cell.alignment = header_align

    DATA_START = 6
    for i, fila in enumerate(filas):
        row_num = DATA_START + i
        # A=artrcodi B=articodi C=artidesc D=exis E=artipmpe F=faltan G=artiprec H=valor
        ws.append([fila[0], fila[1], fila[2], fila[3], fila[4], None, fila[6], None])
        ws.cell(row=row_num, column=6).value         = f"=E{row_num}-D{row_num}"
        ws.cell(row=row_num, column=7).number_format = PRICE_FMT
        ws.cell(row=row_num, column=8).value         = f"=F{row_num}*G{row_num}"
        ws.cell(row=row_num, column=8).number_format = PRICE_FMT

    total_row = DATA_START + len(filas)
    last_data = total_row - 1
    ws.append(["", "", "TOTAL", "", "", "", "", f"=SUM(H{DATA_START}:H{last_data})"])
    for cell in ws[total_row]:
        cell.font = total_font
    ws.cell(row=total_row, column=8).number_format = PRICE_FMT

    ws.column_dimensions["A"].width = 8
    ws.column_dimensions["B"].width = 12
    ws.column_dimensions["C"].width = 38
    ws.column_dimensions["D"].width = 12
    ws.column_dimensions["E"].width = 10
    ws.column_dimensions["F"].width = 10
    ws.column_dimensions["G"].width = 14
    ws.column_dimensions["H"].width = 14

    buffer = BytesIO()
    wb.save(buffer)
    buffer.seek(0)

    return Response(
        content    = buffer.read(),
        media_type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers    = {"Content-Disposition": "attachment; filename=articulos_bajo_pmp.xlsx"},
    )
