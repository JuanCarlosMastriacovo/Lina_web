from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from datetime import date
from decimal import Decimal
import traceback

from CapaBRL.linabase import linabase
from CapaDAL.tablebase import get_table_model
from CapaDAL.dataconn import sess_conns, ctx_empr, ctx_date


# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA21"
ROUTE_BASE = "/lina21"

CODM_REMI   = "REMI"
CODM_RECI   = "RECI"
CLIE_AJUSTE = 9000      # Cliente especial para ajustes de stock (unitario=0)

LinaArti = get_table_model("linaarti")
LinaClie = get_table_model("linaclie")
LinaEmpr = get_table_model("linaempr")


# ==================== CLASE PRINCIPAL ====================

class Lina21(linabase):
    """Módulo de Emisión de Remitos de Venta (LINA21)."""
    pass


# ==================== FUNCIONES AUXILIARES ====================

def _get_fecha_sesion() -> date:
    """Retorna la fecha de sesión (ctx_date) como objeto date."""
    raw = ctx_date.get()
    if raw:
        try:
            return date.fromisoformat(raw)
        except ValueError:
            pass
    return date.today()


def _get_empr_info():
    empr_code = ctx_empr.get() or "01"
    rec = LinaEmpr.row_get({"emprcodi": empr_code})
    empr_name = str(rec.get("emprname") or "").strip() if rec else ""
    return empr_code, empr_name


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina21_index(request: Request):
    Lina21.set_prog_code(PROG_CODE)
    user = Lina21.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    is_htmx = request.headers.get("HX-Request") == "true"
    ctx = {"request": request, "clie_ajuste": CLIE_AJUSTE}
    if is_htmx:
        return Lina21.templates.TemplateResponse("lina21/form.html", ctx)
    return Lina21.templates.TemplateResponse("lina21/main.html", ctx)


@router.get("/clie/info")
async def lina21_clie_info(request: Request, cliecodi: str = Query(default="")):
    empr = ctx_empr.get() or "01"
    try:
        cod = int(cliecodi)
    except (ValueError, TypeError):
        return JSONResponse({"ok": False, "cliename": ""})
    rec = LinaClie.row_get({"emprcodi": empr, "cliecodi": cod})
    if not rec:
        return JSONResponse({"ok": False, "cliename": ""})
    return JSONResponse({"ok": True, "cliename": str(rec.get("cliename") or "").strip()})


@router.get("/arti/info")
async def lina21_arti_info(request: Request, articodi: str = Query(default="")):
    empr     = ctx_empr.get() or "01"
    articodi = articodi.strip().upper()
    if not articodi:
        return JSONResponse({"ok": False})
    rec = LinaArti.row_get({"emprcodi": empr, "articodi": articodi})
    if not rec:
        return JSONResponse({"ok": False, "error": "Artículo no encontrado"})

    conn = sess_conns.get_conn(readonly=True)
    try:
        cur = conn.cursor()
        cur.execute(
            """
            SELECT COALESCE(a.artiexan, 0)
                   + COALESCE((SELECT SUM(e.fcdecant) FROM linafcde e
                                WHERE e.emprcodi = %s AND e.articodi = %s), 0)
                   - COALESCE((SELECT SUM(s.fvdecant) FROM linafvde s
                                WHERE s.emprcodi = %s AND s.articodi = %s), 0)
              FROM linaarti a
             WHERE a.emprcodi = %s AND a.articodi = %s
            """,
            (empr, articodi, empr, articodi, empr, articodi),
        )
        row        = cur.fetchone()
        existencia = int(row[0]) if row and row[0] is not None else 0
    finally:
        sess_conns.release_conn(conn)

    return JSONResponse({
        "ok":         True,
        "artidesc":   str(rec.get("artidesc") or "").strip(),
        "artiprec":   float(rec.get("artiprec") or 0),
        "existencia": existencia,
    })


@router.post("/save")
async def lina21_save(request: Request):
    user = Lina21.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    try:
        data = await request.json()
    except Exception:
        return JSONResponse({"ok": False, "error": "Datos inválidos"}, status_code=400)

    empr     = ctx_empr.get() or "01"
    fvhefech = _get_fecha_sesion()   # fecha de sesión, no la envía el frontend

    # ── Parse header ────────────────────────────────────────────────────────
    try:
        cliecodi = int(data.get("cliecodi", 0))
    except (ValueError, TypeError):
        cliecodi = 0
    if cliecodi <= 0:
        return JSONResponse({"ok": False, "error": "Debe ingresar un código de cliente válido."}, status_code=400)

    fvheobse = str(data.get("fvheobse", "")).strip()[:40]

    try:
        efec = Decimal(str(data.get("efec", 0) or 0))
        banc = Decimal(str(data.get("banc", 0) or 0))
    except Exception:
        efec = Decimal(0)
        banc = Decimal(0)
    if efec < 0:
        efec = Decimal(0)
    if banc < 0:
        banc = Decimal(0)

    # ── Parse detail lines ───────────────────────────────────────────────────
    lineas_raw = data.get("lineas", [])
    lineas     = []
    reng       = 0
    for ln in lineas_raw:
        articodi = str(ln.get("articodi", "")).strip().upper()
        if not articodi or articodi == "*":
            continue
        reng += 1
        desc = str(ln.get("desc", "")).strip()[:40]
        try:
            cant = int(ln.get("cant", 0) or 0)
        except (ValueError, TypeError):
            cant = 0
        try:
            unit = Decimal(str(ln.get("unit", 0) or 0))
        except Exception:
            unit = Decimal(0)
        lineas.append({
            "fvdereng": reng,
            "articodi": articodi,
            "fvdedesc": desc,
            "fvdecant": cant,
            "fvdeunit": unit,
        })

    # ── Validate ────────────────────────────────────────────────────────────
    is_ajuste = (cliecodi == CLIE_AJUSTE)
    fvhetota  = sum(ln["fvdecant"] * ln["fvdeunit"] for ln in lineas)
    if not is_ajuste:
        if not lineas or fvhetota <= 0:
            return JSONResponse(
                {"ok": False, "error": "No se admiten comprobantes vacíos o con total cero."},
                status_code=400,
            )

    # ── Get connection ────────────────────────────────────────────────────────
    tab_id    = Lina21.get_tab_id(request)
    conn      = Lina21.get_task_conn(request, readonly=False)
    owns_conn = False
    if not conn:
        conn      = sess_conns.get_conn(readonly=False)
        owns_conn = True

    try:
        cur = conn.cursor()

        # Validate client exists
        cur.execute(
            "SELECT cliecodi FROM linaclie WHERE emprcodi=%s AND cliecodi=%s",
            (empr, cliecodi),
        )
        if not cur.fetchone():
            cur.close()
            if owns_conn:
                sess_conns.release_conn(conn)
            return JSONResponse({"ok": False, "error": f"Cliente {cliecodi} no encontrado."}, status_code=400)

        # ── Next fvhenume ────────────────────────────────────────────────────
        cur.execute(
            "SELECT COALESCE(MAX(fvhenume), 0) + 1 FROM linafvhe WHERE emprcodi=%s AND codmcodi=%s",
            (empr, CODM_REMI),
        )
        fvhenume = cur.fetchone()[0]

        # ── INSERT linafvhe ──────────────────────────────────────────────────
        cur.execute(
            "INSERT INTO linafvhe"
            "  (emprcodi, codmcodi, fvhenume, fvhefech, cliecodi, fvhetota, fvheobse, fvhereci)"
            " VALUES (%s, %s, %s, %s, %s, %s, %s, 0)",
            (empr, CODM_REMI, fvhenume, fvhefech, cliecodi, float(fvhetota), fvheobse),
        )

        # ── INSERT linafvde ──────────────────────────────────────────────────
        for ln in lineas:
            unit_val = 0.0 if is_ajuste else float(ln["fvdeunit"])
            cur.execute(
                "INSERT INTO linafvde"
                "  (emprcodi, codmcodi, fvhenume, fvdereng, fvhefech,"
                "   articodi, fvdedesc, fvdecant, fvdeunit)"
                " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                (empr, CODM_REMI, fvhenume, ln["fvdereng"], fvhefech,
                 ln["articodi"], ln["fvdedesc"], ln["fvdecant"], unit_val),
            )

        # ── INSERT linactcl (remito DEBE) ────────────────────────────────────
        cur.execute(
            "INSERT INTO linactcl"
            "  (emprcodi, cliecodi, ctclfech, codmcodi, ctclnumc, ctcldebe, ctclhabe)"
            " VALUES (%s, %s, %s, %s, %s, %s, 0)",
            (empr, cliecodi, fvhefech, CODM_REMI, fvhenume, float(fvhetota)),
        )

        # ── Payment ──────────────────────────────────────────────────────────
        cohenume = None
        if not is_ajuste:
            ctacte = fvhetota - efec - banc
            if ctacte < 0:
                ctacte = Decimal(0)
            efec_f   = float(efec)
            banc_f   = float(banc)
            ctacte_f = float(ctacte)
            total_f  = float(fvhetota)

            cur.execute(
                "SELECT COALESCE(MAX(cohenume), 0) + 1 FROM linacohe WHERE emprcodi=%s AND codmcodi=%s",
                (empr, CODM_RECI),
            )
            cohenume = cur.fetchone()[0]

            cobrado   = efec + banc
            cobrado_f = float(cobrado)

            cur.execute(
                "INSERT INTO linacohe"
                "  (emprcodi, codmcodi, cohenume, cohefech, cliecodi,"
                "   cohetota, coheefec, cohebanc, coheobse)"
                " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                (empr, CODM_RECI, cohenume, fvhefech, cliecodi,
                 cobrado_f, efec_f, banc_f, fvheobse),
            )

            # linacode reng 1: siempre
            codereng = 1
            cur.execute(
                "INSERT INTO linacode"
                "  (emprcodi, codmcodi, cohenume, codereng, codedesc, codeunit)"
                " VALUES (%s, %s, %s, %s, %s, %s)",
                (empr, CODM_RECI, cohenume, codereng,
                 f"Recibido con {CODM_REMI} N° {fvhenume:08d} $ {cobrado_f:,.0f}"[:40], cobrado_f),
            )

            # linacode reng 2: efectivo (si > 0)
            if efec > 0:
                codereng += 1
                cur.execute(
                    "INSERT INTO linacode"
                    "  (emprcodi, codmcodi, cohenume, codereng, codedesc, codeunit)"
                    " VALUES (%s, %s, %s, %s, %s, 0)",
                    (empr, CODM_RECI, cohenume, codereng,
                     f"{efec_f:,.0f} en Efectivo"[:40]),
                )

            # linacode reng 3: transferencia (si > 0)
            if banc > 0:
                codereng += 1
                cur.execute(
                    "INSERT INTO linacode"
                    "  (emprcodi, codmcodi, cohenume, codereng, codedesc, codeunit)"
                    " VALUES (%s, %s, %s, %s, %s, 0)",
                    (empr, CODM_RECI, cohenume, codereng,
                     f"{banc_f:,.0f} en Transf. o Depósito"[:40]),
                )

            # linactcl HABER = efec + banc (si > 0); deja ctacte como saldo deudor
            if cobrado > 0:
                cur.execute(
                    "INSERT INTO linactcl"
                    "  (emprcodi, cliecodi, ctclfech, codmcodi, ctclnumc, ctcldebe, ctclhabe)"
                    " VALUES (%s, %s, %s, %s, %s, 0, %s)",
                    (empr, cliecodi, fvhefech, CODM_RECI, cohenume, float(cobrado)),
                )

            # linacaja (si efectivo > 0)
            if efec > 0:
                conc = f"RECI Nº {cohenume:08d}"[:30]
                cur.execute(
                    "INSERT INTO linacaja"
                    "  (emprcodi, cliecodi, provcodi, cajafech, cajanumc, cajaconc, cajadebe, cajahabe)"
                    " VALUES (%s, %s, 0, %s, %s, %s, 0, %s)",
                    (empr, cliecodi, fvhefech, cohenume, conc, efec_f),
                )

            # linabanc (si banco > 0)
            if banc > 0:
                conc = f"RECI Nº {cohenume:08d}"[:30]
                cur.execute(
                    "INSERT INTO linabanc"
                    "  (emprcodi, cliecodi, provcodi, bancfech, bancnumc, bancconc, bancdebe, banchabe)"
                    " VALUES (%s, %s, 0, %s, %s, %s, 0, %s)",
                    (empr, cliecodi, fvhefech, cohenume, conc, banc_f),
                )

            cur.execute(
                "UPDATE linafvhe SET fvhereci=%s"
                " WHERE emprcodi=%s AND codmcodi=%s AND fvhenume=%s",
                (cohenume, empr, CODM_REMI, fvhenume),
            )

        cur.close()

        if owns_conn:
            conn.commit()
        elif user and tab_id:
            sess_conns.commit_and_restart_task_conn(task_id=tab_id, user=user, prog=PROG_CODE)
        else:
            conn.commit()

        msg = f"{CODM_REMI} N° {fvhenume:08d} grabado."
        if cohenume:
            msg += f"  Recibo N° {cohenume:08d}."
        return JSONResponse({"ok": True, "fvhenume": fvhenume, "cohenume": cohenume, "message": msg})

    except Exception as e:
        try:
            conn.rollback()
        except Exception:
            pass
        traceback.print_exc()
        return JSONResponse({"ok": False, "error": str(e)}, status_code=500)
    finally:
        if owns_conn:
            sess_conns.release_conn(conn)
