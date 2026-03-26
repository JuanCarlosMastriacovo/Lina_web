(function () {

  // ── Config inyectada desde el servidor ────────────────────────────────────
  var _cfg       = JSON.parse(document.getElementById('lina31-config').textContent || '{}');
  var MAX_LINEAS = _cfg.maxLineas || 40;

  // ── Estado ────────────────────────────────────────────────────────────────
  var lineas      = [];          // {reng, articodi, desc, exis, cant, unit}
  var editingIdx  = null;        // null = nueva línea; N = modificando lineas[N]
  var provcodi    = '';
  var provname    = '';
  var ctxTargetIdx = null;       // índice de fila bajo el menú contextual

  // ── Elementos DOM ─────────────────────────────────────────────────────────
  var elCodi     = document.getElementById('lina31-provcodi');
  var elNombre   = document.getElementById('lina31-provname');
  var elBtnG     = document.getElementById('lina31-btn-guardar');
  var elBtnC     = document.getElementById('lina31-btn-cancelar');
  var elFase1    = document.getElementById('lina31-fase1');
  var elFase2    = document.getElementById('lina31-fase2');
  var elIngreso  = document.getElementById('lina31-ingreso');
  var elTbody    = document.getElementById('lina31-tbody');
  var elResumen  = document.getElementById('lina31-prov-resumen');
  var elTotalC   = document.getElementById('lina31-total-cant');
  var elTotalI   = document.getElementById('lina31-total-importe');
  var elCtx      = document.getElementById('lina31-ctx');
  var fcheObse   = document.getElementById('fche-obse');
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

  function parseUnit(s) {
    return parseFloat((s || '').replace(/\./g, '').replace(',', '.')) || 0;
  }

  function cerrarCtx() { elCtx.style.display = 'none'; ctxTargetIdx = null; }

  function esStar() { return (inpArti.value || '').trim().toUpperCase() === '*'; }

  // Activa la descripción editable (solo para artículo *)
  function activarDescEditable() {
    inpDesc.removeAttribute('readonly'); inpDesc.removeAttribute('tabindex');
    inpDesc.style.background = '#fffff8'; inpDesc.style.borderColor = '#aaa';
  }

  function desactivarDescEditable() {
    inpDesc.setAttribute('readonly', ''); inpDesc.setAttribute('tabindex', '-1');
    inpDesc.style.background = '#f0f0f0'; inpDesc.style.borderColor = '#ddd';
  }

  // ── FASE 1: validar proveedor ─────────────────────────────────────────────
  function validarProv() {
    var cod = (elCodi.value || '').trim();
    if (!cod) {
      elNombre.textContent = ''; provcodi = ''; provname = '';
      return;
    }
    fetch('/lina31/prov/info?provcodi=' + encodeURIComponent(cod))
      .then(function(r) { return r.json(); })
      .then(function(d) {
        if (d.ok) {
          provcodi = cod; provname = d.provname;
          irFase2();
        } else {
          provcodi = ''; provname = '';
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
    elResumen.textContent  = provcodi + ' — ' + provname;
    renderGrid();
    inpArti.focus();
  }

  // ── Grilla: renderizar ────────────────────────────────────────────────────
  var MIN_ROWS = MAX_LINEAS;

  function renderGrid() {
    while (elTbody.firstChild) elTbody.removeChild(elTbody.firstChild);

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

    inpReng.textContent = editingIdx !== null ? lineas[editingIdx].reng : lineas.length + 1;

    var totC = 0;
    lineas.forEach(function(l) { totC += parseInt(l.cant) || 0; });
    elTotalC.textContent = totC;
    elTotalI.textContent = '$ ' + fmtN(totalFactura());

    elBtnG.disabled      = lineas.length === 0;
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
      inpDesc.value = ''; inpExis.textContent = ''; inpSubt.textContent = '';
      inpUnit.value = ''; inpUnit.dataset.val = '0';
      activarDescEditable();
      inpDesc.focus();
      return;
    }
    fetch('/lina31/arti/info?articodi=' + encodeURIComponent(cod))
      .then(function(r) { return r.json(); })
      .then(function(d) {
        if (d.ok) {
          inpDesc.value        = d.artidesc;
          inpExis.textContent  = d.existencia;
          inpExis.style.color  = '#555';
          inpUnit.value        = '';
          inpUnit.dataset.val  = '0';
          inpSubt.textContent  = '';
          inpCant.value        = '';
          desactivarDescEditable();
          inpUnit.focus();
          inpUnit.select();
        } else {
          alert('Artículo "' + cod + '" no encontrado.');
          inpArti.value = ''; inpArti.focus();
        }
      })
      .catch(function() { alert('Error al buscar artículo.'); inpArti.focus(); });
  }

  function actualizarSubtotal() {
    var cant = parseInt(inpCant.value) || 0;
    var unit = parseFloat(inpUnit.dataset.val) || 0;
    inpSubt.textContent = cant !== 0 && unit !== 0 ? fmtN(cant * unit) : '';
  }

  // ── Confirmar renglón ─────────────────────────────────────────────────────
  function confirmarRenglon() {
    var cod  = (inpArti.value || '').trim().toUpperCase();
    var cant = parseInt(inpCant.value) || 0;
    var unit = parseFloat(inpUnit.dataset.val) || 0;
    if (!cod)      { alert('Ingrese el código de artículo.'); inpArti.focus(); return; }
    if (unit === 0){ alert('Ingrese el precio unitario.'); inpUnit.focus(); return; }
    if (cant <= 0) { alert('La cantidad debe ser mayor a cero.'); inpCant.focus(); return; }
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
    inpDesc.value       = '';
    inpExis.textContent = '';
    inpUnit.value       = '';
    inpUnit.dataset.val = '0';
    inpSubt.textContent = '';
    inpCant.value       = '';
    desactivarDescEditable();
  }

  // ── Menú contextual ───────────────────────────────────────────────────────
  document.getElementById('lina31-ctx-eliminar').addEventListener('click', function() {
    if (ctxTargetIdx === null) { cerrarCtx(); return; }
    lineas.splice(ctxTargetIdx, 1);
    renumerarLineas();
    if (editingIdx !== null) editingIdx = null;
    cerrarCtx();
    renderGrid();
  });

  document.getElementById('lina31-ctx-subir').addEventListener('click', function() {
    if (ctxTargetIdx === null || ctxTargetIdx === 0) { cerrarCtx(); return; }
    var tmp = lineas[ctxTargetIdx - 1];
    lineas[ctxTargetIdx - 1] = lineas[ctxTargetIdx];
    lineas[ctxTargetIdx]     = tmp;
    renumerarLineas();
    cerrarCtx();
    renderGrid();
  });

  document.getElementById('lina31-ctx-bajar').addEventListener('click', function() {
    if (ctxTargetIdx === null || ctxTargetIdx >= lineas.length - 1) { cerrarCtx(); return; }
    var tmp = lineas[ctxTargetIdx + 1];
    lineas[ctxTargetIdx + 1] = lineas[ctxTargetIdx];
    lineas[ctxTargetIdx]     = tmp;
    renumerarLineas();
    cerrarCtx();
    renderGrid();
  });

  document.getElementById('lina31-ctx-modificar').addEventListener('click', function() {
    if (ctxTargetIdx === null) { cerrarCtx(); return; }
    var l = lineas[ctxTargetIdx];
    editingIdx          = ctxTargetIdx;
    inpArti.value       = l.articodi;
    inpDesc.value       = l.desc;
    inpExis.textContent = l.exis;
    inpUnit.dataset.val = l.unit;
    inpUnit.value       = fmtN(l.unit);
    inpCant.value       = l.cant;
    if (l.articodi === '*') {
      activarDescEditable();
    } else {
      desactivarDescEditable();
    }
    actualizarSubtotal();
    cerrarCtx();
    renderGrid();
    inpUnit.focus(); inpUnit.select();
  });

  document.addEventListener('click', function(e) {
    if (!elCtx.contains(e.target)) cerrarCtx();
  });

  // ── Total ─────────────────────────────────────────────────────────────────
  function totalFactura() {
    return lineas.reduce(function(s, l) {
      return s + (parseInt(l.cant) || 0) * (parseFloat(l.unit) || 0);
    }, 0);
  }

  // ── Guardar ───────────────────────────────────────────────────────────────
  function guardarFactura() {
    elBtnG.disabled = true;
    var obse = (fcheObse.value || '').trim().slice(0, 40);
    var payload = {
      provcodi: provcodi,
      fcheobse: obse,
      lineas:   lineas.map(function(l) {
        return { articodi: l.articodi, desc: l.desc, cant: l.cant, unit: l.unit };
      })
    };
    fetch('/lina31/save', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify(payload)
    })
    .then(function(r) { return r.json(); })
    .then(function(d) {
      if (d.ok) {
        alert(d.message || 'Factura registrada.');
        reiniciar();
      } else {
        alert('Error: ' + (d.error || 'desconocido'));
        elBtnG.disabled = false;
        elBtnG.style.opacity = '1';
      }
    })
    .catch(function(err) {
      alert('Error de red: ' + err);
      elBtnG.disabled = false;
    });
  }

  function reiniciar() {
    lineas = []; editingIdx = null; provcodi = ''; provname = '';
    elFase2.style.setProperty('display', 'none', 'important');
    elFase1.style.display = '';
    elCodi.value = ''; elNombre.textContent = '';
    fcheObse.value = '';
    setTimeout(function() { elCodi.focus(); }, 0);
  }

  // ── Cancelar ──────────────────────────────────────────────────────────────
  function cancelar() {
    var mgr = window.linaTabsManager;
    if (mgr && mgr.activeTab) mgr.closeTab(mgr.activeTab);
  }

  // ── Event listeners ───────────────────────────────────────────────────────

  // Fase 1 — proveedor
  elCodi.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') { e.preventDefault(); validarProv(); }
  });
  elCodi.addEventListener('change', function() { validarProv(); });

  // Fase 2 — código artículo
  inpArti.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      if ((inpArti.value || '').trim().toUpperCase() === '*') e.stopPropagation();
      buscarArti();
    }
  });
  inpArti.addEventListener('change', function() { buscarArti(); });

  // Descripción: Enter/Pad+ avanza a precio (solo cuando editable, artículo *)
  inpDesc.addEventListener('keydown', function(e) {
    if ((e.key === 'Enter' || e.code === 'NumpadAdd') && !inpDesc.readOnly) {
      e.preventDefault(); e.stopPropagation();
      inpUnit.focus(); inpUnit.select();
    }
  });

  // Precio: siempre editable; Enter/Pad+ avanza a cantidad
  inpUnit.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' || e.code === 'NumpadAdd') {
      e.preventDefault(); e.stopPropagation();
      inpUnit.dataset.val = parseUnit(inpUnit.value);
      actualizarSubtotal();
      inpCant.focus(); inpCant.select();
    }
  });
  inpUnit.addEventListener('input', function() {
    inpUnit.dataset.val = parseUnit(inpUnit.value);
    actualizarSubtotal();
  });

  // Cantidad
  inpCant.addEventListener('input', actualizarSubtotal);
  inpCant.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' || e.code === 'NumpadAdd') {
      e.preventDefault();
      confirmarRenglon();
    }
  });

  // Botón Guardar
  elBtnG.addEventListener('click', function() {
    if (!elBtnG.disabled) guardarFactura();
  });

  // Cancelar
  elBtnC.addEventListener('click', reiniciar);

  // Teclado global
  document.addEventListener('keydown', function(e) {
    if (e.ctrlKey && e.key === 's') {
      e.preventDefault();
      if (elBtnG && !elBtnG.disabled && elBtnG.offsetParent !== null) { elBtnG.click(); }
      return;
    }
    if (e.key !== 'Escape') return;
    e.preventDefault();
    if (elFase1.style.display === 'none') {
      limpiarInp(true);
      setTimeout(function() { inpArti.focus(); }, 0);
    }
  });

  // Foco inicial
  elCodi.focus();

})();
