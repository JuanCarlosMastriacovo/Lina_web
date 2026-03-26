/* ============================================================
   lina_base_session.js
   Gestión de contexto de sesión en la navbar:
     - Selector de empresa activa (F2)
     - Selector de fecha de sesión (F3)
     - Navegación por teclado global (Escape, Alt+hotkey, NumPad)

   Las funciones públicas (linaToggleCompanyPicker, etc.) se exponen
   en window porque son invocadas desde atributos onclick en el HTML.
   El resto se encapsula en IIFE para no contaminar el scope global.
   ============================================================ */

(function () {

  /* ── Inicialización DOM ── */

  document.addEventListener('DOMContentLoaded', function () {
    // Inicializar popovers Bootstrap si los hay.
    document.querySelectorAll('[data-bs-toggle="popover"]').forEach(function (el) {
      new bootstrap.Popover(el, { trigger: 'focus', html: false });
    });

    // Botones de empresa.
    const btnEmpr = document.getElementById('btn-empr');
    if (btnEmpr) btnEmpr.addEventListener('click', linaToggleCompanyPicker);
    const btnEmprApply = document.getElementById('btn-empr-apply');
    if (btnEmprApply) btnEmprApply.addEventListener('click', linaApplySessionCompany);
    const btnEmprCancel = document.getElementById('btn-empr-cancel');
    if (btnEmprCancel) btnEmprCancel.addEventListener('click', function () { linaCloseCompanyPicker(true); });

    // Botones de fecha de sesión.
    const btnFecha = document.getElementById('btn-fecha');
    if (btnFecha) {
      btnFecha.addEventListener('click', linaToggleSessionDatePicker);
      _actualizarEstiloFecha(btnFecha);
    }
    const btnFechaApply = document.getElementById('btn-fecha-apply');
    if (btnFechaApply) btnFechaApply.addEventListener('click', linaApplySessionDate);
    const btnFechaCancel = document.getElementById('btn-fecha-cancel');
    if (btnFechaCancel) btnFechaCancel.addEventListener('click', function () { linaCloseSessionDatePicker(true); });

    // Atajos de teclado dentro del selector de empresa.
    const companyInput = document.getElementById('session-company-input');
    if (companyInput) {
      companyInput.addEventListener('keydown', function (e) {
        if (e.key === 'Enter')  { e.preventDefault(); e.stopPropagation(); linaApplySessionCompany(); }
        if (e.key === 'Escape') { e.preventDefault(); e.stopPropagation(); linaCloseCompanyPicker(true); }
      });
    }

    // Atajos de teclado dentro del selector de fecha.
    const dateInput = document.getElementById('session-date-input');
    if (dateInput) {
      dateInput.addEventListener('keydown', function (e) {
        if (e.key === 'Enter')  { e.preventDefault(); e.stopPropagation(); linaApplySessionDate(); }
        if (e.key === 'Escape') { e.preventDefault(); e.stopPropagation(); linaCloseSessionDatePicker(true); }
      });
    }
  });


  /* ── Estilo del botón de fecha según sea hoy o no ── */

  function _hoyLocal() {
    var d = new Date();
    return d.getFullYear() + '-' +
           String(d.getMonth() + 1).padStart(2, '0') + '-' +
           String(d.getDate()).padStart(2, '0');
  }

  function _actualizarEstiloFecha(btn) {
    if (!btn) return;
    var sesion = (btn.dataset.dateIso || '').trim();
    btn.classList.toggle('btn-fecha-otro', sesion !== _hoyLocal());
  }


  /* ── Cierre de paneles al hacer clic fuera ── */

  document.addEventListener('click', function (e) {
    const companyPanel = document.getElementById('session-company-panel');
    const companyBtn   = document.getElementById('btn-empr');
    const datePanel    = document.getElementById('session-date-panel');
    const dateBtn      = document.getElementById('btn-fecha');
    const target       = e.target;

    if (companyPanel && companyBtn && companyPanel.classList.contains('visible')) {
      if (!(target instanceof Node) || (!companyPanel.contains(target) && !companyBtn.contains(target))) {
        linaCloseCompanyPicker(false);
      }
    }
    if (datePanel && dateBtn && datePanel.classList.contains('visible')) {
      if (!(target instanceof Node) || (!datePanel.contains(target) && !dateBtn.contains(target))) {
        linaCloseSessionDatePicker(false);
      }
    }
  });


  /* ── Navegación global por teclado ── */

  document.addEventListener('keydown', function (e) {

    const companyPanel = document.getElementById('session-company-panel');
    const datePanel    = document.getElementById('session-date-panel');

    // Escape con panel de empresa o fecha abierto
    if (e.key === 'Escape' && companyPanel && companyPanel.classList.contains('visible')) {
      e.preventDefault(); linaCloseCompanyPicker(true); return;
    }
    if (e.key === 'Escape' && datePanel && datePanel.classList.contains('visible')) {
      e.preventDefault(); linaCloseSessionDatePicker(true); return;
    }

    // Escape: jerarquía de acciones en el formulario de detalle → cerrar tab activo
    if (e.key === 'Escape') {
      const detailPanel = document.querySelector('.tab-pane.active .md-detail-panel')
                       || document.querySelector('.md-detail-panel');
      if (detailPanel) {
        const undoBtn   = detailPanel.querySelector('[data-action="undo"]');
        const cancelBtn = detailPanel.querySelector('[data-action="cancel"]');
        if (undoBtn && !undoBtn.disabled)   { e.preventDefault(); undoBtn.click(); return; }
        if (cancelBtn && !cancelBtn.disabled) { e.preventDefault(); cancelBtn.click(); return; }
      }
      const tabsRoot = window.linaTabsManager || null;
      if (tabsRoot && tabsRoot.activeTab) { e.preventDefault(); tabsRoot.closeTab(tabsRoot.activeTab); }
      return;
    }

    // Alt+K → hotkeys de menú
    if (e.altKey) {
      const key     = e.key.toLowerCase();
      const element = document.querySelector(`[data-hotkey="${key}"]`);
      if (element) { e.preventDefault(); element.click(); }
    }

    // Ctrl+S → Guardar en formulario de detalle activo
    if (e.ctrlKey && e.key === 's') {
      const detailPanel = document.querySelector('.tab-pane.active .md-detail-panel')
                       || document.querySelector('.md-detail-panel');
      if (detailPanel) {
        const saveBtn = detailPanel.querySelector('button[type="submit"][form="detail-form"]:not([disabled])');
        if (saveBtn && saveBtn.offsetParent !== null) { e.preventDefault(); saveBtn.click(); return; }
      }
    }

    // F2 / F7 / F8 → botones de acción (primer botón visible con data-hotkey="Fx")
    if (e.key === 'F2' || e.key === 'F7' || e.key === 'F8') {
      const btns = document.querySelectorAll(`button[data-hotkey="${e.key}"]:not([disabled])`);
      for (const btn of btns) {
        if (btn.offsetParent !== null) { e.preventDefault(); btn.click(); break; }
      }
    }

    // NumPad + / Enter → avanzar foco; NumPad - → retroceder foco
    const isEnter      = e.key === 'Enter';
    const isNumpadPlus = e.code === 'NumpadAdd';
    const isNumpadMinus = e.code === 'NumpadSubtract';

    if (isNumpadPlus || isNumpadMinus || isEnter) {
      const active = document.activeElement;

      if (isEnter) {
        const isField    = ['INPUT', 'SELECT', 'TEXTAREA'].includes(active.tagName);
        const isButton   = active.tagName === 'BUTTON' || (active.tagName === 'INPUT' && ['button', 'submit', 'reset'].includes(active.type));
        const isReadonly = active.readOnly || active.hasAttribute('readonly');
        if (!isField || isButton || isReadonly) return;
      }

      const focusableSelector = 'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])';
      const focusable = Array.from(document.querySelectorAll(focusableSelector))
        .filter(el => !el.disabled && el.offsetParent !== null && el.getAttribute('tabindex') !== '-1');
      const index = focusable.indexOf(active);

      if (index > -1) {
        e.preventDefault();
        const nextIndex = (isNumpadPlus || isEnter)
          ? (index + 1) % focusable.length
          : (index - 1 + focusable.length) % focusable.length;
        focusable[nextIndex].focus();
        if (focusable[nextIndex].select) focusable[nextIndex].select();
      }
    }
  });


  /* ── Selector de empresa (funciones públicas) ── */

  window.linaToggleCompanyPicker = function (evt) {
    if (evt) { evt.preventDefault(); evt.stopPropagation(); }
    linaCloseSessionDatePicker(false);

    const panel = document.getElementById('session-company-panel');
    const btn   = document.getElementById('btn-empr');
    const input = document.getElementById('session-company-input');
    if (!(panel && btn && input)) return;

    const willOpen = !panel.classList.contains('visible');
    if (willOpen) {
      const mgr = window.linaTabsManager;
      if (mgr && mgr.tabs && mgr.tabs.length > 0) {
        linaAlert('Cierre todas las pestañas antes de cambiar la empresa activa.', 'warn');
        return;
      }
    }
    panel.classList.toggle('visible', willOpen);
    btn.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
    if (willOpen) {
      input.value = btn.dataset.emprCode || input.value || '';
      setTimeout(() => input.focus(), 0);
    }
  };

  window.linaCloseCompanyPicker = function (focusButton) {
    const panel = document.getElementById('session-company-panel');
    const btn   = document.getElementById('btn-empr');
    if (!(panel && btn)) return;
    panel.classList.remove('visible');
    btn.setAttribute('aria-expanded', 'false');
    if (focusButton) setTimeout(() => btn.focus(), 0);
  };

  window.linaApplySessionCompany = async function () {
    const input = document.getElementById('session-company-input');
    const btn   = document.getElementById('btn-empr');
    if (!(input && btn)) return;

    const emprCode = String(input.value || '').trim();
    if (!emprCode) { linaAlert('Debe seleccionar una empresa activa.', 'warn'); input.focus(); return; }

    try {
      const resp    = await fetch('/api/session/company', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ empr_code: emprCode }) });
      const payload = await resp.json().catch(() => ({}));
      if (!resp.ok || !payload.ok) { linaAlert(payload.error || 'No se pudo actualizar la empresa activa.', 'error'); input.focus(); return; }

      btn.textContent       = payload.empr_display || emprCode;
      btn.dataset.emprCode  = payload.empr_code || emprCode;
      btn.dataset.emprName  = payload.empr_name || '';
      input.value           = payload.empr_code || emprCode;
      linaCloseCompanyPicker(true);
    } catch (_err) {
      linaAlert('No se pudo actualizar la empresa activa.', 'error');
    }
  };


  /* ── Selector de fecha de sesión (funciones públicas) ── */

  window.linaToggleSessionDatePicker = function (evt) {
    if (evt) { evt.preventDefault(); evt.stopPropagation(); }
    linaCloseCompanyPicker(false);

    const panel = document.getElementById('session-date-panel');
    const btn   = document.getElementById('btn-fecha');
    const input = document.getElementById('session-date-input');
    if (!(panel && btn && input)) return;

    const willOpen = !panel.classList.contains('visible');
    if (willOpen) {
      const mgr = window.linaTabsManager;
      if (mgr && mgr.tabs && mgr.tabs.length > 0) {
        linaAlert('Cierre todas las pestañas antes de cambiar la fecha de sesión.', 'warn');
        return;
      }
    }
    panel.classList.toggle('visible', willOpen);
    btn.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
    if (willOpen) {
      input.value = btn.dataset.dateIso || input.value || '';
      setTimeout(() => {
        input.focus();
        try { if (typeof input.showPicker === 'function') input.showPicker(); } catch (_err) { /* navegador no lo soporta */ }
      }, 0);
    }
  };

  window.linaCloseSessionDatePicker = function (focusButton) {
    const panel = document.getElementById('session-date-panel');
    const btn   = document.getElementById('btn-fecha');
    if (!(panel && btn)) return;
    panel.classList.remove('visible');
    btn.setAttribute('aria-expanded', 'false');
    if (focusButton) setTimeout(() => btn.focus(), 0);
  };

  window.linaApplySessionDate = async function () {
    const input = document.getElementById('session-date-input');
    const btn   = document.getElementById('btn-fecha');
    if (!(input && btn)) return;

    const sessionDate = String(input.value || '').trim();
    if (!sessionDate) { linaAlert('Debe seleccionar una fecha de sesión.', 'warn'); input.focus(); return; }

    try {
      const resp    = await fetch('/api/session/date', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ session_date: sessionDate }) });
      const payload = await resp.json().catch(() => ({}));
      if (!resp.ok || !payload.ok) { linaAlert(payload.error || 'No se pudo actualizar la fecha de sesión.', 'error'); input.focus(); return; }

      btn.textContent      = payload.session_date_display || sessionDate;
      btn.dataset.dateIso  = payload.session_date || sessionDate;
      input.value          = payload.session_date || sessionDate;
      _actualizarEstiloFecha(btn);
      linaCloseSessionDatePicker(true);
    } catch (_err) {
      linaAlert('No se pudo actualizar la fecha de sesión.', 'error');
    }
  };

})();
