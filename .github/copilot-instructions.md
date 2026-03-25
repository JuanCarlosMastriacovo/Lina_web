# Workspace Instructions for lina_web

## Propósito

Estas instrucciones guían a los agentes de GitHub Copilot y subagentes en el proyecto lina_web para mantener coherencia, calidad y eficiencia en el desarrollo.

## Principios clave

- **Respeta la arquitectura**: FastAPI (CapaUI), lógica de negocio (CapaBRL), acceso a datos (CapaDAL), plantillas Jinja (templates), estáticos (static).
- **Convenciones de nombres**: Sigue los patrones existentes (ej: lina21 para ventas, lina31 para compras, etc.).
- **No dupliques lógica**: Si una función existe para ventas, reutiliza/migra para compras cambiando contexto (ver Pendiente.txt).
- **Errores y UX**: Mensajes claros, foco automático en campos relevantes, feedback inmediato en formularios.
- **Scripts y comandos**: Usa los scripts y comandos documentados en README.md para ejecutar, testear y mantener la app.
- **Variables sensibles**: Nunca expongas credenciales en código fuente ni plantillas.
- **Documenta cambios relevantes**: Si introduces una convención nueva, actualiza README.md o deja comentario claro.

## Comandos principales

- Ejecutar app: `python -m CapaUI.lina0` o `uvicorn CapaUI.lina0:app --reload`
- Scripts SQL: Ejecutar desde MySQL Workbench o terminal según README.md

## Áreas de especial atención

- Al migrar lógica de ventas a compras, sigue las equivalencias de Pendiente.txt (ej: linaclie → liniaprov, debe ↔ haber, etc.).
- Mantén la homogeneidad UX entre módulos equivalentes (ej: ventas vs compras).
- Si encuentras hardcode, consulta si debe parametrizarse.

## Reglas de negocio (BR-001 a BR-015)

**BR-001:** Si articodi == '*' en remitos (compra/venta): permite descripción/cantidad/precio, pero no genera movimientos de stock.

**BR-002:** En CRUDs de tablas maestras, al seleccionar registro en panel izquierdo, el foco pasa al primer campo del derecho. Navegación con flechas y enter.

**BR-003:** En todas las pantallas: Escape equivale a "paso atrás" (deshacer/cancelar/cerrar tab). Tecla "+" del pad numérico = Tab, "-" = Shift+Tab.

**BR-004:** No usar rutas absolutas en desarrollo.

**BR-005:** Usuario (usercodi): 8-32 caracteres, letras/números/guion bajo/espacios/punto, case-insensitive para login, guardar en mayúsculas. Unicidad por empresa. Password: mínimo 8, ideal 12+, 3 de 4 grupos (mayúscula, minúscula, número, símbolo), bloqueo tras 5 fallos, hash seguro, historial, rotación, bloqueo temporal, nunca texto plano.

**BR-006:** Barra de mensajes horizontal en formularios (heredada de linabase), con niveles (info, advertencia, error), ícono, botón aceptar, doble click expande, incluye info de usuario, empresa, programa, fecha/hora, comentarios.

**BR-007:** Scripts SQL administrativos deben ser SQL puro, no embebido en Python.

**BR-008:** Nunca usar hardcode para info que esté en el origen de datos; toda metadata debe gestionarse desde el origen.

**BR-009:** No usar JS embebido en HTML, siempre en static/js.

**BR-010:** Respetar estructura de capas: toda comunicación con BD en CapaDAL, nunca SQL en CapaUI o CapaBRL.

**BR-011:** En lista de precios (LINA1332): omitir precios=0, descripciones "NO HAY"/"NO USAR"; compactar medallas comunes y laser según reglas.

**BR-012:** Remitos de venta cliente 9000 (ajustes stock): precios y total siempre 0, admite cantidades negativas, no admite articodi="*".

**BR-013:** Remitos de venta: articodi="*" no mueve stock, permite descripción editable, se guarda en campo especial.

**BR-014:** Listados pueden ser PDF, XLSX o TXT (fuente monoespaciada, formato A4 vertical/apaisado).

**BR-015:** Revisar periódicamente: código duplicado, dead code, JS embebido, capas cruzadas, hardcode parametrizable (llevar a config.py).

Para detalles y redacción completa, consulta también [CapaBRL/BRs.md](../CapaBRL/BRs.md).

## Anti-patrones a evitar

- Duplicar código sin adaptar contexto.
- Ignorar convenciones de carpetas y nombres.
- Modificar scripts SQL sin actualizar documentación.
- Introducir dependencias no listadas en requirements.txt.

## Ejemplo de prompts útiles

- "Genera el módulo de compras equivalente a ventas (lina21 → lina31) siguiendo convenciones y UX."
- "¿Qué scripts SQL debo correr para inicializar la base?"
- "¿Cómo adapto la lógica de cobranzas a pagos?"

---

Para detalles adicionales, consulta README.md, Pendiente.txt y BRs.md.