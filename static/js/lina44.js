(function () {

  var elCodi     = document.getElementById('lina44-provcodi');
  var elNombre   = document.getElementById('lina44-provname');
  var elConcepto = document.getElementById('lina44-concepto');
  var elImporte  = document.getElementById('lina44-importe');
  var elBtnG     = document.getElementById('lina44-btn-guardar');
  var elBtnL     = document.getElementById('lina44-btn-limpiar');

  var provcodi = 0;

  // ── Validar proveedor ────────────────────────────────────────────────────
  function validarProv() {
    var cod = (elCodi.value || '').trim();
    if (!cod) {
      provcodi = 0;
      elNombre.textContent = '';
      elNombre.style.color = '';
      return;
    }
    fetch('/lina44/prov/info?provcodi=' + encodeURIComponent(cod))
      .then(function (r) { return r.json(); })
      .then(function (d) {
        if (d.ok) {
          provcodi = parseInt(cod, 10) || 0;
          elNombre.textContent  = d.provname;
          elNombre.style.color  = '#333';
          elNombre.style.fontWeight = 'normal';
          elConcepto.focus();
        } else {
          provcodi = 0;
          elNombre.textContent  = 'No encontrado';
          elNombre.style.color  = '#c00';
          elNombre.style.fontWeight = 'normal';
        }
      })
      .catch(function () {
        elNombre.textContent = 'Error de red';
        elNombre.style.color = '#c00';
      });
  }

  // ── Guardar ──────────────────────────────────────────────────────────────
  function guardar() {
    var concepto = (elConcepto.value || '').trim();
    var importe  = parseFloat(elImporte.value) || 0;

    if (!concepto) {
      alert('Debe ingresar un concepto.');
      elConcepto.focus();
      return;
    }
    if (Math.abs(importe) < 0.005) {
      alert('El importe no puede ser cero.');
      elImporte.focus();
      return;
    }

    elBtnG.disabled = true;
    fetch('/lina44/save', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({
        provcodi: provcodi,
        concepto: concepto,
        importe:  importe,
      }),
    })
      .then(function (r) { return r.json(); })
      .then(function (d) {
        if (d.ok) {
          alert(d.message);
          // Limpiar concepto e importe, mantener proveedor
          elConcepto.value = '';
          elImporte.value  = '';
          elConcepto.focus();
        } else {
          alert('Error: ' + (d.error || 'desconocido'));
        }
        elBtnG.disabled = false;
      })
      .catch(function (err) {
        alert('Error de red: ' + err);
        elBtnG.disabled = false;
      });
  }

  // ── Limpiar todo ─────────────────────────────────────────────────────────
  function limpiar() {
    provcodi = 0;
    elCodi.value         = '';
    elNombre.textContent = '';
    elNombre.style.color = '';
    elConcepto.value     = '';
    elImporte.value      = '';
    elCodi.focus();
  }

  // ── Eventos ──────────────────────────────────────────────────────────────
  elCodi.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') { e.preventDefault(); validarProv(); }
  });
  elCodi.addEventListener('change', function () { validarProv(); });

  elConcepto.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' || (e.key === 'Tab' && !e.shiftKey)) {
      e.preventDefault();
      elImporte.focus();
      elImporte.select();
    }
  });

  elImporte.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') { e.preventDefault(); guardar(); }
  });

  elBtnG.addEventListener('click', guardar);
  elBtnL.addEventListener('click', limpiar);

  document.addEventListener('keydown', function (e) {
    if (e.ctrlKey && e.key === 's') {
      e.preventDefault();
      guardar();
    }
    if (e.key === 'Escape') limpiar();
  });

  elCodi.focus();

})();
