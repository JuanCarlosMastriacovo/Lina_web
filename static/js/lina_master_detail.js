(function () {
  function linaCreateMasterDetailSelectorModel() {
    return {
      selectedIndex: -1,
      contextMenu: {
        visible: false,
        x: 0,
        y: 0,
        row: null,
        title: "",
      },
      isPanelActive() {
        const pane = this.$root.closest(".tab-pane");
        return !pane || pane.classList.contains("active");
      },
      isTypingInField() {
        const el = document.activeElement;
        if (!el) return false;
        const tag = el.tagName;
        return ["INPUT", "TEXTAREA", "SELECT"].includes(tag) || el.isContentEditable;
      },
      shouldHandleKey(e) {
        if (this.contextMenu && this.contextMenu.visible) return false;
        const navKey = ["ArrowDown", "ArrowUp", "PageDown", "PageUp", "Enter"].includes(e.key) || e.code === "NumpadEnter";
        if (!navKey) return false;
        if (this.isTypingInField()) return false;

        const active = document.activeElement;
        if (active === document.body) return true;
        return this.$root.contains(active);
      },
      getRows() {
        return Array.from(this.$root.querySelectorAll(".grid-row"));
      },
      getDetailPanel() {
        const workspace = this.$root.closest(".md-workspace");
        if (!workspace) return null;
        return workspace.querySelector(".md-detail-panel");
      },
      hideContextMenu() {
        this.contextMenu.visible = false;
        this.contextMenu.row = null;
        this.contextMenu.title = "";
      },
      getRowCode(row) {
        if (!row) return "";
        let code = String(row.dataset.itemCode || "").trim();
        if (!code) {
          const firstCell = row.querySelector("td");
          code = String(firstCell ? firstCell.textContent : "").trim();
        }
        if (!code) {
          const detailUrl = String(row.dataset.detailUrl || row.getAttribute("hx-get") || "");
          const match = detailUrl.match(/\/detail\/([^/?#]+)/i);
          if (match && match[1]) {
            try {
              code = decodeURIComponent(match[1]).trim();
            } catch (_e) {
              code = String(match[1]).trim();
            }
          }
        }
        return code;
      },
      getRowLabel(row) {
        if (!row) return "";
        let label = String(row.dataset.itemLabel || "").trim();
        if (!label) {
          const secondCell = row.querySelectorAll("td")[1];
          label = String(secondCell ? secondCell.textContent : "").trim();
        }
        return label;
      },
      showContextMenuForRow(row, focusFirstItem = false) {
        if (!row) return;
        const rows = this.getRows();
        const rowIndex = rows.indexOf(row);
        if (rowIndex >= 0) {
          this.selectedIndex = rowIndex;
          this.updateSelection(true);
        }
        this.contextMenu.row = row;
        this.contextMenu.title = [this.getRowCode(row), this.getRowLabel(row)]
          .filter(Boolean)
          .join(" - ");
        this.contextMenu.visible = true;
        this.$nextTick(() => {
          const menu = this.$root.querySelector(".selector-context-menu");
          if (!menu) return;
          const bounds = this.$root.getBoundingClientRect();
          const rowBounds = row.getBoundingClientRect();
          const menuWidth = menu.offsetWidth || 180;
          const menuHeight = menu.offsetHeight || 120;
          const maxX = Math.max(8, bounds.width - menuWidth - 8);
          const maxY = Math.max(8, bounds.height - menuHeight - 8);
          const preferredX = rowBounds.left - bounds.left + 28;
          const preferredY = rowBounds.top - bounds.top + 2;
          const fallbackY = rowBounds.bottom - bounds.top - menuHeight - 2;
          this.contextMenu.x = Math.min(Math.max(8, preferredX), maxX);
          this.contextMenu.y = preferredY <= maxY ? Math.max(8, preferredY) : Math.max(8, fallbackY);

          if (focusFirstItem) {
            const firstItem = menu.querySelector(".selector-context-menu-item");
            if (firstItem && typeof firstItem.focus === "function") {
              setTimeout(() => firstItem.focus(), 0);
            }
          }
        });
      },
      openContextMenu(e) {
        const row = e.target.closest(".grid-row");
        if (!row) return;
        e.preventDefault();
        this.showContextMenuForRow(row, true);
      },
      handleContextMenuKey(e) {
        const isShiftF10 = e.shiftKey && e.key === "F10";
        if (!isShiftF10) return;
        if (this.isTypingInField()) return;

        const rows = this.getRows();
        if (!rows.length) return;

        let row = document.activeElement ? document.activeElement.closest(".grid-row") : null;
        if (!row) {
          if (this.selectedIndex < 0) this.selectedIndex = 0;
          row = rows[this.selectedIndex] || rows[0];
        }
        if (!row) return;

        e.preventDefault();
        this.showContextMenuForRow(row, true);
      },
      handleContextMenuNavigationKey(e) {
        if (!(this.contextMenu && this.contextMenu.visible)) return;
        const menu = this.$root.querySelector(".selector-context-menu");
        if (!menu) return;

        const items = Array.from(menu.querySelectorAll(".selector-context-menu-item"));
        if (!items.length) return;

        const active = document.activeElement;
        let idx = items.indexOf(active);

        if (e.key === "Escape") {
          e.preventDefault();
          e.stopPropagation();
          return;
        }

        if (e.key === "ArrowDown") {
          e.preventDefault();
          e.stopPropagation();
          idx = idx < 0 ? 0 : (idx + 1) % items.length;
          items[idx].focus();
          return;
        }

        if (e.key === "ArrowUp") {
          e.preventDefault();
          e.stopPropagation();
          idx = idx < 0 ? items.length - 1 : (idx - 1 + items.length) % items.length;
          items[idx].focus();
        }
      },
      getLoadedDetailUrl() {
        const detailRoot = this.getDetailPanel()?.querySelector("[data-detail-url]");
        return detailRoot ? detailRoot.dataset.detailUrl || "" : "";
      },
      openContextDetail() {
        const row = this.contextMenu.row;
        if (!row) return;
        const detailUrl = row.dataset.detailUrl;
        const panel = this.getDetailPanel();
        this.hideContextMenu();
        if (detailUrl && panel && window.htmx) {
          htmx.ajax("GET", detailUrl, {
            target: panel,
            swap: "innerHTML",
          });
          return;
        }
        row.click();
      },
      ensureDetailLoaded(detailUrl, onReady) {
        const panel = this.getDetailPanel();
        if (!panel || !detailUrl) return;
        if (this.getLoadedDetailUrl() === detailUrl) {
          onReady();
          return;
        }
        if (window.htmx) {
          const onAfterSwap = () => {
            setTimeout(() => onReady(), 0);
          };
          panel.addEventListener("htmx:afterSwap", onAfterSwap, { once: true });
          htmx.ajax("GET", detailUrl, {
            target: panel,
            swap: "innerHTML",
          });
        }
      },
      invokeDetailAction(actionName) {
        const row = this.contextMenu.row;
        if (!row) return;
        const detailUrl = row.dataset.detailUrl;
        const itemCode = this.getRowCode(row);
        const itemLabel = this.getRowLabel(row);
        this.hideContextMenu();
        if (!detailUrl || !itemCode) return;
        this.ensureDetailLoaded(detailUrl, () => {
          const eventName = actionName === "delete" ? "selector-delete" : "selector-recode";
          setTimeout(() => {
            window.dispatchEvent(
              new CustomEvent(eventName, {
                detail: { code: itemCode, label: itemLabel },
              })
            );
          }, 40);
        });
      },
      setFirstRowSelected() {
        const rows = this.getRows();
        if (rows.length > 0) {
          this.selectedIndex = 0;
          this.updateSelection(true);
        } else {
          this.selectedIndex = -1;
          this.hideContextMenu();
        }
      },
      handleKeyDown(e) {
        const rows = this.getRows();
        if (rows.length === 0) return;

        const focusedRow = document.activeElement ? document.activeElement.closest(".grid-row") : null;
        if (focusedRow) {
          const focusedIndex = rows.indexOf(focusedRow);
          if (focusedIndex >= 0) this.selectedIndex = focusedIndex;
        }

        if (this.selectedIndex < 0) this.selectedIndex = 0;

        if (e.key === "ArrowDown") {
          e.preventDefault();
          this.selectedIndex = Math.min(this.selectedIndex + 1, rows.length - 1);
          this.updateSelection();
        } else if (e.key === "ArrowUp") {
          e.preventDefault();
          this.selectedIndex = Math.max(this.selectedIndex - 1, 0);
          this.updateSelection();
        } else if (e.key === "PageDown") {
          e.preventDefault();
          this.selectedIndex = Math.min(this.selectedIndex + 10, rows.length - 1);
          this.updateSelection();
        } else if (e.key === "PageUp") {
          e.preventDefault();
          this.selectedIndex = Math.max(this.selectedIndex - 10, 0);
          this.updateSelection();
        } else if ((e.key === "Enter" || e.code === "NumpadEnter") && this.selectedIndex >= 0) {
          e.preventDefault();
          rows[this.selectedIndex].click();
        }
      },
      updateSelection(keepFocus = false) {
        const rows = this.getRows();
        rows.forEach((r, i) => {
          if (i === this.selectedIndex) {
            r.classList.add("selected");
            if (keepFocus) {
              r.focus();
            }
            r.scrollIntoView({ block: "nearest" });
          } else {
            r.classList.remove("selected");
          }
        });
      },
    };
  }

  window.linaCreateMasterDetailSelectorModel = linaCreateMasterDetailSelectorModel;
})();
