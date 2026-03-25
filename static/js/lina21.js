(function () {

  // ── Config inyectada desde el servidor ────────────────────────────────────
  var _cfg       = JSON.parse(document.getElementById('lina21-config').textContent || '{}');
  var MAX_LINEAS = _cfg.maxLineas  || 40;
  var CLIE_AJUSTE = _cfg.clieAjuste || 9000;

  // ── Estado ────────────────────────────────────────────────────────────────
  var lineas      = [];          // {reng, articodi, desc, exis, cant, unit}
  var editingIdx  = null;        // null = nueva línea; N = modificando lineas[N]
  var cliecodi    = '';
  var cliename    = '';
  var ctxTargetIdx = null;       // índice de fila bajo el menú contextual

  // ── Elementos DOM ─────────────────────────────────────────────────────────
  var elCodi     = document.getElementById('lina21-cliecodi');
  var elNombre   = document.getElementById('lina21-cliename');
  var elBtnG     = document.getElementById('lina21-btn-guardar');
  var elBtnC     = document.getElementById('lina21-btn-cancelar');
  var elBtnConf  = document.getElementById('lina21-btn-confirmar');
  var elBtnCorr  = document.getElementById('lina21-btn-corregir');
  var elFase1    = document.getElementById('lina21-fase1');
  var elFase2    = document.getElementById('lina21-fase2');
  var elBtnsF2   = document.getElementById('lina21-btns-fase2');
  var elBtnsF3   = document.getElementById('lina21-btns-fase3');
  var elIngreso  = document.getElementById('lina21-ingreso');
  var elPago     = document.getElementById('lina21-pago');
  var pagoEfec   = document.getElementById('pago-efec');
  var pagoBanc   = document.getElementById('pago-banc');
  var pagoCtacte = document.getElementById('pago-ctacte');
  var pagoObse   = document.getElementById('pago-obse');
  var elTbody    = document.getElementById('lina21-tbody');
  var elResumen  = document.getElementById('lina21-clie-resumen');
  var elTotalC   = document.getElementById('lina21-total-cant');
  var elTotalI   = document.getElementById('lina21-total-importe');
  var elCtx      = document.getElementById('lina21-ctx');
  var inpReng    = document.getElementById('inp-reng');
  var inpArti    = document.getElementById('inp-articodi');
  var inpDesc    = document.getElementById('inp-desc');
  var inpExis    = document.getElementById('inp-exis');
  var inpCant    = document.getElementById('inp-cant');
  var inpUnit    = document.getElementById('inp-unit');
  var inpSubt    = document.getElementById('inp-subtotal');

  // ── Helpers ───────────────────────────────────────────────────────────────
  function renumerarLineas() {
    lineas.forEach(function(l, i) { l.reng = i + 1; });
  }

  function fmtN(v) {
    var n = parseFloat(v) || 0;
    return n.toFixed(2).replace('.', ',').replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  }

  function isAjuste() { return parseInt(cliecodi) === CLIE_AJUSTE; }

  function parseUnit(s) {
    return parseFloat((s || '').replace(/\./g, '').replace(',', '.')) || 0;
  }

  function activarStar() {
    inpDesc.removeAttribute('readonly'); inpDesc.removeAttribute('tabindex');
    inpDesc.style.background = '#fffff8'; inpDesc.style.borderColor = '#aaa';
    inpUnit.removeAttribute('readonly'); inpUnit.removeAttribute('tabindex');
    inpUnit.style.background = '#fffff8'; inpUnit.style.borderColor = '#aaa';
    inpUnit.dataset.val = '';
    inpCant.value = 1; inpCant.disabled = true; inpCant.style.background = '#f0f0f0';
  }

  function desactivarStar() {
    inpDesc.setAttribute('readonly', ''); inpDesc.setAttribute('tabindex', '-1');
    inpDesc.style.background = '#f0f0f0'; inpDesc.style.borderColor = '#ddd';
    inpUnit.setAttribute('readonly', ''); inpUnit.setAttribute('tabindex', '-1');
    inpUnit.style.background = '#f0f0f0'; inpUnit.style.borderColor = '#ddd';
    inpCant.disabled = false; inpCant.style.background = '#fffff8';
  }

  function cerrarCtx() { elCtx.style.display = 'none'; ctxTargetIdx = null; }

  // ── FASE 1: validar cliente ───────────────────────────────────────────────
  function validarClie() {
    var cod = (elCodi.value || '').trim();
    if (!cod) {
      elNombre.textContent = ''; cliecodi = ''; cliename = '';
      return;
    }
    fetch('/lina21/clie/info?cliecodi=' + encodeURIComponent(cod))
      .then(function(r) { return r.json(); })
      .then(function(d) {
        if (d.ok) {
          cliecodi = cod; cliename = d.cliename;
          irFase2();
        } else {
          cliecodi = ''; cliename = '';
          elNombre.textContent  = 'No encontrado';
          elNombre.style.color  = '#c00';
          elNombre.style.fontWeight = 'normal';
        }
      })
      .catch(function() {
        elNombre.textContent = 'Error de red';
        elNombre.style.color = '#c00';
      });
  }

  // ── Transición a FASE 2 ───────────────────────────────────────────────────
  function irFase2() {
    elFase1.style.display  = 'none';
    elFase2.style.setProperty('display', 'flex', 'important');
    elBtnsF2.style.display = '';
    elResumen.textContent  = cliecodi + ' — ' + cliename;
    renderGrid();
    inpArti.focus();
  }

  // ── Grilla: renderizar ────────────────────────────────────────────────────
  var MIN_ROWS = MAX_LINEAS;   // grilla fija de MAX_LINEAS renglones (datos + vacíos)

  function renderGrid() {
    while (elTbody.firstChild) elTbody.removeChild(elTbody.firstChild);

    // Filas con datos
    lineas.forEach(function(l, idx) {
      var tr = document.createElement('tr');
      tr.style.background = idx % 2 === 0 ? '#fff' : '#f7f7f7';
      tr.style.cursor = 'default';
      if (editingIdx === idx) {
        tr.style.background = '#fff8dc';
        tr.style.opacity = '0.6';
      }
      tr.innerHTML =
        '<td style="padding:1px 4px;text-align:center;color:#888;">' + l.reng + '</td>' +
        '<td style="padding:1px 4px;font-family:monospace;">' + esc(l.articodi) + '</td>' +
        '<td style="padding:1px 4px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + esc(l.desc) + '</td>' +
        '<td style="padding:1px 4px;text-align:right;font-family:monospace;color:#666;">' + (l.exis !== '' ? l.exis : '') + '</td>' +
        '<td style="padding:1px 4px;text-align:right;font-family:monospace;">' + l.cant + '</td>' +
        '<td style="padding:1px 4px;text-align:right;font-family:monospace;color:#444;">' + fmtN(l.unit) + '</td>' +
        '<td style="padding:1px 4px;text-align:right;font-family:monospace;font-weight:bold;">' + fmtN(l.cant * l.unit) + '</td>';
      (function(i) {
        tr.addEventListener('contextmenu', function(e) {
          e.preventDefault();
          ctxTargetIdx = i;
          elCtx.style.display = 'block';
          elCtx.style.left = e.clientX + 'px';
          elCtx.style.top  = e.clientY + 'px';
        });
      })(idx);
      elTbody.appendChild(tr);
    });

    // Filas vacías hasta MIN_ROWS
    var vacías = Math.max(0, MIN_ROWS - lineas.length);
    for (var v = 0; v < vacías; v++) {
      var rn = lineas.length + v + 1;
      var bg = (lineas.length + v) % 2 === 0 ? '#fff' : '#f7f7f7';
      var trv = document.createElement('tr');
      trv.style.background = bg;
      trv.innerHTML =
        '<td style="padding:1px 4px;text-align:center;color:#ccc;font-size:7.5pt;">' + rn + '</td>' +
        '<td></td><td></td><td></td><td></td><td></td><td></td>';
      elTbody.appendChild(trv);
    }

    // Actualizar fila renglón en input
    inpReng.textContent = editingIdx !== null ? lineas[editingIdx].reng : lineas.length + 1;

    // Totales
    var totC = 0;
    lineas.forEach(function(l) { totC += parseInt(l.cant) || 0; });
    elTotalC.textContent = totC;
    elTotalI.textContent = '$ ' + fmtN(totalRemito());

    // Guardar habilitado si hay renglones
    elBtnG.disabled    = lineas.length === 0;
    elBtnG.style.opacity = lineas.length === 0 ? '0.5' : '1';
  }

  function esc(s) {
    return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  }

  // ── Fila de ingreso: buscar artículo ──────────────────────────────────────
  function buscarArti() {
    var cod = (inpArti.value || '').trim().toUpperCase();
    inpArti.value = cod;
    if (!cod) { limpiarInp(false); return; }
    if (cod === '*') {
      if (isAjuste()) {
        alert('El artículo * no está disponible para ajustes de stock.');
        inpArti.value = ''; inpArti.focus(); return;
      }
      inpDesc.value = ''; inpExis.textContent = ''; inpSubt.textContent = '';
      inpUnit.value = ''; inpUnit.dataset.val = '';
      activarStar();
      inpDesc.focus();
      return;
    }
    fetch('/lina21/arti/info?articodi=' + encodeURIComponent(cod))
      .then(function(r) { return r.json(); })
      .then(function(d) {
        if (d.ok) {
          inpDesc.value        = d.artidesc;
          inpExis.textContent  = d.existencia;
          inpExis.style.color  = '#555';
          var precio = isAjuste() ? 0 : d.artiprec;
          inpUnit.value        = fmtN(precio);
          inpUnit.dataset.val  = precio;
          inpSubt.textContent  = '';
          inpCant.value        = '';
          inpCant.focus();
          inpCant.select();
        } else {
          alert('Artículo "' + cod + '" no encontrado.');
          inpArti.value = ''; inpArti.focus();
        }
      })
      .catch(function() { alert('Error al buscar artículo.'); inpArti.focus(); });
  }

  function actualizarSubtotal() {
    var cant  = parseInt(inpCant.value) || 0;
    var unit  = parseFloat(inpUnit.dataset.val) || 0;
    var exis  = parseInt(inpExis.textContent);
    inpSubt.textContent = cant !== 0 ? fmtN(cant * unit) : '';
    inpExis.style.color = (!isNaN(exis) && cant > 0 && cant > exis) ? '#c00' : '#555';
  }

  // ── Confirmar renglón ─────────────────────────────────────────────────────
  function confirmarRenglon() {
    var cod  = (inpArti.value || '').trim().toUpperCase();
    var cant = parseInt(inpCant.value) || 0;
    var unit = parseFloat(inpUnit.dataset.val) || 0;
    if (!cod)  { alert('Ingrese el código de artículo.'); inpArti.focus(); return; }
    if (cod === '*' && unit === 0) { alert('Ingrese el precio del artículo.'); inpUnit.focus(); return; }
    if (isAjuste() ? cant === 0 : cant <= 0) {
      alert(isAjuste() ? 'La cantidad no puede ser cero.' : 'La cantidad debe ser mayor a cero.');
      inpCant.focus(); return;
    }
    if (lineas.length >= MAX_LINEAS && editingIdx === null) {
      alert('Se alcanzó el máximo de ' + MAX_LINEAS + ' renglones.'); return;
    }
    var linea = {
      reng:     editingIdx !== null ? lineas[editingIdx].reng : lineas.length + 1,
      articodi: cod,
      desc:     inpDesc.value,
      exis:     inpExis.textContent,
      cant:     cant,
      unit:     unit,
    };
    if (editingIdx !== null) {
      lineas[editingIdx] = linea;
      editingIdx = null;
    } else {
      lineas.push(linea);
    }
    limpiarInp(true);
    renderGrid();
    setTimeout(function() { inpArti.focus(); }, 0);
  }

  function limpiarInp(full) {
    if (full) inpArti.value = '';
    inpDesc.value           = '';
    inpExis.textContent     = '';
    inpUnit.value           = '';
    inpUnit.dataset.val     = '';
    inpSubt.textContent     = '';
    inpCant.value           = '';
    desactivarStar();
  }

  // ── Menú contextual ───────────────────────────────────────────────────────
  document.getElementById('lina21-ctx-eliminar').addEventListener('click', function() {
    if (ctxTargetIdx === null) { cerrarCtx(); return; }
    lineas.splice(ctxTargetIdx, 1);
    renumerarLineas();
    if (editingIdx !== null) editingIdx = null;
    cerrarCtx();
    renderGrid();
  });

  document.getElementById('lina21-ctx-subir').addEventListener('click', function() {
    if (ctxTargetIdx === null || ctxTargetIdx === 0) { cerrarCtx(); return; }
    var tmp = lineas[ctxTargetIdx - 1];
    lineas[ctxTargetIdx - 1] = lineas[ctxTargetIdx];
    lineas[ctxTargetIdx]     = tmp;
    renumerarLineas();
    cerrarCtx();
    renderGrid();
  });

  document.getElementById('lina21-ctx-bajar').addEventListener('click', function() {
    if (ctxTargetIdx === null || ctxTargetIdx >= lineas.length - 1) { cerrarCtx(); return; }
    var tmp = lineas[ctxTargetIdx + 1];
    lineas[ctxTargetIdx + 1] = lineas[ctxTargetIdx];
    lineas[ctxTargetIdx]     = tmp;
    renumerarLineas();
    cerrarCtx();
    renderGrid();
  });

  document.getElementById('lina21-ctx-modificar').addEventListener('click', function() {
    if (ctxTargetIdx === null) { cerrarCtx(); return; }
    var l = lineas[ctxTargetIdx];
    editingIdx         = ctxTargetIdx;
    inpArti.value      = l.articodi;
    inpDesc.value      = l.desc;
    inpExis.textContent = l.exis;
    inpUnit.dataset.val = l.unit;
    inpCant.value      = l.cant;
    if (l.articodi === '*') {
      activarStar();
      inpUnit.value = l.unit;
    } else {
      inpUnit.value = fmtN(l.unit);
    }
    actualizarSubtotal();
    cerrarCtx();
    renderGrid();
    if (l.articodi === '*') { inpDesc.focus(); } else { inpCant.focus(); inpCant.select(); }
  });

  document.addEventListener('click', function(e) {
    if (!elCtx.contains(e.target)) cerrarCtx();
  });

  // ── FASE 3: panel de pago ────────────────────────────────────────────────
  function totalRemito() {
    return lineas.reduce(function(s, l) { return s + (parseInt(l.cant) || 0) * (parseFloat(l.unit) || 0); }, 0);
  }

  function actualizarCtacte() {
    var efec  = parseFloat(pagoEfec.value)  || 0;
    var banc  = parseFloat(pagoBanc.value)  || 0;
    var ctacte = totalRemito() - efec - banc;
    pagoCtacte.textContent = fmtN(ctacte);
    pagoCtacte.style.color = ctacte < 0 ? '#c00' : '#1a3a6a';
  }

  function irPago() {
    elIngreso.style.display  = 'none';
    elPago.style.display     = '';
    elBtnsF2.style.display   = 'none';
    elBtnsF3.style.display   = '';
    pagoEfec.value = '0'; pagoBanc.value = '0'; pagoObse.value = '';
    actualizarCtacte();
    setTimeout(function() { pagoEfec.focus(); pagoEfec.select(); }, 0);
  }

  function irCorregir() {
    elPago.style.display     = 'none';
    elIngreso.style.display  = '';
    elBtnsF3.style.display   = 'none';
    elBtnsF2.style.display   = '';
    setTimeout(function() { inpArti.focus(); }, 0);
  }

  function guardarRemito() {
    elBtnConf.disabled = true;
    var efec = parseFloat(pagoEfec.value) || 0;
    var banc = parseFloat(pagoBanc.value) || 0;
    var obse = pagoObse.value.trim().slice(0, 40);
    var payload = {
      cliecodi:  cliecodi,
      efec:      efec,
      banc:      banc,
      fvheobse:  obse,
      lineas:   lineas.map(function(l) {
        return { articodi: l.articodi, desc: l.desc, cant: l.cant, unit: l.unit };
      })
    };
    fetch('/lina21/save', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify(payload)
    })
    .then(function(r) { return r.json(); })
    .then(function(d) {
      if (d.ok) {
        window.open('/cpbte/pdf?clpr=C&codm=REMI&nume=' + d.fvhenume, '_blank');
        reiniciar();
      } else {
        alert('Error: ' + (d.error || 'desconocido'));
        elBtnConf.disabled = false;
        if (lineas.length > 0) { elBtnG.disabled = false; elBtnG.style.opacity = '1'; }
      }
    })
    .catch(function(err) {
      alert('Error de red: ' + err);
      elBtnConf.disabled = false;
    });
  }

  function reiniciar() {
    lineas = []; editingIdx = null; cliecodi = ''; cliename = '';
    elPago.style.display    = 'none';
    elIngreso.style.display = '';
    elBtnsF3.style.display  = 'none';
    elBtnsF2.style.display  = 'none';
    elFase2.style.setProperty('display', 'none', 'important');
    elFase1.style.display   = '';
    elCodi.value = ''; elNombre.textContent = '';
    setTimeout(function() { elCodi.focus(); }, 0);
  }

  // ── Cancelar / Cerrar tab ─────────────────────────────────────────────────
  function cancelar() {
    var mgr = window.linaTabsManager;
    if (mgr && mgr.activeTab) mgr.closeTab(mgr.activeTab);
  }

  // ── Event listeners ───────────────────────────────────────────────────────

  // Fase 1 — cliente
  elCodi.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') { e.preventDefault(); validarClie(); }
  });
  elCodi.addEventListener('change', function() { validarClie(); });

  // Fase 2 — código artículo
  inpArti.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      if ((inpArti.value || '').trim().toUpperCase() === '*') e.stopPropagation();
      buscarArti();
    }
  });
  inpArti.addEventListener('change', function() { buscarArti(); });

  // Fase 2 — descripción: cuando es editable (*) Enter/Pad+ avanza a precio
  inpDesc.addEventListener('keydown', function(e) {
    if ((e.key === 'Enter' || e.code === 'NumpadAdd') && !inpDesc.readOnly) {
      e.preventDefault(); e.stopPropagation();
      inpUnit.focus(); inpUnit.select();
    }
  });

  // Fase 2 — precio: cuando es editable (*) Enter/Pad+ avanza a cantidad;
  //           actualiza valor al escribir
  inpUnit.addEventListener('keydown', function(e) {
    if ((e.key === 'Enter' || e.code === 'NumpadAdd') && !inpUnit.readOnly) {
      e.preventDefault(); e.stopPropagation();
      confirmarRenglon();
    }
  });
  inpUnit.addEventListener('input', function() {
    if (!inpUnit.readOnly) {
      inpUnit.dataset.val = parseUnit(inpUnit.value);
      actualizarSubtotal();
    }
  });

  // Fase 2 — cantidad
  inpCant.addEventListener('input',   actualizarSubtotal);
  inpCant.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' || e.code === 'NumpadAdd') {
      e.preventDefault();
      confirmarRenglon();
    }
  });

  // Fase 2 — botón Guardar Remito → ir a pago
  elBtnG.addEventListener('click', function() {
    if (!elBtnG.disabled) {
      if (isAjuste()) {
        elBtnG.disabled = true; elBtnG.style.opacity = '0.5';
        guardarRemito();
      } else {
        irPago();
      }
    }
  });

  // Fase 3 — botones
  elBtnConf.addEventListener('click', guardarRemito);
  elBtnCorr.addEventListener('click', irCorregir);
  pagoEfec.addEventListener('input', actualizarCtacte);
  pagoBanc.addEventListener('input', actualizarCtacte);
  pagoEfec.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') { e.preventDefault(); pagoBanc.focus(); pagoBanc.select(); }
  });
  pagoBanc.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') { e.preventDefault(); pagoObse.focus(); pagoObse.select(); }
  });
  pagoObse.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') { e.preventDefault(); guardarRemito(); }
  });

  // Cancelar → reiniciar (vuelve a fase1, borra todo)
  elBtnC.addEventListener('click', reiniciar);

  // Escape → un paso atrás según estado actual (sin perder renglones ya confirmados)
  document.addEventListener('keydown', function(e) {
    if (e.ctrlKey && e.key === 's') {
      e.preventDefault();
      if (elBtnConf && elBtnConf.offsetParent !== null) { elBtnConf.click(); }
      else if (elBtnG && !elBtnG.disabled && elBtnG.offsetParent !== null) { elBtnG.click(); }
      return;
    }
    if (e.key !== 'Escape') return;
    e.preventDefault();
    if (elFase1.style.display === 'none') {       // estamos en fase2 o fase3
      if (elPago.style.display !== 'none') {      // fase3: panel de pago
        irCorregir();
      } else {                                    // fase2: ingreso de renglones
        limpiarInp(true);
        setTimeout(function() { inpArti.focus(); }, 0);
      }
    }
    // fase1: no hacer nada (ya estamos al inicio)
  });

  // Foco inicial
  elCodi.focus();

})();
