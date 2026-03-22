    // Inicializar popovers y eventos de contexto en navbar
    document.addEventListener('DOMContentLoaded', function() {
      document.querySelectorAll('[data-bs-toggle="popover"]').forEach(function(el) {
        new bootstrap.Popover(el, { trigger: 'focus', html: false });
      });

      const companyInput = document.getElementById('session-company-input');
      if (companyInput) {
        companyInput.addEventListener('keydown', function(e) {
          if (e.key === 'Enter') {
            e.preventDefault();
            e.stopPropagation();
            linaApplySessionCompany();
          }
          if (e.key === 'Escape') {
            e.preventDefault();
            e.stopPropagation();
            linaCloseCompanyPicker(true);
          }
        });
      }

      const dateInput = document.getElementById('session-date-input');
      if (dateInput) {
        dateInput.addEventListener('keydown', function(e) {
          if (e.key === 'Enter') {
            e.preventDefault();
            e.stopPropagation();
            linaApplySessionDate();
          }
          if (e.key === 'Escape') {
            e.preventDefault();
            e.stopPropagation();
            linaCloseSessionDatePicker(true);
          }
        });
      }
    });

    function linaToggleCompanyPicker(evt) {
      if (evt) {
        evt.preventDefault();
        evt.stopPropagation();
      }
      linaCloseSessionDatePicker(false);

      const panel = document.getElementById('session-company-panel');
      const btn = document.getElementById('btn-empr');
      const input = document.getElementById('session-company-input');
      if (!(panel && btn && input)) return;

      const willOpen = !panel.classList.contains('visible');
      panel.classList.toggle('visible', willOpen);
      btn.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
      input.value = btn.dataset.emprCode || input.value || '';

      if (willOpen) {
        setTimeout(function() {
          input.focus();
        }, 0);
      }
    }

    function linaCloseCompanyPicker(focusButton) {
      const panel = document.getElementById('session-company-panel');
      const btn = document.getElementById('btn-empr');
      if (!(panel && btn)) return;
      panel.classList.remove('visible');
      btn.setAttribute('aria-expanded', 'false');
      if (focusButton) {
        setTimeout(function() {
          btn.focus();
        }, 0);
      }
    }

    async function linaApplySessionCompany() {
      const input = document.getElementById('session-company-input');
      const btn = document.getElementById('btn-empr');
      if (!(input && btn)) return;

      const emprCode = String(input.value || '').trim();
      if (!emprCode) {
        linaAlert('Debe seleccionar una empresa activa.', 'warn');
        input.focus();
        return;
      }

      try {
        const resp = await fetch('/api/session/company', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ empr_code: emprCode })
        });
        const payload = await resp.json().catch(function() { return {}; });
        if (!resp.ok || !payload.ok) {
          linaAlert(payload.error || 'No se pudo actualizar la empresa activa.', 'error');
          input.focus();
          return;
        }

        btn.textContent = payload.empr_display || emprCode;
        btn.dataset.emprCode = payload.empr_code || emprCode;
        btn.dataset.emprName = payload.empr_name || '';
        input.value = payload.empr_code || emprCode;
        linaCloseCompanyPicker(true);
      } catch (_err) {
        linaAlert('No se pudo actualizar la empresa activa.', 'error');
      }
    }

    function linaToggleSessionDatePicker(evt) {
      if (evt) {
        evt.preventDefault();
        evt.stopPropagation();
      }
      linaCloseCompanyPicker(false);
      const panel = document.getElementById('session-date-panel');
      const btn = document.getElementById('btn-fecha');
      const input = document.getElementById('session-date-input');
      if (!(panel && btn && input)) return;

      const willOpen = !panel.classList.contains('visible');
      panel.classList.toggle('visible', willOpen);
      btn.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
      input.value = btn.dataset.dateIso || input.value || '';

      if (willOpen) {
        setTimeout(function() {
          input.focus();
          if (typeof input.showPicker === 'function') {
            try {
              input.showPicker();
            } catch (_err) {
              // No-op: algunos navegadores restringen showPicker.
            }
          }
        }, 0);
      }
    }

    function linaCloseSessionDatePicker(focusButton) {
      const panel = document.getElementById('session-date-panel');
      const btn = document.getElementById('btn-fecha');
      if (!(panel && btn)) return;
      panel.classList.remove('visible');
      btn.setAttribute('aria-expanded', 'false');
      if (focusButton) {
        setTimeout(function() {
          btn.focus();
        }, 0);
      }
    }

    async function linaApplySessionDate() {
      const input = document.getElementById('session-date-input');
      const btn = document.getElementById('btn-fecha');
      if (!(input && btn)) return;

      const sessionDate = String(input.value || '').trim();
      if (!sessionDate) {
        linaAlert('Debe seleccionar una fecha de sesión.', 'warn');
        input.focus();
        return;
      }

      try {
        const resp = await fetch('/api/session/date', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ session_date: sessionDate })
        });
        const payload = await resp.json().catch(function() { return {}; });
        if (!resp.ok || !payload.ok) {
          linaAlert(payload.error || 'No se pudo actualizar la fecha de sesión.', 'error');
          input.focus();
          return;
        }

        btn.textContent = payload.session_date_display || sessionDate;
        btn.dataset.dateIso = payload.session_date || sessionDate;
        input.value = payload.session_date || sessionDate;
        linaCloseSessionDatePicker(true);
      } catch (_err) {
        linaAlert('No se pudo actualizar la fecha de sesión.', 'error');
      }
    }

    document.addEventListener('click', function(e) {
      const companyPanel = document.getElementById('session-company-panel');
      const companyBtn = document.getElementById('btn-empr');
      const panel = document.getElementById('session-date-panel');
      const btn = document.getElementById('btn-fecha');
      const target = e.target;
      if (companyPanel && companyBtn && companyPanel.classList.contains('visible')) {
        if (!(target instanceof Node) || (!companyPanel.contains(target) && !companyBtn.contains(target))) {
          linaCloseCompanyPicker(false);
        }
      }
      if (panel && btn && panel.classList.contains('visible')) {
        if (!(target instanceof Node) || (!panel.contains(target) && !btn.contains(target))) {
          linaCloseSessionDatePicker(false);
        }
      }
    });

    document.addEventListener('keydown', function(e) {
      // 0. F2 → Empresa activa, F3 → Fecha de sesión
      if (e.key === 'F2') {
        e.preventDefault();
        linaToggleCompanyPicker();
        return;
      }
      if (e.key === 'F3') {
        e.preventDefault();
        linaToggleSessionDatePicker();
        return;
      }

      const companyPanel = document.getElementById('session-company-panel');
      const panel = document.getElementById('session-date-panel');
      if (e.key === 'Escape' && companyPanel && companyPanel.classList.contains('visible')) {
        e.preventDefault();
        linaCloseCompanyPicker(true);
        return;
      }
      if (e.key === 'Escape' && panel && panel.classList.contains('visible')) {
        e.preventDefault();
        linaCloseSessionDatePicker(true);
        return;
      }

      // 1. Escape: jerarquía de acciones.
      //    a) Si el detalle tiene undo habilitado  → undo
      //    b) Si el detalle tiene cancel            → cancel
      //    c) En cualquier otro caso               → cerrar tab activo
      if (e.key === 'Escape') {
        const detailPanel = document.querySelector('.tab-pane.active .md-detail-panel')
                         || document.querySelector('.md-detail-panel');
        if (detailPanel) {
          const undoBtn = detailPanel.querySelector('[data-action="undo"]');
          const cancelBtn = detailPanel.querySelector('[data-action="cancel"]');
          if (undoBtn && !undoBtn.disabled) {
            e.preventDefault();
            undoBtn.click();
            return;
          }
          if (cancelBtn && !cancelBtn.disabled) {
            e.preventDefault();
            cancelBtn.click();
            return;
          }
        }
        // Sin acción disponible en el formulario → cerrar tab activo
        const tabsRoot = window.linaTabsManager || null;
        if (tabsRoot && tabsRoot.activeTab) {
          e.preventDefault();
          tabsRoot.closeTab(tabsRoot.activeTab);
        }
        return;
      }

      // 2. Hotkeys Alt+K
      if (e.altKey) {
        const key = e.key.toLowerCase();
        const element = document.querySelector(`[data-hotkey="${key}"]`);
        if (element) {
          e.preventDefault();
          element.click();
        }
      }

      // 3. Navegación con Pad Numérico (+ y -) y Enter
      // NumpadAdd (+) o Enter -> Tab, NumpadSubtract (-) -> Shift+Tab
      const isEnter = e.key === 'Enter';
      const isNumpadPlus = e.code === 'NumpadAdd';
      const isNumpadMinus = e.code === 'NumpadSubtract';

      if (isNumpadPlus || isNumpadMinus || isEnter) {
        const active = document.activeElement;

        // Si es Enter, solo navegar si es un campo de edición (input, select, textarea) 
        // y NO es un botón ni es de solo lectura (readonly)
        if (isEnter) {
          const isField = ['INPUT', 'SELECT', 'TEXTAREA'].includes(active.tagName);
          const isButton = active.tagName === 'BUTTON' || (active.tagName === 'INPUT' && ['button', 'submit', 'reset'].includes(active.type));
          const isReadonly = active.readOnly || active.hasAttribute('readonly');
          
          if (!isField || isButton || isReadonly) return;
        }

        const focusableElements = 'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])';
        const focusable = Array.from(document.querySelectorAll(focusableElements)).filter(el => !el.disabled && el.offsetParent !== null);
        const index = focusable.indexOf(active);

        if (index > -1) {
            e.preventDefault();
            let nextIndex;
            if (isNumpadPlus || isEnter) {
                nextIndex = (index + 1) % focusable.length;
            } else {
                nextIndex = (index - 1 + focusable.length) % focusable.length;
            }
            focusable[nextIndex].focus();
            if (focusable[nextIndex].select) focusable[nextIndex].select();
        }
      }
    });

    // 4. Foco automático al cargar detalle (HTMX)
    document.addEventListener('htmx:afterSettle', function(evt) {
      const target = evt.detail && evt.detail.target ? evt.detail.target : null;
      if (!target) return;

      // Soporta paneles de detalle con IDs dinámicos por pestaña.
      const detailRoot = target.matches('.md-detail-panel')
        ? target
        : target.closest('.md-detail-panel');

      if (!detailRoot) return;

      const firstInput = detailRoot.querySelector('input:not([readonly]):not([type="hidden"]), select:not([readonly]), textarea:not([readonly])');
      if (firstInput) {
        firstInput.focus();
        if (firstInput.select) firstInput.select();
      }
    });

