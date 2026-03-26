(function () {

  // ── Config ────────────────────────────────────────────────────────────────
  var _cfg = JSON.parse(document.getElementById('lina35-config').textContent || '{}');
  var HOY  = _cfg.hoy || '';

  // ── Elementos DOM ─────────────────────────────────────────────────────────
  var elDesde     = document.getElementById('lina35-desde');
  var elHasta     = document.getElementById('lina35-hasta');
  var elProvcodi  = document.getElementById('lina35-provcodi');
  var elProvname  = document.getElementById('lina35-provname');
  var elBtnCons   = document.getElementById('lina35-btn-consultar');
  var elTbody     = document.getElementById('lina35-tbody');
  var elStatus    = document.getElementById('lina35-status');
  var elCtx       = document.getElementById('lina35-ctx');
  var elCtxPdf    = document.getElementById('lina35-ctx-pdf');
  var elCtxTxt    = document.getElementById('lina35-ctx-txt');
  var elCtxAnular = document.getElementById('lina35-ctx-anular');
  var elGridScroll = document.getElementById('lina35-grid-scroll');

  // Defaults
  elHasta.value = HOY;

  // ── Estado ────────────────────────────────────────────────────────────────
  var ctxRow = null;

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
      tr.innerHTML = '<td colspan="8" style="padding:8px;color:#aaa;text-align:center;font-style:italic;">Sin registros.</td>';
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
        '<td style="padding:1px 6px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + esc(r.proveedor) + '</td>' +
        '<td style="padding:1px 6px;text-align:right;font-family:monospace;">' + esc(r.efec) + '</td>' +
        '<td style="padding:1px 6px;text-align:right;font-family:monospace;">' + esc(r.banc) + '</td>' +
        '<td style="padding:1px 6px;text-align:right;font-family:monospace;">' + esc(r.importe) + '</td>';

      (function (row) {
        tr.addEventListener('contextmenu', function (e) {
          e.preventDefault();
          ctxRow = row;
          elCtxAnular.style.display = row.anulado ? 'none' : '';
          elCtx.style.display = 'block';
          elCtx.style.left = e.clientX + 'px';
          elCtx.style.top  = e.clientY + 'px';
        });
      })(r);

      elTbody.appendChild(tr);
    });

    elGridScroll.scrollTop = elGridScroll.scrollHeight;
  }

  // ── Consultar ─────────────────────────────────────────────────────────────
  function consultar() {
    var desde    = elDesde.value.trim();
    var hasta    = elHasta.value.trim() || HOY;
    var provcodi = parseInt(elProvcodi.value) || 0;

    var params = new URLSearchParams();
    if (desde)    params.set('desde',    desde);
    if (hasta)    params.set('hasta',    hasta);
    if (provcodi) params.set('provcodi', provcodi);

    elStatus.textContent = 'Consultando…';
    elBtnCons.disabled   = true;

    fetch('/lina35/list?' + params.toString())
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
      .catch(function () {
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
    fetch('/lina35/anular', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({ codm: row.codm, nro: row.nro }),
    })
      .then(function (r) { return r.json(); })
      .then(function (d) {
        if (d.ok) {
          consultar();
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
    window.open('/cpbte/pdf?clpr=P&codm=' + encodeURIComponent(ctxRow.codm) + '&nume=' + ctxRow.nro, '_blank');
    cerrarCtx();
  });

  elCtxTxt.addEventListener('click', function () {
    if (!ctxRow) { cerrarCtx(); return; }
    window.open('/cpbte/txt?clpr=P&codm=' + encodeURIComponent(ctxRow.codm) + '&nume=' + ctxRow.nro, '_blank');
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

  [elDesde, elHasta, elProvcodi].forEach(function (el) {
    el.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') { e.preventDefault(); consultar(); }
    });
  });

  elProvcodi.addEventListener('change', function () {
    var cod = parseInt(elProvcodi.value) || 0;
    if (cod <= 0) { elProvname.textContent = ''; return; }
    fetch('/lina35/prov/info?provcodi=' + cod)
      .then(function (r) { return r.json(); })
      .then(function (d) { elProvname.textContent = d.provname || ''; })
      .catch(function () { elProvname.textContent = ''; });
  });

})();
