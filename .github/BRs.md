******
BR-001
******
Cuando se use el articodi=='*' en remitos de compra y de venta, 
1. Se permitirá ingresar la descripción, cantidad y precio del artículo 
2. No generará movimientos de stock.

******
BR-002
******
Aplicable a los CRUDS de tablas maestras
1. Cuando hago una seleccion de registro en el panel izquierdo que el foco pase al primer 
campo en el panel derecho. 
Tambien que por panel derecho vacío pueda navegar el panel izquierdo con las flechas up y down 
y que el enter sobre un registro funcione como un click

******
BR-003
******
Aplicable a todas las pantallas de la aplicación
1. Necesito (y esto para todas las pantallas de la aplicación) que 
escape funcione como un "paso atrás"
    (normalmente que equivalga a un click en deshacer o click en cancelar 
    o cerrar el tab si está permitido, en ese orden)  
    y además que la tecla "+" del pad numérico funcione siempre como avance de campo <Tab>
    y pad "-" como retroceso de campo <Shift+Tab>

******
BR-004
******
1. No usamos rutas absolutas en el desarrollo

******
BR-005
******
Regla de negocio para id de usuario y pwd

******
BR-010
******
Solo utilizamos recursos gnu gratis permanentemente


username (usercodi)
Longitud: 8 a 32.
Permitidos: letras, números, guion bajo, espacios, punto.
Case-insensitive para login, pero guardar en mayúsculas normalizadas.
Unicidad por empresa (emprcodi + usercodi).
Sugerencias: que la pantalla login no recuerde ni sugiera las ultimas id usuario
userpass
Longitud mínima: 8 (ideal 12+).
Debe incluir al menos 3 de 4 grupos: mayúscula, minúscula, número, símbolo.
Visibilidad: como opcion de configuracion puede aparecer el visualizador de pwd al ingersarla
Bloquear contraseñas obvias: nombre de usuario, secuencias (123456, abcdef), repetidas.
Historial: no reutilizar últimas 3.
Rotación: 90 días (si aplica política corporativa).
Bloqueo temporal: 5 intentos fallidos -> 15 minutos.
Guardado: hash sha2, nunca texto plano. Ante una apliacion nueva considerar Argon2id o bcrypt
Auditoria:
agregar a tabla user 
    userpdat, datetime (ultimo update de userpas)
    userfail, int (numero de intentos fallidos)
    userlock, datetime (bloqueado hasta fecha-hora)
    userplog, char(96) (últimos 3 hash, 3*32)
    userbloq, char(1) (condición de Bloqueo, a definir)

******
BR-006
******
En linabase se implementara una barra horizontal en el borde inferior del formulario, 
que mostrará los mensajes de la ap.
Referencia: CapaUI\Pantalla CRUD Single Record.jpeg
Tambien los programas heredaran de linabase la funcion de mostrar mensajes con niveles
    a) Informacion
    b) Advertencia
    c) Error
Esta función recibirá Texto del mensaje y nivel de gravedad. Si el mensaje es más extenso que el 
ancho disponible finalizará en tres puntos "..."
A la izquierda de esta barra un elemento que muestre el ícono del mensaje (usar los de windows)
A la derecha de esta barra un botón pequeño con una tilde verde para aceptar el mensaje.
La barra estará limpia y los íconos ocultos hasta que se active el mensaje
Click en el ícono verde la volverá a su estado inicial
Cuando la ventana esté activa, doble click en el texto expandirá el mensaje a una ventana modal que 
permita copiar la info del mensaje y/o ser cerrada.
En la info del mensaje incluirá Usuario, empresa, programa (tab), texto, gravedad, fecha y hora y
comentarios específicos hechos por el programa activo.
En el futuro se logeará esta data en la tabla linaerro.


******
BR-007
******
Cuando se generen scripts sql para operar administrativamente sobre la bd, 
que sean sql puro, no sql embebido en python

******
BR-008
******
Nunca pero nunca usar hardcode para info que esté en el origen de datos. Con solo los datos de conexión al motor de datos tiene que poder gestionarse toda la metadata desde el origen

******
BR-009
******
No usar el código javascript embebido en html. Usar static\js

******
BR-010
******
Respetar estructura de capas. Toda comunicacion con la bd origen debe estar en CapaDAL, ningun script sql debe estar en CapaUI o CapaBR

******
BR-011
******
En la lista de precios LINA1332
1. Omitir los que tienen precio = 0
2. Omitir los que tienen en parte de su descripcion "NO HAY" o "NO USAR"
3. Compactar todos los que están bajo el rubro MCOM con el mismo precio y lista un solo renglón, código en blanco, descripción "Todas las medallas comunes"
4. Compactar en un solo rengón "Medallas laser" a todas las que tengan como descripcion "Medalla laser" y el mismo precio.

******
BR-012
******
En remitos de venta: lina21.py
    cliente 9000 Ajustes de stock es un cliente particular, los precios de los artículos "vendidos" se toman siempre=0,
    siempre el total del remito en dinero será=0. De esta manera mueve stock sin mover dinero.
    En este cliente se admiten cantidades negativas
    En este cliente no se admite articodi=*

******
BR-013
******
En remitos de venta: lina21.py
    El código de artículo "*" no mueve stock, 
    existe para facturar importes positivos o negativos que no obedecen a movimientos de stock
    Cuando se ingresa "*" el campo "descripcion" deja de ser readonly y se edita, 
    por eso se incluye fvdedesc en linafvde, para guardar estos datos que no son artidesc
    
******
BR-014
******
Los listados podrán presentarse en pdf, xlsx y txt, excepto cuando se especifique lo contrario
El formato txt usará una fuente de ancho fijo, por ejemplo ms sans serif, 
tamaño adecuado al ancho del registro para que entre en A4 vertical o apaisado

******
BR-015
******
Periódicamente encargar a Claude buscar
Código duplicado
Dead code
JS embebido
Capas cruzadas
Hardcode parametrizable hacerlo
Hardcode no parametrizable todo junto a config.py

******
BR-015
******
    En Compras: registración de remitos(facturas) recibidos van al haber y los recibos(pagos hechos por nosotros) al debe
    En Compras: registración de remitos el precio unitario se toma del operador, no de linaarti
    Al registrar remitos de compra el total del remito va al haber del proveedor, no pide pago, va todo a cta. cte. y no genera     recibo
    Los comprobantes de compras no se imprimen, salvo que sea a pedido desde lina32 o lina35
