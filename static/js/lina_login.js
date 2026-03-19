(function () {
  function initLoginBehavior() {
    const userInput = document.getElementById("login_user_code");
    const input = document.getElementById("login_user_pass");
    const btn = document.getElementById("toggle-user-pass");
    const submitBtn = document.getElementById("login-submit-btn");
    const form = input ? input.form : null;
    if (!input || !btn) return;

    if (userInput && document.querySelector(".alert.alert-danger")) {
      userInput.focus();
      userInput.select();
    }

    // Keep password toggle out of keyboard Tab order.
    btn.tabIndex = -1;
    btn.setAttribute("tabindex", "-1");

    input.addEventListener("keydown", function (ev) {
      if (ev.key === "Enter" && form) {
        ev.preventDefault();
        if (submitBtn && typeof form.requestSubmit === "function") {
          form.requestSubmit(submitBtn);
        } else if (submitBtn) {
          submitBtn.click();
        } else {
          form.submit();
        }
        return;
      }

      if (ev.key === "Tab" && !ev.shiftKey && submitBtn) {
        ev.preventDefault();
        submitBtn.focus();
      }
    });

    btn.addEventListener("click", function () {
      const isPassword = input.getAttribute("type") === "password";
      input.setAttribute("type", isPassword ? "text" : "password");
      btn.textContent = isPassword ? "Ocultar" : "Mostrar";
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initLoginBehavior);
  } else {
    initLoginBehavior();
  }
})();
