# Diagrama Entidad-Relación (EER) - Sistema LinaWeb

Este diagrama representa las relaciones entre las 24 tablas del sistema.

```mermaid
erDiagram
    LinaEmpr ||--o{ LinaArti : owns
    LinaEmpr ||--o{ LinaArtr : owns
    LinaEmpr ||--o{ LinaClie : owns
    LinaEmpr ||--o{ LinaProv : owns
    LinaEmpr ||--o{ LinaUser : owns

    LinaArtr ||--o{ LinaArti : categorizes
    LinaArti ||--o{ LinaFvde : "sold in"
    LinaArti ||--o{ LinaFcde : "bought in"

    LinaClie ||--o{ LinaBanc : "bank moves"
    LinaClie ||--o{ LinaCaja : "cash moves"
    LinaClie ||--o{ LinaCohe : "compro cab"
    LinaClie ||--o{ LinaCtcl : "account moves"
    LinaClie ||--o{ LinaFvhe : "invoice cab"

    LinaProv ||--o{ LinaBanc : "bank moves"
    LinaProv ||--o{ LinaCaja : "cash moves"
    LinaProv ||--o{ LinaCtpr : "account moves"
    LinaProv ||--o{ LinaFche : "purchase cab"
    LinaProv ||--o{ LinaPahe : "payment cab"

    LinaFvhe ||--o{ LinaFvde : "contains"
    LinaFche ||--o{ LinaFcde : "contains"
    LinaCohe ||--o{ LinaCode : "contains"
    LinaPahe ||--o{ LinaPade : "contains"

    LinaCodm ||--o{ LinaFvhe : "type of"
    LinaCodm ||--o{ LinaFche : "type of"
    LinaCodm ||--o{ LinaCohe : "type of"
    LinaCodm ||--o{ LinaPahe : "type of"

    LinaUser ||--o{ LinaSafe : "has permissions (CASCADE)"
    LinaProg ||--o{ LinaSafe : "is secured (CASCADE)"

    LinaUser ||--o{ LinaEmpr : "belongs to"
    LinaProg }|--o{ LinaUser : "accessed by"

```

## Lógica de Base de Datos

### Auditoría Automática
El sistema cuenta con un robusto sistema de auditoría implementado mediante disparadores (**triggers**) en 21 tablas del sistema.

*   **Campos Auditados**: `user`, `date`, `time`, `oper`, `prog`, `wstn`, `nume`.
*   **Formato de Hora**: `hh:mm:ss`.
*   **Operaciones**:
    *   `I`: Registro insertado.
    *   `U`: Registro actualizado.
*   **Integración con la Web**: La aplicación envía el usuario logueado y el código del programa activo a través de variables de sesión de MySQL (`@lina_user` y `@lina_prog`), permitiendo que la base de datos identifique quién realizó cada cambio incluso desde la capa web.

### Sincronización de Permisos (Security)
La tabla `linasafe` (Permisos) se mantiene sincronizada automáticamente con las tablas `linauser` (Usuarios) y `linaprog` (Programas).

*   **Procedimiento Almacenado**: `sp_sync_linasafe` se encarga de ecualizar las tablas para asegurar que cada usuario tenga una entrada de permiso para cada programa del sistema.
*   **Automatización**: Se ejecutan disparadores automáticos ante cualquier `INSERT` o `DELETE` en las tablas de Usuarios o Programas.
*   **Integridad Referencial**: 
    *   **ON UPDATE CASCADE**: Cambios en códigos de usuario o programa se propagan automáticamente a los permisos.
    *   **ON DELETE CASCADE**: La eliminación de usuarios o programas limpia automáticamente sus permisos asociados.

