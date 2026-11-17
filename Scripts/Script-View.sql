/* ============================================================
   MÓDULO 1: COMPRAS
   ============================================================ */

/* ============================================================
   VIEW 1: COMPRAS CON INFORMACIÓN DEL PROVEEDOR
   ============================================================ */
CREATE VIEW VW_COMPRAS_PROVEEDORES AS
SELECT
    C.id_Compra,
    C.oc_Fecha,
    C.oc_FechaEntrega,
    P.id_Proveedor,
    P.prv_Nombre AS Proveedor,
    P.prv_RUC_CED AS RUC_CED,
    P.prv_Telefono AS Telefono,
    CI.ciu_Descripcion AS Ciudad,
    C.oc_Subtotal,
    C.oc_IVA,
    C.oc_Total,
    C.ESTADO_OC
FROM COMPRAS C
INNER JOIN PROVEEDORES P
    ON C.id_Proveedor = P.id_Proveedor
INNER JOIN CIUDADES CI
    ON P.id_Ciudad = CI.id_Ciudad;

/* ============================================================
   VIEW 2: DETALLE DE COMPRAS
   ============================================================ */
CREATE VIEW VW_DETALLE_COMPRAS AS
SELECT
    C.id_Compra,
    C.oc_Fecha,
    P.id_Proveedor,
    P.prv_Nombre AS Proveedor,
    PR.id_Producto,
    PR.pro_Descripcion AS Producto,
    D.pxo_Cantidad AS Cantidad,
    D.pxo_Valor AS Valor_Unitario,
    D.pxo_Subtotal AS Subtotal_Producto,
    D.ESTADO_PxOC AS Estado_Detalle
FROM COMPRAS C
INNER JOIN PROVEEDORES P
    ON C.id_Proveedor = P.id_Proveedor
INNER JOIN PROxOC D
    ON C.id_Compra = D.id_Compra
INNER JOIN PRODUCTOS PR
    ON D.id_Producto = PR.id_Producto;

/* ============================================================
   VIEW 3: COMPRAS Y RECEPCIONES
   ============================================================ */
CREATE VIEW VW_COMPRAS_RECEPCIONES AS
SELECT
    C.id_Compra,
    C.oc_Fecha,
    C.oc_FechaEntrega,
    P.prv_Nombre AS Proveedor,
    C.oc_Total,
    C.ESTADO_OC AS Estado_Compra,
    R.id_Recibo,
    R.rec_Descripcion AS Descripcion_Recepcion,
    R.rec_FechaHora AS Fecha_Recepcion,
    R.rec_Num_Produc AS Numero_Productos_Recibidos,
    R.ESTADO_REC AS Estado_Recepcion
FROM COMPRAS C
INNER JOIN PROVEEDORES P
    ON C.id_Proveedor = P.id_Proveedor
LEFT JOIN RECEPCIONES R
    ON C.id_Compra = R.id_Compra;


/* ============================================================
   MÓDULO 2: INVENTARIOS
   ============================================================ */

/* ============================================================
   VIEW 4: CATÁLOGO DE PRODUCTOS (MODIFICADO: Cat y Marcas)
   ============================================================ */
CREATE VIEW VW_PRODUCTOS_INVENTARIO AS
SELECT
    P.id_Producto,
    P.pro_Descripcion AS Producto,
    CAT.cat_Nombre AS Categoria,
    MAR.mar_Nombre AS Marca,
    UC.um_Descripcion AS Unidad_Compra,
    UV.um_Descripcion AS Unidad_Venta,
    P.pro_Valor_Compra AS Valor_Compra,
    P.pro_Precio_Venta AS Precio_Venta,
    P.pro_Saldo_Inicial AS Saldo_Inicial,
    P.pro_Qty_Ingresos AS Cantidad_Ingresos,
    P.pro_Qty_Egresos AS Cantidad_Egresos,
    P.pro_Qty_Ajustes AS Cantidad_Ajustes,
    P.pro_Saldo_Final AS Saldo_Final,
    P.ESTADO_PROD AS Estado
FROM PRODUCTOS P
INNER JOIN UNIDADES_MEDIDAS UC ON P.pro_UM_Compra = UC.id_Unidad_Medida
INNER JOIN UNIDADES_MEDIDAS UV ON P.pro_UM_Venta = UV.id_Unidad_Medida
INNER JOIN CATEGORIAS CAT ON P.id_Categoria = CAT.id_Categoria
INNER JOIN MARCAS MAR ON P.id_Marca = MAR.id_Marca;

/* ============================================================
   VIEW 5: PRODUCTOS COMPRADOS
   ============================================================ */
CREATE VIEW VW_PRODUCTOS_COMPRADOS AS
SELECT
    C.id_Compra,
    C.oc_Fecha AS Fecha_Compra,
    C.id_Proveedor,
    P.id_Producto,
    P.pro_Descripcion AS Producto,
    D.pxo_Cantidad AS Cantidad_Comprada,
    D.pxo_Valor AS Valor_Unitario,
    D.pxo_Subtotal AS Subtotal,
    D.ESTADO_PxOC AS Estado_Detalle
FROM COMPRAS C
INNER JOIN PROxOC D ON C.id_Compra = D.id_Compra
INNER JOIN PRODUCTOS P ON D.id_Producto = P.id_Producto;

/* ============================================================
   VIEW 6: PRODUCTOS RECIBIDOS
   ============================================================ */
CREATE VIEW VW_PRODUCTOS_RECIBIDOS AS
SELECT
    R.id_Recibo,
    R.id_Compra,
    R.rec_FechaHora AS Fecha_Recepcion,
    P.id_Producto,
    P.pro_Descripcion AS Producto,
    D.pxr_Cantidad AS Cantidad_Registrada,
    D.pxr_Qty_Recibida AS Cantidad_Recibida,
    D.pxr_Motivo AS Motivo,
    D.ESTADO_PxREC AS Estado_Detalle
FROM RECEPCIONES R
INNER JOIN PROxREC D ON R.id_Recibo = D.id_Recibo
INNER JOIN PRODUCTOS P ON D.id_Producto = P.id_Producto;

/* ============================================================
   VIEW 7: AJUSTES DE INVENTARIO
   ============================================================ */
CREATE VIEW VW_AJUSTES_INVENTARIO AS
SELECT
    A.id_Ajuste,
    A.aju_FechaHora AS Fecha_Ajuste,
    A.aju_Descripcion AS Descripcion_Ajuste,
    A.id_Empleado,
    E.emp_Nombre1 AS Nombre_Empleado,
    E.emp_Apellido1 AS Apellido_Empleado,
    P.id_Producto,
    P.pro_Descripcion AS Producto,
    D.pxa_Cantidad AS Cantidad_Ajuste,
    D.pxa_Qty_Ajustada AS Cantidad_Ajustada,
    D.ESTADO_PxAJU AS Estado_Detalle
FROM AJUSTES A
INNER JOIN PROxAJU D ON A.id_Ajuste = D.id_Ajuste
INNER JOIN PRODUCTOS P ON D.id_Producto = P.id_Producto
INNER JOIN EMPLEADOS E ON A.id_Empleado = E.id_Empleado;


/* ============================================================
   MÓDULO 3: VENTAS
   ============================================================ */

/* ============================================================
   VIEW 8: FACTURAS CON INFORMACIÓN DEL CLIENTE
   ============================================================ */
CREATE VIEW VW_FACTURAS_CLIENTES AS
SELECT
    F.id_Factura,
    F.fac_Fecha,
    C.id_Cliente,
    C.cli_Nombre AS Cliente,
    C.cli_RUC_CED AS RUC_CED,
    C.cli_Telefono AS Telefono,
    CI.ciu_Descripcion AS Ciudad,
    F.id_Empleado,
    F.fac_Descripcion AS Descripcion,
    F.fac_Subtotal,
    F.fac_IVA,
    F.fac_Total,
    F.ESTADO_FAC AS Estado
FROM FACTURAS F
INNER JOIN CLIENTES C ON F.id_Cliente = C.id_Cliente
INNER JOIN CIUDADES CI ON C.id_Ciudad = CI.id_Ciudad;

/* ============================================================
   VIEW 9: DETALLE DE VENTAS
   ============================================================ */
CREATE VIEW VW_DETALLE_VENTAS AS
SELECT
    F.id_Factura,
    F.fac_Fecha AS Fecha_Factura,
    C.id_Cliente,
    C.cli_Nombre AS Cliente,
    P.id_Producto,
    P.pro_Descripcion AS Producto,
    D.pxf_Cantidad AS Cantidad,
    D.pxf_Precio AS Precio_Unitario,
    D.pxf_Subtotal AS Subtotal_Producto,
    D.ESTADO_PxFAC AS Estado_Detalle
FROM FACTURAS F
INNER JOIN CLIENTES C ON F.id_Cliente = C.id_Cliente
INNER JOIN PROxFAC D ON F.id_Factura = D.id_Factura
INNER JOIN PRODUCTOS P ON D.id_Producto = P.id_Producto;

/* ============================================================
   VIEW 10: FACTURAS Y ENTREGAS
   ============================================================ */
CREATE VIEW VW_FACTURAS_ENTREGAS AS
SELECT
    F.id_Factura,
    F.fac_Fecha AS Fecha_Factura,
    C.cli_Nombre AS Cliente,
    F.fac_Total,
    F.ESTADO_FAC AS Estado_Factura,
    E.id_Entrega,
    E.ent_Descripcion AS Descripcion_Entrega,
    E.ent_FechaHora AS Fecha_Entrega,
    E.ent_Num_Produc AS Numero_Productos_Entregados,
    E.ESTADO_ENT AS Estado_Entrega
FROM FACTURAS F
INNER JOIN CLIENTES C ON F.id_Cliente = C.id_Cliente
LEFT JOIN ENTREGAS E ON F.id_Factura = E.id_Factura;

/* ============================================================
   VIEW 11: DETALLE DE ENTREGAS
   ============================================================ */
CREATE VIEW VW_DETALLE_ENTREGAS AS
SELECT
    E.id_Entrega,
    E.id_Factura,
    E.ent_FechaHora AS Fecha_Entrega,
    C.cli_Nombre AS Cliente,
    P.id_Producto,
    P.pro_Descripcion AS Producto,
    D.pxe_Cantidad AS Cantidad,
    D.pxe_Qty_Entregada AS Cantidad_Entregada,
    D.pxe_Motivo AS Motivo,
    D.ESTADO_PxENT AS Estado_Detalle
FROM ENTREGAS E
INNER JOIN FACTURAS F ON E.id_Factura = F.id_Factura
INNER JOIN CLIENTES C ON F.id_Cliente = C.id_Cliente
INNER JOIN PROxENT D ON E.id_Entrega = D.id_Entrega
INNER JOIN PRODUCTOS P ON D.id_Producto = P.id_Producto;


/* ============================================================
   MÓDULO 4: TALENTO HUMANO
   ============================================================ */

/* ============================================================
   VIEW 12: INFORMACIÓN DE EMPLEADOS
   ============================================================ */
CREATE VIEW VW_EMPLEADOS_DEPARTAMENTOS AS
SELECT
    E.id_Empleado,
    E.emp_Cedula AS Cedula,
    E.emp_Apellido1 AS Apellido1,
    E.emp_Apellido2 AS Apellido2,
    E.emp_Nombre1 AS Nombre1,
    E.emp_Nombre2 AS Nombre2,
    E.emp_Sexo AS Sexo,
    E.emp_FechaNacimiento AS Fecha_Nacimiento,
    E.emp_Sueldo AS Sueldo,
    E.emp_Direccion AS Direccion,
    E.emp_Telefono AS Telefono,
    E.emp_Celular AS Celular,
    E.emp_Mail AS Mail,
    D.id_Departamento,
    D.dep_Nombre AS Departamento,
    E.ESTADO_EMP AS Estado
FROM EMPLEADOS E
INNER JOIN DEPARTAMENTOS D ON E.id_Departamento = D.id_Departamento;

/* ============================================================
   VIEW 13: EMPLEADOS Y CARGOS (MODIFICADO: De Roles a Cargos)
   ============================================================ */
CREATE VIEW VW_EMPLEADOS_CARGOS AS
SELECT
    E.id_Empleado,
    E.emp_Cedula AS Cedula,
    CONCAT(E.emp_Nombre1, ' ', E.emp_Apellido1) AS Empleado,
    C.id_Cargo,
    C.cgo_Descripcion AS Cargo,
    CE.cxe_Fecha_Inicio AS Fecha_Inicio,
    CE.cxe_Fecha_Fin AS Fecha_Fin,
    CE.ESTADO_CxE AS Estado
FROM EMPLEADOS E
INNER JOIN CARGOSxEMPLEADO CE ON E.id_Empleado = CE.id_Empleado
INNER JOIN CARGOS C ON CE.id_Cargo = C.id_Cargo;

/* ============================================================
   VIEW 14: CARGAS FAMILIARES
   ============================================================ */
CREATE VIEW VW_CARGAS_EMPLEADOS AS
SELECT
    E.id_Empleado,
    CONCAT(E.emp_Nombre1, ' ', E.emp_Apellido1) AS Empleado,
    C.id_Carga,
    C.car_Cedula AS Cedula_Carga,
    C.car_Apellido1 AS Apellido1,
    C.car_Nombre1 AS Nombre1,
    C.car_Sexo AS Sexo,
    C.car_FechaNacimiento AS Fecha_Nacimiento,
    C.car_Parentesco AS Parentesco,
    C.ESTADO_CAR AS Estado
FROM EMPLEADOS E
INNER JOIN CARGAS C ON E.id_Empleado = C.id_Empleado;

/* ============================================================
   VIEW 15: PAGOS DE EMPLEADOS
   ============================================================ */
CREATE VIEW VW_PAGOS_EMPLEADOS AS
SELECT
    P.id_Pago,
    P.pag_Descripcion AS Pago,
    P.pag_Fecha_Inicio AS Fecha_Inicio,
    P.pag_Fecha_Fin AS Fecha_Fin,
    E.id_Empleado,
    CONCAT(E.emp_Nombre1, ' ', E.emp_Apellido1) AS Empleado,
    PE.pxe_Sueldo AS Sueldo,
    PE.pxe_Bonificaciones AS Bonificaciones,
    PE.pxe_Descuentos AS Descuentos,
    PE.pxe_Valor_Neto AS Valor_Neto,
    PE.ESTADO_PxE AS Estado
FROM PAGOS P
INNER JOIN PAGxEMP PE ON P.id_Pago = PE.id_Pago
INNER JOIN EMPLEADOS E ON PE.id_Empleado = E.id_Empleado;

/* ============================================================
   VIEW 16: BONIFICACIONES POR EMPLEADO
   ============================================================ */
CREATE VIEW VW_BONIFICACIONES_EMPLEADOS AS
SELECT
    P.id_Pago,
    P.pag_Descripcion AS Pago,
    E.id_Empleado,
    CONCAT(E.emp_Nombre1, ' ', E.emp_Apellido1) AS Empleado,
    B.id_Bonificacion,
    B.bon_Descripcion AS Bonificacion,
    BXP.bxe_Fecha AS Fecha,
    BXP.bxe_Valor AS Valor,
    BXP.ESTADO_BXE AS Estado
FROM BONxEMPxPAG BXP
INNER JOIN PAGOS P ON BXP.id_Pago = P.id_Pago
INNER JOIN EMPLEADOS E ON BXP.id_Empleado = E.id_Empleado
INNER JOIN BONIFICACIONES B ON BXP.id_Bonificacion = B.id_Bonificacion;

/* ============================================================
   VIEW 17: DESCUENTOS POR EMPLEADO
   ============================================================ */
CREATE VIEW VW_DESCUENTOS_EMPLEADOS AS
SELECT
    P.id_Pago,
    P.pag_Descripcion AS Pago,
    E.id_Empleado,
    CONCAT(E.emp_Nombre1, ' ', E.emp_Apellido1) AS Empleado,
    D.id_Descuento,
    D.des_Descripcion AS Descuento,
    DXP.dxe_Fecha AS Fecha,
    DXP.dxe_Valor AS Valor,
    DXP.ESTADO_DXE AS Estado
FROM DESxEMPxPAG DXP
INNER JOIN PAGOS P ON DXP.id_Pago = P.id_Pago
INNER JOIN EMPLEADOS E ON DXP.id_Empleado = E.id_Empleado
INNER JOIN DESCUENTOS D ON DXP.id_Descuento = D.id_Descuento;

/* ============================================================
   VIEW 18: CENTROS DE COSTOS Y DEPARTAMENTOS (NUEVA)
   ============================================================ */
CREATE VIEW VW_CENTROS_COSTOS AS
SELECT
    CC.id_CentroCosto,
    CC.cco_Nombre AS Centro_Costo,
    CC.cco_PresupuestoMensual AS Presupuesto,
    D.id_Departamento,
    D.dep_Nombre AS Departamento,
    CC.ESTADO_CCO AS Estado
FROM CENTROS_COSTOS CC
INNER JOIN DEPARTAMENTOS D ON CC.id_Departamento = D.id_Departamento;


/* ============================================================
   MÓDULO 5: CONTABILIDAD
   ============================================================ */

/* ============================================================
   VIEW 19: PLAN DE CUENTAS
   ============================================================ */
CREATE VIEW VW_PLAN_CUENTAS AS
SELECT
    C.id_Cuenta,
    C.cue_Descripcion AS Cuenta,
    T.id_Tipo_Cta,
    T.tip_Descripcion AS Tipo_Cuenta,
    C.ESTADO_CUE AS Estado
FROM CUENTAS C
INNER JOIN TIPO_CUENTA T ON C.cue_Tipo = T.id_Tipo_Cta;

/* ============================================================
   VIEW 20: DETALLE DE ASIENTOS CONTABLES
   ============================================================ */
CREATE VIEW VW_DETALLE_ASIENTOS AS
SELECT
    A.id_Asiento,
    A.asi_FechaHora AS Fecha_Asiento,
    A.asi_Descripcion AS Descripcion_Asiento,
    A.ESTADO_ASI AS Estado_Asiento,
    C.id_Cuenta,
    C.cue_Descripcion AS Cuenta,
    CC.cco_Nombre AS Centro_Costo, -- <- Dato extraído para mayor claridad contable
    D.cxa_Debe AS Debe,
    D.cxa_Haber AS Haber,
    D.ESTADO_CXA AS Estado_Detalle
FROM ASIENTOS A
INNER JOIN CTAxASI D 
    ON A.id_Asiento = D.id_Asiento
INNER JOIN CUENTAS C 
    ON D.id_Cuenta = C.id_Cuenta
LEFT JOIN CENTROS_COSTOS CC 
    ON D.id_CentroCosto = CC.id_CentroCosto;

/* ============================================================
   VIEW 21: RESUMEN DE ASIENTOS
   ============================================================ */
CREATE VIEW VW_RESUMEN_ASIENTOS AS
SELECT
    A.id_Asiento,
    A.asi_FechaHora AS Fecha_Asiento,
    A.asi_Descripcion AS Descripcion,
    A.asi_Total_Debe AS Total_Debe,
    A.asi_Total_Haber AS Total_Haber,
    A.USER_ID AS Usuario,
    A.ESTADO_ASI AS Estado
FROM ASIENTOS A;


/* ============================================================
   MÓDULO 6: SEGURIDAD Y CONTROL DE ACCESO (NUEVAS VISTAS)
   ============================================================ */

/* ============================================================
   VIEW 22: ACCESO DE USUARIOS (Vincula la credencial con el empleado)
   ============================================================ */
CREATE VIEW VW_ACCESO_USUARIOS AS
SELECT
    U.id_Usuario,
    U.usr_Username AS Usuario,
    E.id_Empleado,
    CONCAT(E.emp_Nombre1, ' ', E.emp_Apellido1) AS Empleado,
    D.dep_Nombre AS Departamento,
    U.usr_UltimoAcceso AS Ultimo_Acceso,
    U.usr_IntentosFallidos AS Intentos_Fallidos,
    U.ESTADO_USR AS Estado_Usuario
FROM USUARIOS U
INNER JOIN EMPLEADOS E ON U.id_Empleado = E.id_Empleado
INNER JOIN DEPARTAMENTOS D ON E.id_Departamento = D.id_Departamento;

/* ============================================================
   VIEW 23: MATRIZ DE ROLES Y PERMISOS (Para saber qué hace cada rol)
   ============================================================ */
CREATE VIEW VW_MATRIZ_PERMISOS AS
SELECT 
    R.id_Rol,
    R.rol_Nombre AS Rol,
    P.id_Permiso,
    P.prm_Modulo AS Modulo,
    P.prm_Accion AS Accion,
    P.prm_Descripcion AS Descripcion_Permiso
FROM ROLES R
INNER JOIN ROLESxPERMISOS RP ON R.id_Rol = RP.id_Rol
INNER JOIN PERMISOS P ON RP.id_Permiso = P.id_Permiso;

/* ============================================================
   VIEW 24: LOG DE AUDITORÍA CON USUARIO
   ============================================================ */
CREATE VIEW VW_LOG_AUDITORIA AS
SELECT
    L.id_Log,
    L.log_FechaHora AS Fecha,
    U.usr_Username AS Usuario_Responsable,
    L.log_TablaAfectada AS Tabla,
    L.log_Accion AS Accion_Realizada,
    L.log_IP AS Direccion_IP
FROM LOG_AUDITORIA L
INNER JOIN USUARIOS U ON L.id_Usuario = U.id_Usuario
ORDER BY L.log_FechaHora DESC;