(function () {

  // ── Config ────────────────────────────────────────────────────────────────
  var _cfg = JSON.parse(document.getElementById('lina22-config').textContent || '{}');
  var HOY  = _cfg.hoy || '';

  // ── Elementos DOM ─────────────────────────────────────────────────────────
  var elDesde     = document.getElementById('lina22-desde');
  var elHasta     = document.getElementById('lina22-hasta');
  var elCliecodi  = document.getElementById('lina22-cliecodi');
  var elCliename  = document.getElementById('lina22-cliename');
  var elBtnCons   = document.getElementById('lina22-btn-consultar');
  var elTbody     = document.getElementById('lina22-tbody');
  var elStatus    = document.getElementById('lina22-status');
  var elCtx         = document.getElementById('lina22-ctx');
  var elCtxPdf      = document.getElementById('lina22-ctx-pdf');
  var elCtxTxt      = document.getElementById('lina22-ctx-txt');
  var elCtxAnular   = document.getElementById('lina22-ctx-anular');
  var elGridScroll  = document.getElementById('lina22-grid-scroll');

  // Defaults
  elHasta.value = HOY;

  // ── Estado ────────────────────────────────────────────────────────────────
  var ctxRow = null;   // {codm, nro, anulado} del row bajo el menú contextual

  // ── Helpers ───────────────────────────────────────────────────────────────
  function esc(s) {
    return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function cerrarCtx() { elCtx.style.display = 'none'; ctxRow = null; }

  // ── Render grilla ─────────────────────────────────────────────────────────
  function renderGrid(rows) {
    while (elTbody.firstChild) elTbody.removeChild(elTbody.firstChild);

    if (!rows.length) {
      var tr = document.createElement('tr');
      tr.innerHTML = '<td colspan="6" style="padding:8px;color:#aaa;text-align:center;font-style:italic;">Sin registros.</td>';
      elTbody.appendChild(tr);
      return;
    }

    rows.forEach(function (r) {
      var tr = document.createElement('tr');
      if (r.anulado) tr.className = 'row-anulado';
      tr.style.cursor = 'default';

      tr.innerHTML =
        '<td style="padding:1px 6px;">' + esc(r.codm) + '</td>' +
        '<td style="padding:1px 6px;text-align:right;font-family:monospace;">' + esc(r.nro.toString().padStart(6, '0')) + '</td>' +
        '<td style="padding:1px 6px;text-align:center;">' + esc(r.fecha) + '</td>' +
        '<td style="padding:1px 6px;text-align:right;font-family:monospace;">' + esc(r.cta) + '</td>' +
        '<td style="padding:1px 6px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + esc(r.cliente) + '</td>' +
        '<td style="padding:1px 6px;text-align:right;font-family:monospace;">' + esc(r.importe) + '</td>';

      (function (row) {
        tr.addEventListener('contextmenu', function (e) {
          e.preventDefault();
          ctxRow = row;
          // Mostrar/ocultar Anular según estado
          elCtxAnular.style.display = row.anulado ? 'none' : '';
          elCtx.style.display = 'block';
          elCtx.style.left = e.clientX + 'px';
          elCtx.style.top  = e.clientY + 'px';
        });
      })(r);

      elTbody.appendChild(tr);
    });

    // Mostrar el último registro
    elGridScroll.scrollTop = elGridScroll.scrollHeight;
  }

  // ── Consultar ─────────────────────────────────────────────────────────────
  function consultar() {
    var desde    = elDesde.value.trim();
    var hasta    = elHasta.value.trim() || HOY;
    var cliecodi = parseInt(elCliecodi.value) || 0;

    var params = new URLSearchParams();
    if (desde)      params.set('desde',    desde);
    if (hasta)      params.set('hasta',    hasta);
    if (cliecodi)   params.set('cliecodi', cliecodi);

    elStatus.textContent = 'Consultando…';
    elBtnCons.disabled   = true;

    fetch('/lina22/list?' + params.toString())
      .then(function (r) { return r.json(); })
      .then(function (d) {
        elBtnCons.disabled = false;
        if (d.ok) {
          elStatus.textContent = d.rows.length + ' registro' + (d.rows.length !== 1 ? 's' : '') + '.';
          renderGrid(d.rows);
        } else {
          elStatus.textContent = 'Error: ' + (d.error || 'desconocido');
        }
      })
      .catch(function (err) {
        elBtnCons.disabled = false;
        elStatus.textContent = 'Error de red.';
      });
  }

  // ── Anular ────────────────────────────────────────────────────────────────
  function anularComprobante(row) {
    var nroFmt = row.nro.toString().padStart(6, '0');
    if (!confirm('¿ANULA el comprobante ' + row.codm + ' N° ' + nroFmt + '?\n\nEsta acción no se puede deshacer.')) {
      return;
    }
    fetch('/lina22/anular', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({ codm: row.codm, nro: row.nro }),
    })
      .then(function (r) { return r.json(); })
      .then(function (d) {
        if (d.ok) {
          consultar();   // refrescar grilla
        } else {
          alert('Error al anular: ' + (d.error || 'desconocido'));
        }
      })
      .catch(function (err) {
        alert('Error de red: ' + err);
      });
  }

  // ── Menú contextual ───────────────────────────────────────────────────────
  elCtxPdf.addEventListener('click', function () {
    if (!ctxRow) { cerrarCtx(); return; }
    window.open('/cpbte/pdf?clpr=C&codm=' + encodeURIComponent(ctxRow.codm) + '&nume=' + ctxRow.nro, '_blank');
    cerrarCtx();
  });

  elCtxTxt.addEventListener('click', function () {
    if (!ctxRow) { cerrarCtx(); return; }
    window.open('/cpbte/txt?clpr=C&codm=' + encodeURIComponent(ctxRow.codm) + '&nume=' + ctxRow.nro, '_blank');
    cerrarCtx();
  });

  elCtxAnular.addEventListener('click', function () {
    if (!ctxRow) { cerrarCtx(); return; }
    var row = ctxRow;
    cerrarCtx();
    anularComprobante(row);
  });

  document.addEventListener('click', function (e) {
    if (!elCtx.contains(e.target)) cerrarCtx();
  });

  // ── Event listeners ───────────────────────────────────────────────────────
  elBtnCons.addEventListener('click', consultar);

  // Enter en cualquier campo del filtro dispara la consulta
  [elDesde, elHasta, elCliecodi].forEach(function (el) {
    el.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') { e.preventDefault(); consultar(); }
    });
  });

  // Auto-completar nombre cliente al salir del campo código
  elCliecodi.addEventListener('change', function () {
    var cod = parseInt(elCliecodi.value) || 0;
    if (cod <= 0) { elCliename.textContent = ''; return; }
    fetch('/lina22/clie/info?cliecodi=' + cod)
      .then(function (r) { return r.json(); })
      .then(function (d) {
        elCliename.textContent = d.cliename || '';
      })
      .catch(function () { elCliename.textContent = ''; });
  });

  // No consulta automática: el usuario debe presionar Consultar.

})();
