(function () {

  // ── Config ────────────────────────────────────────────────────────────────
  var _cfg      = JSON.parse(document.getElementById('lina34-config').textContent || '{}');
  var MAX_LINEAS = _cfg.maxLineas || 40;

  // ── Estado ────────────────────────────────────────────────────────────────
  var lineas       = [];    // [{reng, desc, unit}]
  var editingIdx   = null;
  var provcodi     = '';
  var provname     = '';
  var pahenume     = 0;
  var ctxTargetIdx = null;

  // ── Elementos DOM ─────────────────────────────────────────────────────────
  var elCodi     = document.getElementById('lina34-provcodi');
  var elNombre   = document.getElementById('lina34-provname');
  var elFase1    = document.getElementById('lina34-fase1');
  var elFase2    = document.getElementById('lina34-fase2');
  var elBtnsF2   = document.getElementById('lina34-btns-fase2');
  var elBtnsF3   = document.getElementById('lina34-btns-fase3');
  var elIngreso  = document.getElementById('lina34-ingreso');
  var elCierre   = document.getElementById('lina34-cierre');
  var elTbody    = document.getElementById('lina34-tbody');
  var elResumen  = document.getElementById('lina34-prov-resumen');
  var elPagoNum  = document.getElementById('lina34-pago-num');
  var elTotal    = document.getElementById('lina34-total');
  var elBtnG     = document.getElementById('lina34-btn-guardar');
  var elBtnC     = document.getElementById('lina34-btn-cancelar');
  var elBtnConf  = document.getElementById('lina34-btn-confirmar');
  var elBtnCorr  = document.getElementById('lina34-btn-corregir');
  var elCtx      = document.getElementById('lina34-ctx');
  var inpReng    = document.getElementById('inp34-reng');
  var inpDesc    = document.getElementById('inp34-desc');
  var inpUnit    = document.getElementById('inp34-unit');
  var cierreObse  = document.getElementById('cierre34-obse');
  var cierreEfec  = document.getElementById('cierre34-efec');
  var cierreTransf= document.getElementById('cierre34-transf');
  var cierre34Dif = document.getElementById('cierre34-dif');

  // ── Helpers ───────────────────────────────────────────────────────────────
  function esc(s) {
    return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function fmtN(v) {
    var n = parseFloat(v) || 0;
    return n.toFixed(2).replace('.', ',').replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  }

  function cerrarCtx() { elCtx.style.display = 'none'; ctxTargetIdx = null; }

  function totalPago() {
    return lineas.reduce(function (s, l) { return s + (parseFloat(l.unit) || 0); }, 0);
  }

  function renumerarLineas() {
    lineas.forEach(function (l, i) { l.reng = i + 1; });
  }

  // ── FASE 1: validar proveedor ─────────────────────────────────────────────
  function validarProv() {
    var cod = (elCodi.value || '').trim();
    if (!cod) { elNombre.textContent = ''; provcodi = ''; provname = ''; return; }
    fetch('/lina34/prov/info?provcodi=' + encodeURIComponent(cod))
      .then(function (r) { return r.json(); })
      .then(function (d) {
        if (d.ok) {
          provcodi = cod;
          provname = d.provname;
          pahenume = d.pahenume;
          irFase2();
        } else {
          provcodi = ''; provname = '';
          elNombre.textContent   = 'No encontrado';
          elNombre.style.color   = '#c00';
          elNombre.style.fontWeight = 'normal';
        }
      })
      .catch(function () {
        elNombre.textContent = 'Error de red';
        elNombre.style.color = '#c00';
      });
  }

  // ── Transición a FASE 2 ───────────────────────────────────────────────────
  function irFase2() {
    elFase1.style.display = 'none';
    elFase2.style.setProperty('display', 'flex', 'important');
    elBtnsF2.style.display = '';
    elResumen.textContent = String(provcodi).padStart(4, '0') + ' — ' + provname;
    elPagoNum.textContent = 'RECI N° ' + String(pahenume).padStart(6, '0');
    renderGrid();
    inpDesc.focus();
  }

  // ── Grilla ────────────────────────────────────────────────────────────────
  function renderGrid() {
    while (elTbody.firstChild) elTbody.removeChild(elTbody.firstChild);

    lineas.forEach(function (l, idx) {
      var tr = document.createElement('tr');
      tr.style.background = idx % 2 === 0 ? '#fff' : '#f7f7f7';
      tr.style.cursor = 'default';
      if (editingIdx === idx) {
        tr.style.background = '#fff8dc';
        tr.style.opacity = '0.6';
      }
      tr.innerHTML =
        '<td style="padding:1px 4px;text-align:center;color:#888;">' + l.reng + '</td>' +
        '<td style="padding:1px 6px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + esc(l.desc) + '</td>' +
        '<td style="padding:1px 6px;text-align:right;font-family:monospace;font-weight:bold;">' + fmtN(l.unit) + '</td>';
      (function (i) {
        tr.addEventListener('contextmenu', function (e) {
          e.preventDefault();
          ctxTargetIdx = i;
          elCtx.style.display = 'block';
          elCtx.style.left = e.clientX + 'px';
          elCtx.style.top  = e.clientY + 'px';
        });
      })(idx);
      elTbody.appendChild(tr);
    });

    // Filas vacías hasta MAX_LINEAS
    var vacias = Math.max(0, MAX_LINEAS - lineas.length);
    for (var v = 0; v < vacias; v++) {
      var rn  = lineas.length + v + 1;
      var bg  = (lineas.length + v) % 2 === 0 ? '#fff' : '#f7f7f7';
      var trv = document.createElement('tr');
      trv.style.background = bg;
      trv.innerHTML =
        '<td style="padding:1px 4px;text-align:center;color:#ccc;font-size:7.5pt;">' + rn + '</td>' +
        '<td></td><td></td>';
      elTbody.appendChild(trv);
    }

    inpReng.textContent = editingIdx !== null ? lineas[editingIdx].reng : lineas.length + 1;

    var tot = totalPago();
    elTotal.textContent = '$ ' + fmtN(tot);

    var hayDatos = lineas.length > 0 && tot > 0;
    elBtnG.disabled    = !hayDatos;
    elBtnG.style.opacity = hayDatos ? '1' : '0.5';
  }

  // ── Confirmar renglón ─────────────────────────────────────────────────────
  function confirmarRenglon() {
    var desc = (inpDesc.value || '').trim();
    var unit = parseFloat(inpUnit.value) || 0;
    if (!desc && unit === 0) { inpDesc.focus(); return; }
    if (unit < 0) { alert('El importe no puede ser negativo.'); inpUnit.focus(); return; }
    if (lineas.length >= MAX_LINEAS && editingIdx === null) {
      alert('Se alcanzó el máximo de ' + MAX_LINEAS + ' renglones.'); return;
    }
    var linea = {
      reng: editingIdx !== null ? lineas[editingIdx].reng : lineas.length + 1,
      desc: desc,
      unit: unit,
    };
    if (editingIdx !== null) {
      lineas[editingIdx] = linea;
      editingIdx = null;
    } else {
      lineas.push(linea);
    }
    inpDesc.value = '';
    inpUnit.value = '';
    renderGrid();
    setTimeout(function () { inpDesc.focus(); }, 0);
  }

  // ── Menú contextual ───────────────────────────────────────────────────────
  document.getElementById('lina34-ctx-eliminar').addEventListener('click', function () {
    if (ctxTargetIdx === null) { cerrarCtx(); return; }
    lineas.splice(ctxTargetIdx, 1);
    renumerarLineas();
    if (editingIdx !== null) editingIdx = null;
    cerrarCtx();
    renderGrid();
  });

  document.getElementById('lina34-ctx-subir').addEventListener('click', function () {
    if (ctxTargetIdx === null || ctxTargetIdx === 0) { cerrarCtx(); return; }
    var tmp = lineas[ctxTargetIdx - 1];
    lineas[ctxTargetIdx - 1] = lineas[ctxTargetIdx];
    lineas[ctxTargetIdx]     = tmp;
    renumerarLineas();
    cerrarCtx();
    renderGrid();
  });

  document.getElementById('lina34-ctx-bajar').addEventListener('click', function () {
    if (ctxTargetIdx === null || ctxTargetIdx >= lineas.length - 1) { cerrarCtx(); return; }
    var tmp = lineas[ctxTargetIdx + 1];
    lineas[ctxTargetIdx + 1] = lineas[ctxTargetIdx];
    lineas[ctxTargetIdx]     = tmp;
    renumerarLineas();
    cerrarCtx();
    renderGrid();
  });

  document.getElementById('lina34-ctx-modificar').addEventListener('click', function () {
    if (ctxTargetIdx === null) { cerrarCtx(); return; }
    var l = lineas[ctxTargetIdx];
    editingIdx    = ctxTargetIdx;
    inpDesc.value = l.desc;
    inpUnit.value = l.unit;
    cerrarCtx();
    renderGrid();
    inpUnit.focus(); inpUnit.select();
  });

  document.addEventListener('click', function (e) {
    if (!elCtx.contains(e.target)) cerrarCtx();
  });

  // ── Panel de cierre ───────────────────────────────────────────────────────
  function actualizarDif() {
    var tot    = totalPago();
    var efec   = parseFloat(cierreEfec.value)   || 0;
    var transf = parseFloat(cierreTransf.value) || 0;
    var dif    = tot - efec - transf;
    cierre34Dif.textContent = fmtN(dif);
    var ok = Math.abs(dif) < 0.01;
    cierre34Dif.style.color = ok ? '#2e7d32' : '#c00';
    elBtnConf.disabled = !ok;
    elBtnConf.style.opacity = ok ? '1' : '0.5';
  }

  function irCierre() {
    elIngreso.style.display = 'none';
    elCierre.style.display  = '';
    elBtnsF2.style.display  = 'none';
    elBtnsF3.style.display  = '';
    cierreObse.value   = '';
    cierreEfec.value   = totalPago().toFixed(2);
    cierreTransf.value = '0';
    actualizarDif();
    setTimeout(function () { cierreObse.focus(); }, 0);
  }

  function irCorregir() {
    elCierre.style.display  = 'none';
    elIngreso.style.display = '';
    elBtnsF3.style.display  = 'none';
    elBtnsF2.style.display  = '';
    setTimeout(function () { inpDesc.focus(); }, 0);
  }

  // ── Guardar ───────────────────────────────────────────────────────────────
  function guardarPago() {
    if (elBtnConf.disabled) return;
    elBtnConf.disabled = true;
    var payload = {
      provcodi: provcodi,
      efec:     parseFloat(cierreEfec.value)   || 0,
      banc:     parseFloat(cierreTransf.value) || 0,
      paheobse: cierreObse.value.trim().slice(0, 40),
      lineas:   lineas.map(function (l) { return { desc: l.desc, unit: l.unit }; }),
    };
    fetch('/lina34/save', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify(payload),
    })
      .then(function (r) { return r.json(); })
      .then(function (d) {
        if (d.ok) {
          alert(d.message);
          reiniciar();
        } else {
          alert('Error: ' + (d.error || 'desconocido'));
          elBtnConf.disabled = false;
        }
      })
      .catch(function (err) {
        alert('Error de red: ' + err);
        elBtnConf.disabled = false;
      });
  }

  // ── Reiniciar ─────────────────────────────────────────────────────────────
  function reiniciar() {
    lineas = []; editingIdx = null; provcodi = ''; provname = ''; pahenume = 0;
    elCierre.style.display  = 'none';
    elIngreso.style.display = '';
    elBtnsF3.style.display  = 'none';
    elBtnsF2.style.display  = 'none';
    elFase2.style.setProperty('display', 'none', 'important');
    elFase1.style.display = '';
    elCodi.value = '';
    elNombre.textContent = '';
    setTimeout(function () { elCodi.focus(); }, 0);
  }

  // ── Event listeners ───────────────────────────────────────────────────────

  elCodi.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') { e.preventDefault(); validarProv(); }
  });
  elCodi.addEventListener('change', function () { validarProv(); });

  inpDesc.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' || (e.key === 'Tab' && !e.shiftKey)) {
      e.preventDefault();
      inpUnit.focus();
      inpUnit.select();
    }
  });

  inpUnit.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' || (e.key === 'Tab' && !e.shiftKey)) {
      e.preventDefault();
      confirmarRenglon();
    }
  });

  inpUnit.addEventListener('blur', function () {
    var desc = (inpDesc.value || '').trim();
    var unit = parseFloat(inpUnit.value) || 0;
    if (desc || unit > 0) { confirmarRenglon(); }
  });

  elBtnG.addEventListener('click', function () { if (!elBtnG.disabled) irCierre(); });

  cierreObse.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') { e.preventDefault(); cierreEfec.focus(); cierreEfec.select(); }
  });
  cierreEfec.addEventListener('input',   actualizarDif);
  cierreEfec.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') { e.preventDefault(); cierreTransf.focus(); cierreTransf.select(); }
  });
  cierreTransf.addEventListener('input',   actualizarDif);
  cierreTransf.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') { e.preventDefault(); if (!elBtnConf.disabled) guardarPago(); }
  });

  elBtnConf.addEventListener('click', guardarPago);
  elBtnCorr.addEventListener('click', irCorregir);

  elBtnC.addEventListener('click', reiniciar);
  document.addEventListener('keydown', function (e) {
    if (e.ctrlKey && e.key === 's') {
      e.preventDefault();
      if (elBtnConf && elBtnConf.offsetParent !== null) { elBtnConf.click(); }
      else if (elBtnG && !elBtnG.disabled && elBtnG.offsetParent !== null) { elBtnG.click(); }
      return;
    }
    if (e.key === 'Escape') reiniciar();
  });

  elCodi.focus();

})();
