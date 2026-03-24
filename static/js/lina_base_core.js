const _linaViewportCfgEl = document.getElementById('lina-min-viewport-config');
let LINA_MIN_VIEWPORT_CONFIG = {};
if (_linaViewportCfgEl) {
  try {
    LINA_MIN_VIEWPORT_CONFIG = JSON.parse(_linaViewportCfgEl.textContent || '{}');
  } catch (_e) {
    LINA_MIN_VIEWPORT_CONFIG = {};
  }
}

    function tabsManager() {
      return {
        tabs: [],
        activeTab: null,
        tabCounter: 0,
        bypassDetailGuardTabId: null,

        init() {
          window.linaTabsManager = this;
          this.checkViewportConstraints();
          window.addEventListener('resize', () => this.checkViewportConstraints());
        },

        getRequiredViewport() {
          const defaultReq = (LINA_MIN_VIEWPORT_CONFIG && LINA_MIN_VIEWPORT_CONFIG.default) || { width: 1120, height: 620 };
          const active = this.tabs.find(t => t.id === this.activeTab) || null;
          const code = active && active.code ? String(active.code).trim().toUpperCase() : '';
          const map = (LINA_MIN_VIEWPORT_CONFIG && LINA_MIN_VIEWPORT_CONFIG.programs) || {};
          return map[code] || defaultReq;
        },

        checkViewportConstraints() {
          const warn = document.getElementById('lina-viewport-warn');
          if (!warn) return;

          const req = this.getRequiredViewport();
          const currW = window.innerWidth || 0;
          const currH = window.innerHeight || 0;
          const ok = currW >= req.width && currH >= req.height;

          if (ok) {
            warn.classList.remove('visible');
            warn.textContent = '';
            return;
          }

          warn.textContent = `Tamano de ventana insuficiente. Minimo recomendado: ${req.width}x${req.height}. Actual: ${currW}x${currH}.`;
          warn.classList.add('visible');
        },

        serializeForm(form) {
          return JSON.stringify(Array.from(new FormData(form).entries()));
        },

        registerDirtyTrackers(pane) {
          if (!pane) return;
          const tabPane = pane.closest('.tab-pane') || pane;
          const tabId = tabPane.id && tabPane.id.startsWith('pane-') ? tabPane.id.replace('pane-', '') : null;
          const forms = pane.querySelectorAll('form');
          forms.forEach(form => {
            if (!form.dataset.trackedDirty) {
              form.dataset.initialState = this.serializeForm(form);
              form.dataset.trackedDirty = '1';
              const markDirty = () => {
                if (tabId) this.refreshTabDirtyFromPane(tabId);
              };
              form.addEventListener('input', markDirty);
              form.addEventListener('change', markDirty);
            }
          });
          if (tabId) this.refreshTabDirtyFromPane(tabId);
        },

        isPaneDirty(pane) {
          if (!pane) return false;
          const forms = pane.querySelectorAll('form');
          for (const form of forms) {
            if (!form.dataset.initialState) {
              form.dataset.initialState = this.serializeForm(form);
            }
            const initial = form.dataset.initialState || '[]';
            if (this.serializeForm(form) !== initial) return true;
          }
          return false;
        },

        refreshTabDirtyFromPane(tabId) {
          const tab = this.tabs.find(t => t.id === tabId);
          if (!tab) return;
          const pane = document.getElementById('pane-' + tabId);
          tab.dirty = this.isPaneDirty(pane);
          this.tabs = [...this.tabs];
        },

        anyTabDirty() {
          this.tabs.forEach(t => this.refreshTabDirtyFromPane(t.id));
          return this.tabs.some(t => !!t.dirty);
        },

        shouldGuardDetailNavigation(evt) {
          const detail = evt && evt.detail ? evt.detail : null;
          const elt = detail && detail.elt ? detail.elt : null;
          if (!elt) return { guard: false, tabId: null };

          const pane = elt.closest('.tab-pane');
          if (!pane || !pane.id || !pane.id.startsWith('pane-')) {
            return { guard: false, tabId: null };
          }
          const tabId = pane.id.substring(5);

          if (this.bypassDetailGuardTabId === tabId) {
            this.bypassDetailGuardTabId = null;
            return { guard: false, tabId };
          }

          const method = ((detail.verb || detail.requestConfig?.verb || 'GET') + '').toUpperCase();
          const isGet = method === 'GET';
          const isDetailNavTrigger = elt.classList?.contains('detail-nav-trigger') || elt.classList?.contains('grid-row');

          return { guard: isGet && isDetailNavTrigger, tabId };
        },

        async notifyTabOpen(tab) {
          try {
            await fetch('/api/tabs/open', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ tabId: tab.id, progCode: tab.code, readonly: !!tab.readonly })
            });
          } catch (_e) {
            console.warn('No se pudo registrar apertura de tab en servidor');
          }
        },

        async notifyTabWrite(tabId) {
          const tab = this.tabs.find(t => t.id === tabId);
          if (!tab || tab.readonly === false) return;
          tab.readonly = false;
          try {
            await fetch('/api/tabs/mark-write', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ tabId })
            });
          } catch (_e) {
            console.warn('No se pudo actualizar estado write del tab en servidor');
          }
        },

        async finalizeTabClose(tabId, commit) {
          const idx = this.tabs.findIndex(t => t.id === tabId);
          if (idx < 0) return;
          try {
            await fetch('/api/tabs/close', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ tabId, commit: !!commit })
            });
          } catch (_e) {
            console.warn('No se pudo cerrar conexión de tab en servidor');
          }
          this.tabs.splice(idx, 1);
          if (this.activeTab === tabId) {
            this.activeTab = this.tabs.length > 0 ? this.tabs[this.tabs.length - 1].id : null;
          }
        },

        askDirtyDecision() {
          const modalEl = document.getElementById('dirtyCloseModal');
          if (!modalEl || !window.bootstrap) return Promise.resolve('cancel');
          const modal = bootstrap.Modal.getOrCreateInstance(modalEl, { backdrop: 'static', keyboard: false });
          return new Promise(resolve => {
            let resolved = false;
            const done = (choice) => {
              if (resolved) return;
              resolved = true;
              cleanup();
              modal.hide();
              resolve(choice);
            };
            const btnSave = document.getElementById('btnDirtySave');
            const btnDiscard = document.getElementById('btnDirtyDiscard');
            const btnCancel = document.getElementById('btnDirtyCancel');
            const onSave = () => done('save');
            const onDiscard = () => done('discard');
            const onCancel = () => done('cancel');
            const onHidden = () => done('cancel');
            const cleanup = () => {
              btnSave && btnSave.removeEventListener('click', onSave);
              btnDiscard && btnDiscard.removeEventListener('click', onDiscard);
              btnCancel && btnCancel.removeEventListener('click', onCancel);
              modalEl.removeEventListener('hidden.bs.modal', onHidden);
            };
            btnSave && btnSave.addEventListener('click', onSave);
            btnDiscard && btnDiscard.addEventListener('click', onDiscard);
            btnCancel && btnCancel.addEventListener('click', onCancel);
            modalEl.addEventListener('hidden.bs.modal', onHidden);
            modal.show();
          });
        },

        async saveTabForms(tabId) {
          const pane = document.getElementById('pane-' + tabId);
          if (!pane) return true;
          const dirtyForms = Array.from(pane.querySelectorAll('form')).filter(f => {
            if (!f.dataset.initialState) {
              f.dataset.initialState = this.serializeForm(f);
            }
            const initial = f.dataset.initialState || '[]';
            return this.serializeForm(f) !== initial;
          });
          for (const form of dirtyForms) {
            if (window.htmx) {
              htmx.trigger(form, 'submit');
            } else {
              form.requestSubmit();
            }
            await new Promise(r => setTimeout(r, 250));
            form.dataset.initialState = this.serializeForm(form);
          }
          this.refreshTabDirtyFromPane(tabId);
          return true;
        },

        openTab(progCode, progTitle, url) {
          const tabId = `tab_${progCode}_${++this.tabCounter}`;
          const tabExists = this.tabs.find(t => t.url === url);

          if (tabExists) {
            this.activateTab(tabExists.id);
            return;
          }

          this.tabs.push({
            id: tabId,
            code: progCode,
            title: progTitle,
            url: url,
            readonly: true,
            dirty: false
          });

          this.activeTab = tabId;
          this.checkViewportConstraints();

          const tab = this.tabs.find(t => t.id === tabId);
          if (tab) this.notifyTabOpen(tab);

          const sep = url.includes('?') ? '&' : '?';
          fetch(`${url}${sep}_tab=${encodeURIComponent(tabId)}`, {
            method: 'GET',
            headers: {
              'HX-Request': 'true',
              'X-Tab-Id': tabId
            }
          })
          .then(resp => resp.text())
          .then(html => {
            const paneElement = document.getElementById('pane-' + tabId);
            if (!paneElement) return;
            paneElement.innerHTML = html;
            // innerHTML no ejecuta scripts: re-crearlos para que corran.
            // Se omiten scripts con type no ejecutable (ej. application/json)
            // para evitar errores de sintaxis y para que conserven su id en el DOM.
            paneElement.querySelectorAll('script').forEach(function(oldScript) {
              var type = (oldScript.type || '').trim().toLowerCase();
              var executable = !type || type === 'text/javascript' || type === 'module' || type === 'application/javascript';
              if (!executable) return;
              var newScript = document.createElement('script');
              newScript.textContent = oldScript.textContent;
              oldScript.parentNode.replaceChild(newScript, oldScript);
            });
            try {
              if (window.Alpine) Alpine.initTree(paneElement);
            } catch (err) {
              console.error('Error inicializando Alpine en tab', tabId, err);
            }
            try {
              if (window.htmx) htmx.process(paneElement);
            } catch (err) {
              console.error('Error procesando HTMX en tab', tabId, err);
            }
            this.registerDirtyTrackers(paneElement);
          })
          .catch(err => {
            console.error('Error cargando tab:', err);
            document.getElementById('pane-' + tabId).innerHTML = '<div class="alert alert-danger">Error cargando contenido</div>';
          });
        },

        activateTab(tabId) {
          this.activeTab = tabId;
          this.checkViewportConstraints();
        },

        async closeTab(tabId) {
          const tab = this.tabs.find(t => t.id === tabId);
          if (!tab) return;

          this.refreshTabDirtyFromPane(tabId);
          if (tab.dirty) {
            const choice = await this.askDirtyDecision();
            if (choice === 'cancel') return;
            if (choice === 'save') {
              await this.notifyTabWrite(tabId);
              const saved = await this.saveTabForms(tabId);
              if (!saved) return;
              await this.finalizeTabClose(tabId, true);
              return;
            }
            await this.finalizeTabClose(tabId, false);
            return;
          }
          await this.finalizeTabClose(tabId, tab.readonly === false);
          this.checkViewportConstraints();
        },

        onTabLoad(event) {}
      };
    }

    document.addEventListener('htmx:afterSwap', function(evt) {
      htmx.process(evt.detail.target);
      if (window.Alpine) Alpine.initTree(evt.detail.target);
      const tabsRoot = window.linaTabsManager || null;
      const pane = evt.detail.target.closest('.tab-pane') || evt.detail.target;
      if (tabsRoot && typeof tabsRoot.registerDirtyTrackers === 'function') {
        tabsRoot.registerDirtyTrackers(pane.closest('.tab-pane') || pane);
      }
    });

    document.addEventListener('htmx:configRequest', function(evt) {
      const elt = evt.detail && evt.detail.elt ? evt.detail.elt : null;
      if (!elt) return;
      const pane = elt.closest('.tab-pane');
      if (!pane || !pane.id || !pane.id.startsWith('pane-')) return;
      const tabId = pane.id.substring(5);
      evt.detail.parameters = evt.detail.parameters || {};
      evt.detail.parameters._tab = tabId;
      evt.detail.headers = evt.detail.headers || {};
      evt.detail.headers['X-Tab-Id'] = tabId;

      const method = (evt.detail.verb || '').toUpperCase();
      if (method && method !== 'GET') {
        const tabsRoot = window.linaTabsManager || null;
        if (tabsRoot && typeof tabsRoot.notifyTabWrite === 'function') {
          tabsRoot.notifyTabWrite(tabId);
        }
      }
    });

    document.addEventListener('htmx:beforeRequest', function(evt) {
      const tabsRoot = window.linaTabsManager || null;
      if (!tabsRoot || typeof tabsRoot.shouldGuardDetailNavigation !== 'function') return;

      const guardInfo = tabsRoot.shouldGuardDetailNavigation(evt);
      if (!guardInfo.guard || !guardInfo.tabId) return;

      tabsRoot.refreshTabDirtyFromPane(guardInfo.tabId);
      const tab = tabsRoot.tabs.find(t => t.id === guardInfo.tabId);
      if (!tab || !tab.dirty) return;

      evt.preventDefault();
      const triggerEl = evt.detail && evt.detail.elt ? evt.detail.elt : null;
      if (!triggerEl) return;

      (async () => {
        const choice = await tabsRoot.askDirtyDecision();
        if (choice === 'cancel') return;
        if (choice === 'save') {
          await tabsRoot.notifyTabWrite(guardInfo.tabId);
          const saved = await tabsRoot.saveTabForms(guardInfo.tabId);
          if (!saved) return;
        }
        tabsRoot.bypassDetailGuardTabId = guardInfo.tabId;
        if (typeof triggerEl.click === 'function') {
          triggerEl.click();
        } else if (window.htmx) {
          htmx.trigger(triggerEl, 'click');
        }
      })();
    });

    document.addEventListener('htmx:afterRequest', function(evt) {
      const successful = !!(evt.detail && evt.detail.successful);
      if (!successful) return;

      const elt = evt.detail && evt.detail.elt ? evt.detail.elt : null;
      if (!elt || elt.tagName !== 'FORM') return;

      if (!elt.dataset.initialState) {
        elt.dataset.trackedDirty = '1';
      }
      elt.dataset.initialState = JSON.stringify(Array.from(new FormData(elt).entries()));

      const pane = elt.closest('.tab-pane');
      if (!pane || !pane.id || !pane.id.startsWith('pane-')) return;
      const tabId = pane.id.substring(5);
      const tabsRoot = window.linaTabsManager || null;
      if (tabsRoot && typeof tabsRoot.refreshTabDirtyFromPane === 'function') {
        tabsRoot.refreshTabDirtyFromPane(tabId);
        const tab = tabsRoot.tabs.find(t => t.id === tabId);
        if (tab) {
          tab.dirty = false;
          tab.readonly = true;
          tabsRoot.tabs = [...tabsRoot.tabs];
        }
      }
    });

    document.addEventListener('click', function(evt) {
      const actionBtn = evt.target && evt.target.closest
        ? evt.target.closest('[data-action="undo"], [data-action="cancel"]')
        : null;
      if (!actionBtn) return;

      const pane = actionBtn.closest('.tab-pane');
      if (!pane || !pane.id || !pane.id.startsWith('pane-')) return;
      const tabId = pane.id.substring(5);

      setTimeout(function() {
        const tabsRoot = window.linaTabsManager || null;
        if (!tabsRoot || typeof tabsRoot.refreshTabDirtyFromPane !== 'function') return;
        tabsRoot.refreshTabDirtyFromPane(tabId);
        const tab = tabsRoot.tabs.find(t => t.id === tabId);
        if (tab && !tab.dirty) {
          tab.readonly = true;
          tabsRoot.tabs = [...tabsRoot.tabs];
        }
      }, 30);
    });

    const _LINA_MSG_ICONS = { info: 'ℹ️', warn: '⚠️', error: '🚫' };
    const _LINA_MSG_LEVELS = { info: 'Información', warn: 'Advertencia', error: 'Error' };
    let _linaLastMsg = null;

    function linaShowMsg(text, level, extra) {
      level = (level || 'info').toLowerCase();
      if (!_LINA_MSG_ICONS[level]) level = 'info';
      const bar   = document.getElementById('lina-msgbar');
      const icon  = document.getElementById('lina-msgbar-icon');
      const txt   = document.getElementById('lina-msgbar-text');
      const ack   = document.getElementById('lina-msgbar-ack');
      if (!bar) return;

      const now = new Date();
      const tab = window.linaTabsManager
        ? (window.linaTabsManager.tabs.find(t => t.id === window.linaTabsManager.activeTab) || null)
        : null;

      _linaLastMsg = {
        text,
        level,
        levelLabel: _LINA_MSG_LEVELS[level],
        icon: _LINA_MSG_ICONS[level],
        tab: tab ? tab.title : '—',
        tabId: tab ? tab.id : null,
        extra: extra || '',
        fecha: now.toLocaleDateString('es-AR'),
        hora: now.toLocaleTimeString('es-AR'),
      };

      bar.className = 'lina-msgbar lv-' + level;
      icon.textContent = _LINA_MSG_ICONS[level];
      icon.title = _LINA_MSG_LEVELS[level];
      icon.classList.add('visible');
      txt.textContent = text;
      txt.classList.add('has-msg');
      ack.classList.add('visible');
    }

    function linaAckMsg() {
      const bar  = document.getElementById('lina-msgbar');
      const icon = document.getElementById('lina-msgbar-icon');
      const txt  = document.getElementById('lina-msgbar-text');
      const ack  = document.getElementById('lina-msgbar-ack');
      if (!bar) return;
      bar.className = 'lina-msgbar';
      icon.textContent = '';
      icon.classList.remove('visible');
      txt.textContent = '';
      txt.classList.remove('has-msg');
      ack.classList.remove('visible');
      _linaLastMsg = null;
    }

    function linaOpenMsgDetail() {
      if (!_linaLastMsg) return;
      const m = _linaLastMsg;
      const body = [
        `Nivel:    ${m.levelLabel}`,
        `Mensaje:  ${m.text}`,
        `Pestaña:  ${m.tab}`,
        `Fecha:    ${m.fecha}  ${m.hora}`,
        m.extra ? `Detalle:\n${m.extra}` : ''
      ].filter(Boolean).join('\n');

      const modalEl = document.getElementById('linaMsgDetailModal');
      const okEl = document.getElementById('linaMsgDetailOk');
      if (modalEl && window.bootstrap) {
        document.getElementById('linaMsgDetailBody').textContent = body;
        const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        const onShown = () => {
          setTimeout(() => { if (okEl) okEl.focus(); }, 0);
          modalEl.removeEventListener('shown.bs.modal', onShown);
        };
        modalEl.addEventListener('shown.bs.modal', onShown);
        modal.show();
      } else {
        linaAlert(body, m.level || 'info');
      }
    }

    function linaAlert(message, level) {
      const lvl = (level || 'info').toLowerCase();
      const titleMap = { info: 'LINA - Informacion', warn: 'LINA - Advertencia', error: 'LINA - Error' };
      const modalEl = document.getElementById('linaAlertModal');
      const titleEl = document.getElementById('linaAlertTitle');
      const bodyEl  = document.getElementById('linaAlertBody');
      const okEl    = document.getElementById('linaAlertOk');
      const title   = titleMap[lvl] || titleMap.info;
      if (modalEl && titleEl && bodyEl && okEl && window.bootstrap) {
        titleEl.textContent = title;
        bodyEl.textContent  = message || '';
        const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        const onShown = () => { setTimeout(() => okEl.focus(), 0); modalEl.removeEventListener('shown.bs.modal', onShown); };
        modalEl.addEventListener('shown.bs.modal', onShown);
        modal.show();
        return;
      }
      alert((title || 'LINA') + '\n\n' + (message || ''));
    }

    function linaConfirm(message, level) {
      const lvl = (level || 'warn').toLowerCase();
      const titleMap = { info: 'LINA - Informacion', warn: 'LINA - Advertencia', error: 'LINA - Error' };
      const modalEl = document.getElementById('linaConfirmModal');
      const titleEl = document.getElementById('linaConfirmTitle');
      const bodyEl  = document.getElementById('linaConfirmBody');
      const yesEl   = document.getElementById('linaConfirmYes');
      const noEl    = document.getElementById('linaConfirmNo');
      const title   = titleMap[lvl] || titleMap.warn;

      if (!(modalEl && titleEl && bodyEl && yesEl && noEl && window.bootstrap)) {
        return Promise.resolve(window.confirm(message || 'Confirma la operacion?'));
      }

      titleEl.textContent = title;
      bodyEl.textContent  = message || '';
      const modal = bootstrap.Modal.getOrCreateInstance(modalEl, { backdrop: 'static', keyboard: true });

      return new Promise(resolve => {
        let resolved = false;
        const done = (result) => {
          if (resolved) return;
          resolved = true;
          cleanup();
          modal.hide();
          resolve(result);
        };
        const onYes    = () => done(true);
        const onNo     = () => done(false);
        const onHidden = () => done(false);
        const onShown  = () => setTimeout(() => yesEl.focus(), 0);
        const cleanup  = () => {
          yesEl.removeEventListener('click', onYes);
          noEl.removeEventListener('click', onNo);
          modalEl.removeEventListener('hidden.bs.modal', onHidden);
          modalEl.removeEventListener('shown.bs.modal', onShown);
        };
        yesEl.addEventListener('click', onYes);
        noEl.addEventListener('click', onNo);
        modalEl.addEventListener('hidden.bs.modal', onHidden);
        modalEl.addEventListener('shown.bs.modal', onShown);
        modal.show();
      });
    }

    function linaPrompt(message, defaultValue, options) {
      const opts      = options || {};
      const title     = String(opts.title || 'LINA - Ingreso');
      const normalize = typeof opts.normalize === 'function' ? opts.normalize : (v => v);
      const validate  = typeof opts.validate  === 'function' ? opts.validate  : null;

      const modalEl  = document.getElementById('linaInputModal');
      const titleEl  = document.getElementById('linaInputTitle');
      const bodyEl   = document.getElementById('linaInputBody');
      const inputEl  = document.getElementById('linaInputValue');
      const errorEl  = document.getElementById('linaInputError');
      const okEl     = document.getElementById('linaInputOk');
      const cancelEl = document.getElementById('linaInputCancel');

      if (!(modalEl && titleEl && bodyEl && inputEl && errorEl && okEl && cancelEl && window.bootstrap)) {
        linaAlert('No se pudo abrir la ventana de ingreso de datos.', 'error');
        return Promise.resolve(null);
      }

      titleEl.textContent   = title;
      bodyEl.textContent    = String(message || '');
      inputEl.value         = String(defaultValue || '');
      errorEl.style.display = 'none';
      errorEl.textContent   = '';

      const modal = bootstrap.Modal.getOrCreateInstance(modalEl, { backdrop: 'static', keyboard: true });
      return new Promise(resolve => {
        let resolved = false;
        const done = (result) => {
          if (resolved) return;
          resolved = true;
          cleanup();
          modal.hide();
          resolve(result);
        };
        const onOk = () => {
          const value = normalize(String(inputEl.value || ''));
          if (validate) {
            const err = validate(value);
            if (err) { errorEl.textContent = err; errorEl.style.display = ''; setTimeout(() => inputEl.focus(), 0); return; }
          }
          done(value);
        };
        const onCancel  = () => done(null);
        const onHidden  = () => done(null);
        const onShown   = () => setTimeout(() => { inputEl.focus(); if (inputEl.select) inputEl.select(); }, 0);
        const onKeydown = (e) => { if (e.key === 'Enter') { e.preventDefault(); onOk(); } };
        const cleanup   = () => {
          okEl.removeEventListener('click', onOk);
          cancelEl.removeEventListener('click', onCancel);
          modalEl.removeEventListener('hidden.bs.modal', onHidden);
          modalEl.removeEventListener('shown.bs.modal', onShown);
          inputEl.removeEventListener('keydown', onKeydown);
        };
        okEl.addEventListener('click', onOk);
        cancelEl.addEventListener('click', onCancel);
        modalEl.addEventListener('hidden.bs.modal', onHidden);
        modalEl.addEventListener('shown.bs.modal', onShown);
        inputEl.addEventListener('keydown', onKeydown);
        modal.show();
      });
    }

    async function linaPromptCodeChange(entityLabel, currentCode, label, options) {
      const opts        = options || {};
      const upper       = !!opts.uppercase;
      const safeCurrent = String(currentCode || '').trim();
      const safeLabel   = String(label || '').trim();
      const caption     = safeLabel
        ? `Nuevo codigo para ${entityLabel} (${safeCurrent} - ${safeLabel}):`
        : `Nuevo codigo para ${entityLabel} (${safeCurrent}):`;
      return linaPrompt(caption, safeCurrent, {
        title: 'LINA - Cambiar codigo',
        normalize: (v) => { let out = String(v || '').trim(); if (upper) out = out.toUpperCase(); return out; },
        validate:  (v) => {
          const compareCurrent = upper ? safeCurrent.toUpperCase() : safeCurrent;
          if (!v || v === compareCurrent) return 'Debe ingresar un codigo nuevo valido.';
          return '';
        },
      });
    }

    function linaShowRecodeReject(message) {
      linaAlert('Solicitud rechazada: ' + (message || 'No se pudo cambiar el codigo.'), 'error');
    }

    function linaCreateMasterDetailFormModel(config) {
      const cfg           = config || {};
      const codeField     = cfg.codeField;
      const labelField    = cfg.labelField;
      const entityLabel   = cfg.entityLabel   || 'el registro';
      const recodeUrlBase = cfg.recodeUrlBase || '';
      const detailUrlBase = cfg.detailUrlBase || '';
      const codeUppercase = !!cfg.codeUppercase;
      const maxCodeLength = cfg.maxCodeLength  || 0;
      const codeMin       = (cfg.codeMin != null) ? Number(cfg.codeMin) : null;
      const codeMax       = (cfg.codeMax != null) ? Number(cfg.codeMax) : null;

      const cleanCode = (value, upper) => { let text = String(value || '').trim(); if (upper) text = text.toUpperCase(); return text; };
      const clone     = (obj) => ({ ...(obj || {}) });

      return {
        original: clone(cfg.original),
        current:  clone(cfg.current),
        recodeModal:   null,
        recodeNewCode: '',
        recodeConfirm: false,
        recodeError:   '',

        isDirty() { return JSON.stringify(this.original) !== JSON.stringify(this.current); },
        reset()   { this.current = clone(this.original); },

        _setRecodeError(msg) {
          this.recodeError = msg || '';
          const errEl = this.$el ? this.$el.querySelector('.change-code-error') : null;
          if (errEl) { errEl.textContent = this.recodeError; errEl.style.display = this.recodeError ? '' : 'none'; }
        },

        cancel() {
          const panel = this.$el.closest('.md-detail-panel');
          if (panel) panel.innerHTML = "<div class='flex-grow-1 d-flex align-items-center justify-content-center text-muted'>Seleccione un registro para ver su detalle o haga clic en Agregar.</div>";
          document.body.dispatchEvent(new CustomEvent('detail-closed'));
        },

        markSaved() { this.original = clone(this.current); },

        handleSaveResponse(evt) {
          const detail    = evt && evt.detail ? evt.detail : {};
          const xhr       = detail.xhr || null;
          const messageEl = this.$el.querySelector('#form-message');
          if (!messageEl) return;
          const serverMessage = xhr && xhr.responseText ? String(xhr.responseText).trim() : '';
          if (detail.successful) {
            this.markSaved();
            messageEl.innerHTML = `<span class="text-success">${serverMessage || 'Guardado exitosamente.'}</span>`;
            document.body.dispatchEvent(new CustomEvent('refreshList'));
            return;
          }
          messageEl.innerHTML = `<span class="text-danger">${serverMessage || 'No se pudo guardar.'}</span>`;
          const codeInput = codeField ? this.$el.querySelector(`input[name="${codeField}"]`) : null;
          if (codeInput && typeof codeInput.focus === 'function') { codeInput.focus(); if (typeof codeInput.select === 'function') codeInput.select(); }
        },

        currentCode()  { return cleanCode(this.current && codeField  ? this.current[codeField]  : '', false); },
        currentLabel() { return String(this.current && labelField ? this.current[labelField] || '' : '').trim(); },

        async openChangeCodeModal() {
          const currentCode = this.currentCode();
          if (!currentCode) return;
          this.recodeNewCode = currentCode;
          this.recodeConfirm = false;
          this._setRecodeError('');
          const modalEl = this.$el.querySelector('.change-code-modal');
          if (!modalEl || !window.bootstrap) {
            const newCode = await linaPromptCodeChange(entityLabel, currentCode, this.currentLabel(), { uppercase: codeUppercase });
            if (!newCode) return;
            this.recodeNewCode = newCode;
            this.recodeConfirm = true;
            await this.confirmChangeCode();
            return;
          }
          this.recodeModal = bootstrap.Modal.getOrCreateInstance(modalEl, { backdrop: true, keyboard: true });
          this.recodeModal.show();
          this.$nextTick(() => {
            setTimeout(() => { const input = modalEl.querySelector('.change-code-input'); if (input) { input.focus(); if (input.select) input.select(); } }, 80);
          });
        },

        proceedChangeCode() {
          const currentCode = cleanCode(this.currentCode(), codeUppercase);
          const newCode     = cleanCode(this.recodeNewCode, codeUppercase);
          this.recodeNewCode = newCode;
          if (!newCode)                                        { this._setRecodeError('Debe ingresar un codigo.'); return; }
          if (maxCodeLength > 0 && newCode.length > maxCodeLength) { this._setRecodeError(`Máximo ${maxCodeLength} caracteres.`); return; }
          if (codeMin !== null || codeMax !== null) {
            const n = Number(newCode);
            if (isNaN(n) || (codeMin !== null && n < codeMin) || (codeMax !== null && n > codeMax)) {
              this._setRecodeError(`El código debe estar entre ${codeMin} y ${codeMax}.`); return;
            }
          }
          if (newCode === currentCode)                          { this._setRecodeError('El nuevo codigo debe ser distinto.'); return; }
          this._setRecodeError('');
          this.recodeConfirm = true;
        },

        closeChangeCodeModal() {
          this.recodeConfirm = false;
          this._setRecodeError('');
          if (this.recodeModal) this.recodeModal.hide();
        },

        async confirmChangeCode() {
          const currentCode    = this.currentCode();
          const newCode        = cleanCode(this.recodeNewCode, codeUppercase);
          const compareCurrent = cleanCode(currentCode, codeUppercase);
          this.recodeNewCode   = newCode;
          if (!newCode || newCode === compareCurrent) {
            this._setRecodeError('Debe indicar un codigo nuevo valido.');
            return { ok: false, message: this.recodeError };
          }
          const pane  = this.$el.closest('.tab-pane');
          const tabId = pane && pane.id && pane.id.startsWith('pane-') ? pane.id.substring(5) : '';
          const data  = new FormData();
          data.append('new_code', newCode);
          data.append('_tab', tabId);
          const resp    = await fetch(`${recodeUrlBase}/${encodeURIComponent(currentCode)}/recode`, { method: 'POST', headers: { 'X-Tab-Id': tabId }, body: data });
          const payload = await resp.json().catch(() => ({}));
          if (!resp.ok || !payload.ok) {
            this._setRecodeError(payload.message || 'No se pudo cambiar el codigo.');
            this.recodeConfirm = false;
            return { ok: false, message: this.recodeError };
          }
          this.closeChangeCodeModal();
          document.body.dispatchEvent(new CustomEvent('refreshList'));
          const panel = this.$el.closest('.md-detail-panel');
          if (panel && window.htmx) {
            htmx.ajax('GET', `${detailUrlBase}/${encodeURIComponent(payload.new_code)}?_tab=${encodeURIComponent(tabId)}`, { target: panel, swap: 'innerHTML' });
          }
          return { ok: true, message: payload.message || 'Codigo cambiado correctamente.' };
        },

        handleEscape() {
          if (this.isDirty()) this.reset();
          else this.cancel();
        },

        async handleSelectorRecode(evt) {
          const eventCode   = cleanCode(evt && evt.detail ? evt.detail.code  : '', codeUppercase);
          const eventLabel  = String(evt && evt.detail ? evt.detail.label || '' : '').trim();
          const currentCode = cleanCode(this.currentCode(), codeUppercase);
          if (!eventCode || eventCode !== currentCode) return;
          const newCode = await linaPromptCodeChange(entityLabel, this.currentCode(), eventLabel || this.currentLabel(), { uppercase: codeUppercase });
          if (!newCode) return;
          this.recodeNewCode = newCode;
          this.recodeConfirm = true;
          this._setRecodeError('');
          const result = await this.confirmChangeCode();
          if (!result || !result.ok) linaShowRecodeReject(result ? result.message : 'No se pudo cambiar el codigo.');
        },

        async requestDelete(trigger) {
          const btn = trigger && trigger.currentTarget
            ? trigger.currentTarget
            : (trigger && trigger.nodeType === 1 ? trigger : this.$el.querySelector('[data-selector-action=delete]'));
          if (!btn) { linaAlert('No se encontro la accion de eliminacion para este formulario.', 'warn'); return; }
          const pane       = this.$el.closest('.tab-pane');
          const tabId      = pane && pane.id && pane.id.startsWith('pane-') ? pane.id.substring(5) : '';
          const confirmMsg = btn.getAttribute('data-delete-confirm') || btn.getAttribute('hx-confirm') || 'Confirma la eliminacion del registro?';
          const confirmed  = await linaConfirm(confirmMsg, 'warn');
          if (!confirmed) return;
          const deleteUrl = btn.getAttribute('hx-delete') || '';
          if (!deleteUrl || !window.htmx) { linaAlert('No se pudo ejecutar la eliminacion.', 'error'); return; }
          const panel = this.$el.closest('.md-detail-panel');
          htmx.ajax('DELETE', deleteUrl, { target: panel || this.$el, swap: 'innerHTML', headers: { 'X-Tab-Id': tabId }, values: { _tab: tabId } });
        },

        handleSelectorDelete(evt) {
          const eventCode   = cleanCode(evt && evt.detail ? evt.detail.code : '', codeUppercase);
          const currentCode = cleanCode(this.currentCode(), codeUppercase);
          if (!eventCode || eventCode !== currentCode) return;
          this.requestDelete(this.$el.querySelector('[data-selector-action=delete]'));
        }
      };
    }

    document.addEventListener('lina:msg', function(e) {
      linaShowMsg(e.detail.text, e.detail.level, e.detail.extra);
    });

    document.addEventListener('htmx:responseError', function(e) {
      const detail = e && e.detail ? e.detail : null;
      const xhr    = detail && detail.xhr ? detail.xhr : null;
      const elt    = detail && detail.elt ? detail.elt : null;
      if (!xhr || !elt) return;
      const reqVerb       = (detail.requestConfig && detail.requestConfig.verb ? String(detail.requestConfig.verb) : '').toUpperCase();
      const isDeleteAction = reqVerb === 'DELETE' || !!elt.closest('[data-selector-action="delete"]') || !!elt.closest('[hx-delete]');
      if (!isDeleteAction) return;
      linaAlert((xhr.responseText || '').trim() || 'Operacion rechazada por el servidor.', 'error');
    });

    document.addEventListener('htmx:confirm', function(e) {
      const detail   = e && e.detail ? e.detail : null;
      const question = detail && detail.question ? String(detail.question) : '';
      if (!question) return;
      e.preventDefault();
      linaConfirm(question, 'warn').then(ok => { if (ok) detail.issueRequest(true); });
    });

    document.addEventListener('htmx:afterSettle', function(evt) {
      const target     = evt.detail && evt.detail.target ? evt.detail.target : null;
      if (!target) return;
      const detailRoot = target.matches('.md-detail-panel') ? target : target.closest('.md-detail-panel');
      if (!detailRoot) return;
      const firstInput = detailRoot.querySelector('input:not([readonly]):not([type="hidden"]), select:not([readonly]), textarea:not([readonly])');
      if (firstInput) { firstInput.focus(); if (firstInput.select) firstInput.select(); }
    });

    let _linaCloseAllSent = false;
    function linaCloseAllTabsBestEffort() {
      if (_linaCloseAllSent) return;
      const tabsRoot = window.linaTabsManager || null;
      if (!tabsRoot || !Array.isArray(tabsRoot.tabs) || tabsRoot.tabs.length === 0) return;
      const tabsPayload = tabsRoot.tabs.map(tab => ({ tabId: tab.id, commit: !!tab && tab.readonly === false && !tab.dirty }));
      if (!tabsPayload.length) return;
      const body = JSON.stringify({ tabs: tabsPayload });
      try {
        if (navigator.sendBeacon) {
          const blob = new Blob([body], { type: 'application/json' });
          _linaCloseAllSent = navigator.sendBeacon('/api/tabs/close-all', blob) || _linaCloseAllSent;
          if (_linaCloseAllSent) return;
        }
      } catch (_err) {}
      try {
        fetch('/api/tabs/close-all', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body, keepalive: true });
        _linaCloseAllSent = true;
      } catch (_err) {}
    }

    window.addEventListener('pagehide', function(e) {
      if (e && e.persisted) return;
      linaCloseAllTabsBestEffort();
    });

    document.addEventListener('visibilitychange', function() {
      if (document.visibilityState === 'hidden') linaCloseAllTabsBestEffort();
    });

    window.addEventListener('beforeunload', function(e) {
      const tabsRoot = window.linaTabsManager || null;
      linaCloseAllTabsBestEffort();
      if (!tabsRoot || typeof tabsRoot.anyTabDirty !== 'function') return;
      if (!tabsRoot.anyTabDirty()) return;
      e.preventDefault();
      e.returnValue = '';
    });


/* ── SELECTOR GENÉRICO (F4) ─────────────────────────────────────────────── */

window._linaSelectorState = {
  visible:   false,
  titulo:    "Seleccionar",
  tabla:     "",
  campoCod:  "",
  campoDesc: "",
  resolve:   null,
};

window.linaAbrirSelector = function(config) {
  const state     = window._linaSelectorState;
  state.tabla     = (config && config.tabla)     || "";
  state.campoCod  = (config && config.campoCod)  || "";
  state.campoDesc = (config && config.campoDesc) || "";
  state.titulo    = (config && config.titulo)    || "Seleccionar";
  state.visible   = true;
  window.dispatchEvent(new CustomEvent("lina:selector:abrir", { detail: Object.assign({}, state) }));
  return new Promise(resolve => { state.resolve = resolve; });
};

document.addEventListener("alpine:init", () => {
  Alpine.data("linaSelectorModalModel", () => ({
    visible:   false,
    titulo:    "Seleccionar",
    tabla:     "",
    campoCod:  "",
    campoDesc: "",
    buscar:    "",
    rows:      [],
    selIdx:    -1,
    cargando:  false,

    init() {
      // Activar drag una sola vez cuando el componente está listo
      this.$nextTick(() => {
        const box    = document.getElementById('linaSelectorBox');
        const header = document.getElementById('linaSelectorHeader');
        if (box && typeof linaMakeDraggable === 'function') {
          linaMakeDraggable(box, header);
        }
      });

      window.addEventListener("lina:selector:abrir", (e) => {
        // Guardar el elemento que tenía foco antes de abrir
        this._elementoAnterior = document.activeElement;

        const d        = e.detail || {};
        this.tabla     = d.tabla     || "";
        this.campoCod  = d.campoCod  || "";
        this.campoDesc = d.campoDesc || "";
        this.titulo    = d.titulo    || "Seleccionar";
        this.buscar    = "";
        this.rows      = [];
        this.selIdx    = -1;
        this.visible   = true;

        // Resetear posición al centro cada vez que se abre
        const box = document.getElementById('linaSelectorBox');
        if (box) {
          box.style.left      = '50%';
          box.style.top       = '50%';
          box.style.transform = 'translate(-50%, -50%)';
        }

        this.buscarRows();
        this.$nextTick(() => {
          if (this.$refs.inputBuscar) this.$refs.inputBuscar.focus();
        });
      });
    },

    async buscarRows() {
      if (!this.tabla) return;
      this.cargando = true;
      try {
        const params = new URLSearchParams({
          tabla:        this.tabla,
          campo_codigo: this.campoCod,
          campo_desc:   this.campoDesc,
          buscar:       this.buscar,
        });
        const resp = await fetch("/api/selector?" + params.toString());
        const data = await resp.json();
        this.rows   = data.ok ? (data.rows || []) : [];
        this.selIdx = this.rows.length > 0 ? 0 : -1;
      } catch (_e) {
        this.rows   = [];
        this.selIdx = -1;
      } finally {
        this.cargando = false;
      }
    },

    moverSeleccion(dir) {
      if (this.rows.length === 0) return;
      this.selIdx = Math.max(0, Math.min(this.rows.length - 1, this.selIdx + dir));
    },

    aceptarSeleccionado() {
      if (this.selIdx < 0 || this.selIdx >= this.rows.length) return;
      this.cerrar(this.rows[this.selIdx].codigo);
    },

    cancelar() { this.cerrar(null); },

    cerrar(valor) {
      this.visible  = false;
      this.buscar   = "";
      this.rows     = [];
      this.selIdx   = -1;
      const state   = window._linaSelectorState;
      state.visible = false;
      if (typeof state.resolve === "function") {
        state.resolve(valor);
        state.resolve = null;
      }
      // Devolver foco al elemento que lo tenía antes de abrir el modal
      const prev = this._elementoAnterior;
      if (prev && typeof prev.focus === 'function') {
        this.$nextTick(() => { prev.focus(); if (prev.select) prev.select(); });
      }
      this._elementoAnterior = null;
    },
  }));
});

document.addEventListener("keydown", function(e) {
  if (e.key !== "F4") return;
  const el = document.activeElement;
  if (!el) return;
  const tabla     = el.dataset.selectorTabla;
  const campoCod  = el.dataset.selectorCampoCod;
  const campoDesc = el.dataset.selectorCampoDesc;
  const titulo    = el.dataset.selectorTitulo || "Seleccionar";
  if (!tabla || !campoCod || !campoDesc) return;
  e.preventDefault();
  linaAbrirSelector({ tabla, campoCod, campoDesc, titulo }).then(codigo => {
    if (codigo !== null) {
      el.value = codigo;
      el.dispatchEvent(new Event("input",  { bubbles: true }));
      el.dispatchEvent(new Event("change", { bubbles: true }));
    }
  });
});

/* ── DRAG: ventanas modales arrastrables ─────────────────────────────────── */

/**
 * linaMakeDraggable(containerEl, handleEl)
 * Hace que containerEl sea arrastrable tomándolo por handleEl.
 * Si handleEl es null, usa containerEl como handle.
 *
 * Uso:
 *   linaMakeDraggable(
 *     document.querySelector('#miModal .modal-box'),
 *     document.querySelector('#miModal .modal-header')
 *   );
 */
window.linaMakeDraggable = function(containerEl, handleEl) {
  if (!containerEl) return;
  const handle = handleEl || containerEl;
  handle.style.cursor = "move";

  let startX = 0, startY = 0, origLeft = 0, origTop = 0;

  handle.addEventListener("mousedown", function(e) {
    if (e.button !== 0) return;
    e.preventDefault();

    const rect = containerEl.getBoundingClientRect();
    origLeft = rect.left;
    origTop  = rect.top;
    startX   = e.clientX;
    startY   = e.clientY;

    // Asegurar posicionamiento absoluto desde la posición actual
    containerEl.style.position  = "fixed";
    containerEl.style.left      = origLeft + "px";
    containerEl.style.top       = origTop  + "px";
    containerEl.style.transform = "none";
    containerEl.style.margin    = "0";

    function onMove(e) {
      const dx = e.clientX - startX;
      const dy = e.clientY - startY;
      containerEl.style.left = (origLeft + dx) + "px";
      containerEl.style.top  = (origTop  + dy) + "px";
    }

    function onUp() {
      document.removeEventListener("mousemove", onMove);
      document.removeEventListener("mouseup",   onUp);
    }

    document.addEventListener("mousemove", onMove);
    document.addEventListener("mouseup",   onUp);
  });
};

/* ── Barra de mensajes (BR-006): listeners sin onclick en HTML ── */
(function () {
  function bindMsgbar() {
    const ack = document.getElementById('lina-msgbar-ack');
    if (ack) ack.addEventListener('click', linaAckMsg);
    const txt = document.getElementById('lina-msgbar-text');
    if (txt) txt.addEventListener('dblclick', linaOpenMsgDetail);
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bindMsgbar);
  } else {
    bindMsgbar();
  }
})();
