from fastapi import APIRouter, Request, Query
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from fastapi import Body
from datetime import date
from typing import Dict, Any

from CapaBRL.linabase import linabase
from CapaDAL.dataconn import sess_conns, ctx_empr

# ==================== CONSTANTES Y ROUTER ====================

router     = APIRouter()
PROG_CODE  = "LINA531"
ROUTE_BASE = "/lina531"


# ==================== CLASE PRINCIPAL ====================

class Lina531(linabase):
    """Limpieza de Archivos (LINA531)."""

    @classmethod
    def get_permisos_por_usuario(cls, user: str) -> Dict[str, Any]:
        if cls.permisos_por_usuario_func:
            return cls.permisos_por_usuario_func(user)
        return {}


# ==================== RUTAS ====================

@router.get("/", response_class=HTMLResponse)
async def lina531_index(
    request: Request,
    _tab: str = Query(default=""),
):
    Lina531.set_prog_code(PROG_CODE)
    user = Lina531.get_current_user(request)
    if not user:
        return RedirectResponse("/login")

    perms_dict = Lina531.get_permisos_por_usuario(user)
    perms = perms_dict.get(PROG_CODE)

    return Lina531.templates.TemplateResponse(
        "lina531/main.html",
        {
            "request": request,
            "perms":   perms,
            "tab_id":  _tab,
            "hoy_iso": date.today().isoformat(),
        },
    )


@router.post("/ejecutar")
async def lina531_ejecutar(
    request: Request,
    payload: dict = Body(...),
) -> JSONResponse:
    Lina531.set_prog_code(PROG_CODE)
    user = Lina531.get_current_user(request)
    if not user:
        return JSONResponse({"ok": False, "error": "No autenticado"}, status_code=401)

    perms_dict = Lina531.get_permisos_por_usuario(user)
    perms = perms_dict.get(PROG_CODE)
    if not perms or not perms.modi:
        return JSONResponse({"ok": False, "error": "Sin permiso de modificación (SAFEMODI)."}, status_code=403)

    raw_fecha = str(payload.get("fecha_hasta") or "").strip()
    if not raw_fecha:
        return JSONResponse({"ok": False, "error": "Debe indicar la fecha límite."}, status_code=400)

    try:
        fecha_hasta = date.fromisoformat(raw_fecha)
    except ValueError:
        return JSONResponse({"ok": False, "error": "Fecha inválida."}, status_code=400)

    if fecha_hasta >= date.today():
        return JSONResponse({"ok": False, "error": "La fecha debe ser anterior a hoy."}, status_code=400)

    empr = ctx_empr.get()
    fecha_str = fecha_hasta.isoformat()

    conn = sess_conns.get_conn(readonly=False)
    steps = []
    try:
        cur = conn.cursor()

        # ── 1. Facturas de Compra ──────────────────────────────────────────
        # Restaurar stock: artiexan += sum(fcdecant) por artículo
        cur.execute(
            "UPDATE linaarti a"
            " INNER JOIN ("
            "   SELECT d.emprcodi, d.articodi, SUM(d.fcdecant) AS total_cant"
            "   FROM linafcde d"
            "   WHERE d.emprcodi = %s AND d.fchefech < %s"
            "     AND d.articodi IS NOT NULL AND d.articodi != '' AND d.fcdecant != 0"
            "   GROUP BY d.emprcodi, d.articodi"
            " ) sub ON sub.emprcodi = a.emprcodi AND sub.articodi = a.articodi"
            " SET a.artiexan = a.artiexan + sub.total_cant",
            (empr, fecha_str),
        )
        arti_fc = cur.rowcount

        cur.execute(
            "DELETE FROM linafcde WHERE emprcodi = %s AND fchefech < %s",
            (empr, fecha_str),
        )
        del_fcde = cur.rowcount

        cur.execute(
            "DELETE FROM linafche WHERE emprcodi = %s AND fchefech < %s",
            (empr, fecha_str),
        )
        del_fche = cur.rowcount

        steps.append({
            "nombre":  "Facturas de Compra",
            "detalle": f"{del_fche} encabezados, {del_fcde} ítems eliminados — {arti_fc} artículos actualizados",
        })

        # ── 2. Facturas de Venta ───────────────────────────────────────────
        # Restaurar stock: artiexan -= sum(fvdecant), artiexfe = fecha_str
        cur.execute(
            "UPDATE linaarti a"
            " INNER JOIN ("
            "   SELECT d.emprcodi, d.articodi, SUM(d.fvdecant) AS total_cant"
            "   FROM linafvde d"
            "   WHERE d.emprcodi = %s AND d.fvhefech < %s"
            "     AND d.articodi IS NOT NULL AND d.articodi != '' AND d.fvdecant != 0"
            "   GROUP BY d.emprcodi, d.articodi"
            " ) sub ON sub.emprcodi = a.emprcodi AND sub.articodi = a.articodi"
            " SET a.artiexan = a.artiexan - sub.total_cant,"
            "     a.artiexfe = %s",
            (empr, fecha_str, fecha_str),
        )
        arti_fv = cur.rowcount

        cur.execute(
            "DELETE FROM linafvde WHERE emprcodi = %s AND fvhefech < %s",
            (empr, fecha_str),
        )
        del_fvde = cur.rowcount

        cur.execute(
            "DELETE FROM linafvhe WHERE emprcodi = %s AND fvhefech < %s",
            (empr, fecha_str),
        )
        del_fvhe = cur.rowcount

        steps.append({
            "nombre":  "Facturas de Venta",
            "detalle": f"{del_fvhe} encabezados, {del_fvde} ítems eliminados — {arti_fv} artículos actualizados",
        })

        # ── 3. Cuentas Corrientes Clientes ────────────────────────────────
        # Acumular saldo anterior en linaclie y borrar movimientos
        cur.execute(
            "UPDATE linaclie c"
            " INNER JOIN ("
            "   SELECT emprcodi, cliecodi,"
            "          SUM(ctcldebe - ctclhabe) AS saldo_delta"
            "   FROM linactcl"
            "   WHERE emprcodi = %s AND ctclfech < %s"
            "   GROUP BY emprcodi, cliecodi"
            " ) sub ON sub.emprcodi = c.emprcodi AND sub.cliecodi = c.cliecodi"
            " SET c.cliesala = c.cliesala + sub.saldo_delta,"
            "     c.cliefesa = %s",
            (empr, fecha_str, fecha_str),
        )
        upd_clie = cur.rowcount

        cur.execute(
            "DELETE FROM linactcl WHERE emprcodi = %s AND ctclfech < %s",
            (empr, fecha_str),
        )
        del_ctcl = cur.rowcount

        steps.append({
            "nombre":  "Ctas. Ctes. Clientes",
            "detalle": f"{del_ctcl} movimientos eliminados — {upd_clie} clientes actualizados",
        })

        # ── 4. Cuentas Corrientes Proveedores ─────────────────────────────
        cur.execute(
            "UPDATE linaprov p"
            " INNER JOIN ("
            "   SELECT emprcodi, provcodi,"
            "          SUM(ctprdebe - ctprhabe) AS saldo_delta"
            "   FROM linactpr"
            "   WHERE emprcodi = %s AND ctprfech < %s"
            "   GROUP BY emprcodi, provcodi"
            " ) sub ON sub.emprcodi = p.emprcodi AND sub.provcodi = p.provcodi"
            " SET p.provsala = p.provsala + sub.saldo_delta,"
            "     p.provfesa = %s",
            (empr, fecha_str, fecha_str),
        )
        upd_prov = cur.rowcount

        cur.execute(
            "DELETE FROM linactpr WHERE emprcodi = %s AND ctprfech < %s",
            (empr, fecha_str),
        )
        del_ctpr = cur.rowcount

        steps.append({
            "nombre":  "Ctas. Ctes. Proveedores",
            "detalle": f"{del_ctpr} movimientos eliminados — {upd_prov} proveedores actualizados",
        })

        # ── 5. Movimientos de Caja ────────────────────────────────────────
        cur.execute(
            "SELECT COALESCE(SUM(cajadebe - cajahabe), 0) AS saldo"
            " FROM linacaja WHERE emprcodi = %s AND cajafech < %s",
            (empr, fecha_str),
        )
        saldo_caja = float((cur.fetchone() or (0,))[0])

        cur.execute(
            "DELETE FROM linacaja WHERE emprcodi = %s AND cajafech < %s",
            (empr, fecha_str),
        )
        del_caja = cur.rowcount

        ins_caja = 0
        if saldo_caja != 0:
            debe_caja  = saldo_caja  if saldo_caja > 0 else 0
            habe_caja  = -saldo_caja if saldo_caja < 0 else 0
            cur.execute(
                "INSERT INTO linacaja"
                " (emprcodi, cajafech, cajanumc, cajaconc, cajadebe, cajahabe, cliecodi, provcodi)"
                " VALUES (%s, %s, 0, 'SALDO ANTERIOR', %s, %s, 0, 0)",
                (empr, fecha_str, debe_caja, habe_caja),
            )
            ins_caja = 1

        steps.append({
            "nombre":  "Movimientos de Caja",
            "detalle": f"{del_caja} movimientos eliminados"
                       + (f" — saldo anterior insertado ({saldo_caja:+.2f})" if ins_caja else ""),
        })

        # ── 6. Movimientos de Bancos ──────────────────────────────────────
        cur.execute(
            "SELECT COALESCE(SUM(bancdebe - banchabe), 0) AS saldo"
            " FROM linabanc WHERE emprcodi = %s AND bancfech < %s",
            (empr, fecha_str),
        )
        saldo_banc = float((cur.fetchone() or (0,))[0])

        cur.execute(
            "DELETE FROM linabanc WHERE emprcodi = %s AND bancfech < %s",
            (empr, fecha_str),
        )
        del_banc = cur.rowcount

        ins_banc = 0
        if saldo_banc != 0:
            debe_banc  = saldo_banc  if saldo_banc > 0 else 0
            habe_banc  = -saldo_banc if saldo_banc < 0 else 0
            cur.execute(
                "INSERT INTO linabanc"
                " (emprcodi, bancfech, bancnumc, bancconc, bancdebe, banchabe, cliecodi, provcodi)"
                " VALUES (%s, %s, 0, 'SALDO ANTERIOR', %s, %s, 0, 0)",
                (empr, fecha_str, debe_banc, habe_banc),
            )
            ins_banc = 1

        steps.append({
            "nombre":  "Movimientos de Bancos",
            "detalle": f"{del_banc} movimientos eliminados"
                       + (f" — saldo anterior insertado ({saldo_banc:+.2f})" if ins_banc else ""),
        })

        cur.close()
        conn.commit()

    except Exception as exc:
        try:
            conn.rollback()
        except Exception:
            pass
        return JSONResponse({"ok": False, "error": str(exc)}, status_code=500)
    finally:
        sess_conns.release_conn(conn)

    return JSONResponse({"ok": True, "steps": steps})
