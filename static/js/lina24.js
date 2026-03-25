(function () {

  // ── Config ────────────────────────────────────────────────────────────────
  var _cfg      = JSON.parse(document.getElementById('lina24-config').textContent || '{}');
  var MAX_LINEAS = _cfg.maxLineas || 40;

  // ── Estado ────────────────────────────────────────────────────────────────
  var lineas       = [];    // [{reng, desc, unit}]
  var editingIdx   = null;
  var cliecodi     = '';
  var cliename     = '';
  var cohenume     = 0;
  var ctxTargetIdx = null;

  // ── Elementos DOM ─────────────────────────────────────────────────────────
  var elCodi     = document.getElementById('lina24-cliecodi');
  var elNombre   = document.getElementById('lina24-cliename');
  var elFase1    = document.getElementById('lina24-fase1');
  var elFase2    = document.getElementById('lina24-fase2');
  var elBtnsF2   = document.getElementById('lina24-btns-fase2');
  var elBtnsF3   = document.getElementById('lina24-btns-fase3');
  var elIngreso  = document.getElementById('lina24-ingreso');
  var elCierre   = document.getElementById('lina24-cierre');
  var elTbody    = document.getElementById('lina24-tbody');
  var elResumen  = document.getElementById('lina24-clie-resumen');
  var elReciNum  = document.getElementById('lina24-reci-num');
  var elTotal    = document.getElementById('lina24-total');
  var elBtnG     = document.getElementById('lina24-btn-guardar');
  var elBtnC     = document.getElementById('lina24-btn-cancelar');
  var elBtnConf  = document.getElementById('lina24-btn-confirmar');
  var elBtnCorr  = document.getElementById('lina24-btn-corregir');
  var elCtx      = document.getElementById('lina24-ctx');
  var inpReng    = document.getElementById('inp24-reng');
  var inpDesc    = document.getElementById('inp24-desc');
  var inpUnit    = document.getElementById('inp24-unit');
  var cierreObse  = document.getElementById('cierre24-obse');
  var cierreEfec  = document.getElementById('cierre24-efec');
  var cierreTransf= document.getElementById('cierre24-transf');
  var cierre24Dif = document.getElementById('cierre24-dif');

  // ── Helpers ───────────────────────────────────────────────────────────────
  function esc(s) {
    return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function fmtN(v) {
    var n = parseFloat(v) || 0;
    return n.toFixed(2).replace('.', ',').replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  }

  function cerrarCtx() { elCtx.style.display = 'none'; ctxTargetIdx = null; }

  function totalRecibo() {
    return lineas.reduce(function (s, l) { return s + (parseFloat(l.unit) || 0); }, 0);
  }

  function renumerarLineas() {
    lineas.forEach(function (l, i) { l.reng = i + 1; });
  }

  // ── FASE 1: validar cliente ───────────────────────────────────────────────
  function validarClie() {
    var cod = (elCodi.value || '').trim();
    if (!cod) { elNombre.textContent = ''; cliecodi = ''; cliename = ''; return; }
    fetch('/lina24/clie/info?cliecodi=' + encodeURIComponent(cod))
      .then(function (r) { return r.json(); })
      .then(function (d) {
        if (d.ok) {
          cliecodi = cod;
          cliename = d.cliename;
          cohenume = d.cohenume;
          irFase2();
        } else {
          cliecodi = ''; cliename = '';
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
    elResumen.textContent = String(cliecodi).padStart(4, '0') + ' — ' + cliename;
    elReciNum.textContent = 'RECI N° ' + String(cohenume).padStart(6, '0');
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

    var tot = totalRecibo();
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
  document.getElementById('lina24-ctx-eliminar').addEventListener('click', function () {
    if (ctxTargetIdx === null) { cerrarCtx(); return; }
    lineas.splice(ctxTargetIdx, 1);
    renumerarLineas();
    if (editingIdx !== null) editingIdx = null;
    cerrarCtx();
    renderGrid();
  });

  document.getElementById('lina24-ctx-subir').addEventListener('click', function () {
    if (ctxTargetIdx === null || ctxTargetIdx === 0) { cerrarCtx(); return; }
    var tmp = lineas[ctxTargetIdx - 1];
    lineas[ctxTargetIdx - 1] = lineas[ctxTargetIdx];
    lineas[ctxTargetIdx]     = tmp;
    renumerarLineas();
    cerrarCtx();
    renderGrid();
  });

  document.getElementById('lina24-ctx-bajar').addEventListener('click', function () {
    if (ctxTargetIdx === null || ctxTargetIdx >= lineas.length - 1) { cerrarCtx(); return; }
    var tmp = lineas[ctxTargetIdx + 1];
    lineas[ctxTargetIdx + 1] = lineas[ctxTargetIdx];
    lineas[ctxTargetIdx]     = tmp;
    renumerarLineas();
    cerrarCtx();
    renderGrid();
  });

  document.getElementById('lina24-ctx-modificar').addEventListener('click', function () {
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
    var tot   = totalRecibo();
    var efec  = parseFloat(cierreEfec.value)   || 0;
    var transf= parseFloat(cierreTransf.value) || 0;
    var dif   = tot - efec - transf;
    cierre24Dif.textContent = fmtN(dif);
    var ok = Math.abs(dif) < 0.01;
    cierre24Dif.style.color = ok ? '#2e7d32' : '#c00';
    elBtnConf.disabled = !ok;
    elBtnConf.style.opacity = ok ? '1' : '0.5';
  }

  function irCierre() {
    elIngreso.style.display = 'none';
    elCierre.style.display  = '';
    elBtnsF2.style.display  = 'none';
    elBtnsF3.style.display  = '';
    cierreObse.value   = '';
    cierreEfec.value   = totalRecibo().toFixed(2);
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
  function guardarRecibo() {
    if (elBtnConf.disabled) return;
    elBtnConf.disabled = true;
    var payload = {
      cliecodi: cliecodi,
      efec:     parseFloat(cierreEfec.value)   || 0,
      banc:     parseFloat(cierreTransf.value) || 0,
      coheobse: cierreObse.value.trim().slice(0, 40),
      lineas:   lineas.map(function (l) { return { desc: l.desc, unit: l.unit }; }),
    };
    fetch('/lina24/save', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify(payload),
    })
      .then(function (r) { return r.json(); })
      .then(function (d) {
        if (d.ok) {
          window.open('/cpbte/pdf?clpr=C&codm=RECI&nume=' + d.cohenume, '_blank');
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
    lineas = []; editingIdx = null; cliecodi = ''; cliename = ''; cohenume = 0;
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

  // Fase 1 — cliente
  elCodi.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') { e.preventDefault(); validarClie(); }
  });
  elCodi.addEventListener('change', function () { validarClie(); });

  // Fase 2 — renglón: Tab/Enter en concepto pasa a unitario
  inpDesc.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' || (e.key === 'Tab' && !e.shiftKey)) {
      e.preventDefault();
      inpUnit.focus();
      inpUnit.select();
    }
  });

  // Fase 2 — renglón: Enter o Tab en unitario confirma el renglón
  inpUnit.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' || (e.key === 'Tab' && !e.shiftKey)) {
      e.preventDefault();
      confirmarRenglon();
    }
  });

  // Confirmar también al salir del campo (click en otro lugar)
  inpUnit.addEventListener('blur', function () {
    var desc = (inpDesc.value || '').trim();
    var unit = parseFloat(inpUnit.value) || 0;
    if (desc || unit > 0) { confirmarRenglon(); }
  });

  // Botones fase 2
  elBtnG.addEventListener('click', function () { if (!elBtnG.disabled) irCierre(); });

  // Panel cierre: Tab order Observ → Efectivo → Transf → Guardar
  cierreObse.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') { e.preventDefault(); cierreEfec.focus(); cierreEfec.select(); }
  });
  cierreEfec.addEventListener('input',   actualizarDif);
  cierreEfec.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') { e.preventDefault(); cierreTransf.focus(); cierreTransf.select(); }
  });
  cierreTransf.addEventListener('input',   actualizarDif);
  cierreTransf.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') { e.preventDefault(); if (!elBtnConf.disabled) guardarRecibo(); }
  });

  // Botones fase 3
  elBtnConf.addEventListener('click', guardarRecibo);
  elBtnCorr.addEventListener('click', irCorregir);

  // Cancelar reinicia (no cierra el tab)
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

  // Foco inicial
  elCodi.focus();

})();
