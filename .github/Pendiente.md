- Ver que pasa con linasafe al crear o eliminar empresa
- lina231 salida en txt campo totales queda chico cuando se listan todos los comprobantes
- Verás que la parte de compras Menu lina31 hasta lina372 es homóloga a la parte de ventas, lina21 hasta lina272, que ya tenemos
    Necesito que generes los programas de lina31 hasta lina372,
    considerando
    Lo que era Ventas, ahora son Compras
    Lo que era Cobranzas ahora son Pagos
    Lo que era linaclie y linactcl ahora son liniaprov y linactpr
    Lo que era debe ahora es haber y viceversa
    Lo que era emision de comprobantes (remitos, recibos) ahora es registracion (recibimos los comprobantes, no los generamos)

- CurrEmpr
    Que hacer al cambiar empresa:
        a. negar desplegar selección si hay tabs abiertos===>msg
        b. permitir seleccion y buscar si el usuario tiene algun permiso en esa empresa, si no===>msg
        c. definir nueva plantilla de permisos
- CurrDate
    Que hacer al cambiar fecha:
        a. validar que el usuario tenga permiso de cambiar fecha
        b. negar update de fecha si hay tabs abiertos===>msg
        c. Si cntx_date#udate mostrar en rojo
- Usar la barra de mensajes
- Que ocurrio con .venv en la migracion. ¿conviene recrearlo?
***OK *** Listados
***OK *** Que los botones tambien presenten tool tips con su función
***OK *** Session date
***OK *** Que el botón mostrar/ocultar en pantalla login no tenga tabstop para que con enter se llegue directamente a "ingresar"
***OK *** Que al cerrar el navegador se haga logout en la aplicación
***OK *** Ancho de los cuadros de ingreso en forms
***OK *** Grilla selector con click en cabecera
***OK *** Grilla selector con botón derecho=>menú
***OK *** Grilla selector con "buscar"
***OK *** SP sp_copy_user_rights: desde source_emprcodi+source_usercodi hasta target_emprcodi+target_usercodi copiar safealta,baja,modi,cons
***OK *** Revisa que la lógica de funcionamiento de lina111 sea homogénea con lina131 que no sé si lo fuimos llevando así.
***OK *** Los anchos de los controles de ingreso de datos en las pantallas que sean producto de la "medida" de la longitud del dato según la fuente
***OK *** Con el click en la cruz del campo "buscar" que se refresque la lista y el foco al primer registro del selector
***OK *** ¿se pueden usar "tool tips" que se muestren al hacer hover con el mouse en los controles (tanto etiquetas como cuadros de texto)?
***OK *** Implementar git
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
***OK ***Forms modales de asistencia y selectores de single record
***OK *** Carpeta temp->miscelaneas
***OK *** buscar y eliminar deadcode
***OK *** separar js de html
***OK *** buscar hardcode y consultar parametrizacion
***OK *** que siga en brl def get_existencias_batch usa sql crudo teniendo fn_calc_exis para una individual o si tiene que usar sql crudo migrar fn a CapaDAL
***OK *** FMT_NROCOMP = "08d" debe ser "06d"
***OK *** Listados a txt
***OK *** modulo imprimir comprobantes: migrado de zprtC.prg
***OK *** implementar BR-012 y BR-013
***OK *** en todos los menues contextuales sacar el ícono que aparece a la izquierda de la leyenda
***OK *** En seleccion de empresa no actualiza desde linaempr al arranque
