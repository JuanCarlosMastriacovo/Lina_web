- Generar un Procedimiento en Claude para renombrar un programa
- Usar la barra de mensajes
- Que ocurrio con .venv en la migracion. ¿conviene recrearlo?
*HECHO* Listados
*HECHO* Que los botones tambien presenten tool tips con su función
*HECHO* Session date
*HECHO* Que el botón mostrar/ocultar en pantalla login no tenga tabstop para que con enter se llegue directamente a "ingresar"
*HECHO* Que al cerrar el navegador se haga logout en la aplicación
*HECHO* Ancho de los cuadros de ingreso en forms
*HECHO* Grilla selector con click en cabecera
*HECHO* Grilla selector con botón derecho=>menú
*HECHO* Grilla selector con "buscar"
*HECHO* SP sp_copy_user_rights: desde source_emprcodi+source_usercodi hasta target_emprcodi+target_usercodi copiar safealta,baja,modi,cons
*HECHO* Revisa que la lógica de funcionamiento de lina111 sea homogénea con lina131 que no sé si lo fuimos llevando así.
*HECHO* Los anchos de los controles de ingreso de datos en las pantallas que sean producto de la "medida" de la longitud del dato según la fuente
*HECHO* Con el click en la cruz del campo "buscar" que se refresque la lista y el foco al primer registro del selector
*HECHO* ¿se pueden usar "tool tips" que se muestren al hacer hover con el mouse en los controles (tanto etiquetas como cuadros de texto)?
*HECHO* Implementar git
NEGADO Que el menu contextual en selector de abm single record se despliegue tambien con tecla windows
DESCARTADO Validaciones de campos en CapaDAL y localmente para el prog en CapaUI
    máscara de validación
    "" no se valida
    "9" que sea numérico entero
    "9#" que sea numérico entero o decimal
    "A" que sea alfanumérico
    "D" fecha
    "T" hora
    "DT" datetime
    "*" no vacío ni blancos a la izquierda si es "A"
    
    "<expr" o "<=expr" limite superior del valor
    ">expr" o ">=expr" limite inferior del valor
*HECHO*Forms modales de asistencia y selectores de single record
*HECHO* Carpeta temp->miscelaneas
*HECHO* buscar y eliminar deadcode
*HECHO* separar js de html
*HECHO* buscar hardcode y consultar parametrizacion
*HECHO* que siga en brl def get_existencias_batch usa sql crudo teniendo fn_calc_exis para una individual o si tiene que usar sql crudo migrar fn a CapaDAL
*HECHO* FMT_NROCOMP = "08d" debe ser "06d"
*HECHO* Listados a txt
*HECHO* modulo imprimir comprobantes: migrado de zprtC.prg
*HECHO* implementar BR-012 y BR-013
*HECHO* en todos los menues contextuales sacar el ícono que aparece a la izquierda de la leyenda
*HECHO* En seleccion de empresa no actualiza desde linaempr al arranque
*HECHO* Ver que pasa con linasafe al crear o eliminar empresa
*HECHO* Si ctx_date#hoy() mostrar con colores  destacados
*HECHO* Verás que la parte de compras Menu lina31 hasta lina372 es homóloga a la parte de ventas, lina21 hasta lina272, que ya tenemos
    Necesito que generes los programas de lina31 hasta lina372,
    considerando
    Lo que era Ventas, ahora son Compras
    Lo que era Cobranzas ahora son Pagos
    Lo que era linaclie y linactcl ahora son liniaprov y linactpr
    Lo que era debe ahora es haber y viceversa
    Lo que era emision de comprobantes (remitos, recibos) ahora es registracion (recibimos los comprobantes, no los generamos)
    En registración de remitos(facturas) recibidos van al haber y los recibos(pagos hechos por nosotros) al debe
    En registración de remitos el precio unitario se toma del operador, no de linaarti
    Al registrar remitos el total del remito va al haber del proveedor, no pide pago, va todo a cta. cte. y no genera recibo
    Los comprobantes de compras no se imprimen, salvo que sea a pedido desde lina32 o lina35

*HECHO*CurrEmpr
    Que hacer al cambiar empresa:
        a. negar desplegar selección si hay tabs abiertos===>msg
        b. permitir seleccion y buscar si el usuario tiene algun permiso en esa empresa, si no===>msg
        c. definir nueva plantilla de permisos
*HECHO*CurrDate
    Que hacer al cambiar fecha:
        a. validar que el usuario tenga permiso de cambiar fecha
        b. negar update de fecha si hay tabs abiertos===>msg
        c. Si ctx_date#hoy() mostrar con colores destacados
        
*HECHO*Lina1341 (Cardex) renombrar y mover a 1336
*HECHO*Falta Lina134: Cambio de Precios
            Lina1341.py Por Artículo
            Lina1342.py Por Rubro (blanco=todos)
            Lina1343.py Por Proveedor (0=todos) y Fecha Ultima Compra(blanco=todas)
*HECHO*lina231 salida en txt campo totales queda chico cuando se listan todos los comprobantes