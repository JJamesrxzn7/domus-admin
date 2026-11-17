/* ============================================================
   MODULO 1: COMPRAS
   ============================================================ */

CREATE TABLE CIUDADES (
    id_Ciudad CHAR(3) NOT NULL,
    ciu_Descripcion CHAR(30) NOT NULL,
    ciu_Provincia CHAR(30),
    ciu_Region CHAR(30)
);

CREATE TABLE PROVEEDORES (
    id_Proveedor CHAR(10) NOT NULL,
    prv_Nombre CHAR(40) NOT NULL,
    prv_RUC_CED CHAR(13) NOT NULL,
    prv_Telefono CHAR(10),
    prv_Mail CHAR(60),
    id_Ciudad CHAR(3) NOT NULL,
    prv_Celular CHAR(10),
    prv_Direccion CHAR(60),
    ESTADO_PRV CHAR(3)
);

CREATE TABLE COMPRAS (
    id_Compra CHAR(10) NOT NULL,
    id_Proveedor CHAR(10) NOT NULL,
    oc_Fecha DATETIME NOT NULL,
    oc_FechaEntrega DATETIME,
    oc_Subtotal NUMERIC(7,2) NOT NULL,
    oc_IVA NUMERIC(7,2) NOT NULL,
    oc_Total NUMERIC(7,2) NOT NULL,
    ESTADO_OC CHAR(3)
);

CREATE TABLE RECEPCIONES (
    id_Recibo CHAR(10) NOT NULL,
    id_Compra CHAR(10) NOT NULL,
    rec_Descripcion CHAR(30),
    rec_FechaHora DATETIME NOT NULL,
    rec_Num_Produc INT,
    ESTADO_REC CHAR(3)
);

/* ============================================================
   MODULO 2: INVENTARIOS
   ============================================================ */

CREATE TABLE UNIDADES_MEDIDAS (
    id_Unidad_Medida CHAR(3) NOT NULL,
    um_Descripcion CHAR(20) NOT NULL,
    um_FactorConversion NUMERIC(7,2)
);

CREATE TABLE PERCHAS (
    id_Percha CHAR(10) NOT NULL,
    pch_Letra CHAR(2) NOT NULL,
    pch_Nivel INT NOT NULL,
    pch_Descripcion VARCHAR(60),
    ESTADO_PCH CHAR(3)
);

CREATE TABLE CATEGORIAS (
    id_Categoria CHAR(10) NOT NULL,
    cat_Nombre VARCHAR(50) NOT NULL,
    ESTADO_CAT CHAR(3)
);

CREATE TABLE MARCAS (
    id_Marca CHAR(10) NOT NULL,
    mar_Nombre VARCHAR(50) NOT NULL,
    ESTADO_MAR CHAR(3)
);

CREATE TABLE PRODUCTOS (
    id_Producto CHAR(10) NOT NULL,
    id_Percha CHAR(10) NOT NULL,
    pro_Descripcion CHAR(40) NOT NULL,
    pro_UM_Compra CHAR(3) NOT NULL,
    pro_UM_Venta CHAR(3) NOT NULL,
    pro_Valor_Compra NUMERIC(7,2) NOT NULL,
    pro_Precio_Venta NUMERIC(7,2) NOT NULL,
    pro_Saldo_Inicial INT NOT NULL,
    pro_Qty_Ingresos INT NOT NULL,
    pro_Qty_Egresos INT NOT NULL,
    pro_Qty_Ajustes INT NOT NULL,
    pro_Saldo_Final INT NOT NULL,
    ESTADO_PROD CHAR(3)
);

CREATE TABLE PROxOC (
    id_Compra CHAR(10) NOT NULL,
    id_Producto CHAR(10) NOT NULL,
    pxo_Cantidad INT NOT NULL,
    pxo_Valor NUMERIC(7,2) NOT NULL,
    pxo_Subtotal NUMERIC(7,2) NOT NULL,
    ESTADO_PxOC CHAR(3)
);

CREATE TABLE PROxREC (
    id_Recibo CHAR(10) NOT NULL,
    id_Producto CHAR(10) NOT NULL,
    pxr_Cantidad INT NOT NULL,
    pxr_Qty_Recibida INT NOT NULL,
    pxr_Motivo CHAR(60),
    ESTADO_PxREC CHAR(3)
);

CREATE TABLE AJUSTES (
    id_Ajuste CHAR(15) NOT NULL,
    id_Empleado CHAR(10) NOT NULL,
    aju_Descripcion CHAR(30) NOT NULL,
    aju_FechaHora DATETIME NOT NULL,
    aju_Num_Produc INT,
    ESTADO_AJU CHAR(3)
);

CREATE TABLE PROxAJU (
    id_Ajuste CHAR(15) NOT NULL,
    id_Producto CHAR(10) NOT NULL,
    pxa_Cantidad INT NOT NULL,
    pxa_Qty_Ajustada INT NOT NULL,
    ESTADO_PxAJU CHAR(3)
);

/* ============================================================
   MODULO 3: VENTAS
   ============================================================ */

CREATE TABLE CLIENTES (
    id_Cliente CHAR(10) NOT NULL,
    cli_Nombre CHAR(40) NOT NULL,
    cli_RUC_CED CHAR(13) NOT NULL,
    cli_Telefono CHAR(10),
    cli_Mail CHAR(60),
    id_Ciudad CHAR(3) NOT NULL,
    cli_Celular CHAR(10),
    cli_Direccion CHAR(60),
    cli_MontoMaxCredito NUMERIC(10,2),
    cli_Descuento NUMERIC(5,2),
    ESTADO_CLI CHAR(3)
);

CREATE TABLE FACTURAS (
    id_Factura CHAR(15) NOT NULL,
    id_Cliente CHAR(10) NOT NULL,
    id_Empleado CHAR(10) NOT NULL,
    fac_Descripcion CHAR(60),
    fac_Fecha DATETIME NOT NULL,
    fac_Descuento NUMERIC(7,2),
    fac_Subtotal NUMERIC(7,2) NOT NULL,
    fac_IVA NUMERIC(7,2) NOT NULL,
    fac_FormaPago VARCHAR(20),
    fac_Total NUMERIC(7,2) NOT NULL,
    ESTADO_FAC CHAR(3)
);

CREATE TABLE PROxFAC (
    id_Factura CHAR(15) NOT NULL,
    id_Producto CHAR(10) NOT NULL,
    pxf_Cantidad INT NOT NULL,
    pxf_Precio NUMERIC(7,2) NOT NULL,
    pxf_Subtotal NUMERIC(7,2) NOT NULL,
    ESTADO_PxFAC CHAR(3)
);

CREATE TABLE ENTREGAS (
    id_Entrega CHAR(15) NOT NULL,
    id_Factura CHAR(15) NOT NULL,
    ent_Descripcion CHAR(30) NOT NULL,
    ent_FechaHora DATETIME NOT NULL,
    ent_Num_Produc INT,
    ESTADO_ENT CHAR(3)
);

CREATE TABLE PROxENT (
    id_Entrega CHAR(15) NOT NULL,
    id_Producto CHAR(10) NOT NULL,
    pxe_Cantidad INT NOT NULL,
    pxe_Qty_Entregada INT NOT NULL,
    pxe_Motivo CHAR(60),
    ESTADO_PxENT CHAR(3)
);

/* ============================================================
   MODULO 4: TALENTO HUMANO
   ============================================================ */

CREATE TABLE DEPARTAMENTOS (
    id_Departamento CHAR(10) NOT NULL,
    id_Empleado CHAR(10), 
    dep_Nombre CHAR(30) NOT NULL,
    dep_Telefono CHAR(10),
    dep_Mail CHAR(60),
    ESTADO_DEP CHAR(3)
);

CREATE TABLE CARGOS (
    id_Cargo CHAR(10) NOT NULL,
    cgo_Descripcion CHAR(40) NOT NULL,
    ESTADO_CGO CHAR(3)
);

CREATE TABLE EMPLEADOS (
    id_Empleado CHAR(10) NOT NULL,
    id_Departamento CHAR(10) NOT NULL,
    emp_Cedula VARCHAR(20) NOT NULL,
    emp_Apellido1 CHAR(30) NOT NULL,
    emp_Apellido2 CHAR(30),
    emp_Nombre1 CHAR(30) NOT NULL,
    emp_Nombre2 CHAR(30),
    emp_Sexo CHAR(1),
    emp_FechaNacimiento DATE NOT NULL,
    emp_Sueldo NUMERIC(7,2) NOT NULL,
    emp_Direccion CHAR(60),
    emp_Telefono CHAR(10),
    emp_Celular CHAR(10),
    emp_Fotografia VARCHAR(255),
    emp_Mail CHAR(60),
    USER_ID CHAR(16),
    ESTADO_EMP CHAR(3)
);

CREATE TABLE CARGOSxEMPLEADO (
    id_Cargo CHAR(10) NOT NULL,
    id_Empleado CHAR(10) NOT NULL,
    cxe_Fecha_Inicio DATE NOT NULL,
    cxe_Fecha_Fin DATE,
    USER_ID CHAR(16),
    ESTADO_CxE CHAR(3)
);

CREATE TABLE CARGAS (
    id_Carga CHAR(10) NOT NULL,
    id_Empleado CHAR(10) NOT NULL,
    car_Cedula VARCHAR(20) NOT NULL,
    car_Apellido1 CHAR(30) NOT NULL,
    car_Apellido2 CHAR(30),
    car_Nombre1 CHAR(30) NOT NULL,
    car_Nombre2 CHAR(30),
    car_Sexo CHAR(1),
    car_FechaNacimiento DATE NOT NULL,
    car_Parentesco CHAR(20),
    car_EstadoCivil CHAR(20),
    car_Dependencia CHAR(20),
    USER_ID CHAR(16),
    ESTADO_CAR CHAR(3)
);

CREATE TABLE PAGOS (
    id_Pago CHAR(10) NOT NULL,
    pag_Descripcion CHAR(40) NOT NULL,
    pag_Fecha_Inicio DATE NOT NULL,
    pag_Fecha_Fin DATE NOT NULL,
    USER_ID CHAR(16),
    ESTADO_PAG CHAR(3)
);

CREATE TABLE PAGxEMP (
    id_Pago CHAR(10) NOT NULL,
    id_Empleado CHAR(10) NOT NULL,
    pxe_Sueldo NUMERIC(7,2) NOT NULL,
    pxe_Bonificaciones NUMERIC(7,2) NOT NULL,
    pxe_Descuentos NUMERIC(7,2) NOT NULL,
    pxe_Valor_Neto NUMERIC(7,2) NOT NULL,
    ESTADO_PxE CHAR(3)
);

CREATE TABLE BONIFICACIONES (
    id_Bonificacion CHAR(10) NOT NULL,
    bon_Descripcion CHAR(40) NOT NULL,
    bon_Valor NUMERIC(7,2) NOT NULL,
    ESTADO_BON CHAR(3)
);

CREATE TABLE BONxEMPxPAG (
    id_Pago CHAR(10) NOT NULL,
    id_Empleado CHAR(10) NOT NULL,
    id_Bonificacion CHAR(10) NOT NULL,
    bxe_Fecha DATE NOT NULL,
    bxe_Valor NUMERIC(7,2) NOT NULL,
    ESTADO_BXE CHAR(3)
);

CREATE TABLE DESCUENTOS (
    id_Descuento CHAR(10) NOT NULL,
    des_Descripcion CHAR(40) NOT NULL,
    des_Valor NUMERIC(7,2) NOT NULL,
    ESTADO_DES CHAR(3)
);

CREATE TABLE DESxEMPxPAG (
    id_Pago CHAR(10) NOT NULL,
    id_Empleado CHAR(10) NOT NULL,
    id_Descuento CHAR(10) NOT NULL,
    dxe_Fecha DATE NOT NULL,
    dxe_Valor NUMERIC(7,2) NOT NULL,
    ESTADO_DXE CHAR(3)
);

/* ============================================================
   MODULO 5: CONTABILIDAD
   ============================================================ */

CREATE TABLE BANCOS (
    id_Banco CHAR(10) NOT NULL,
    ban_Nombre VARCHAR(50) NOT NULL,
    ESTADO_BAN CHAR(3)
);

CREATE TABLE CENTROS_COSTOS (
    id_CentroCosto CHAR(10) NOT NULL,
    id_Departamento CHAR(10) NOT NULL,
    cco_Nombre VARCHAR(50) NOT NULL,
    cco_PresupuestoMensual NUMERIC(10,2),
    ESTADO_CCO CHAR(3)
);

CREATE TABLE TIPO_CUENTA (
    id_Tipo_Cta CHAR(3) NOT NULL,
    tip_Descripcion CHAR(10) NOT NULL
);

    CREATE TABLE CUENTAS (
        id_Cuenta CHAR(15) NOT NULL,
        cue_Descripcion CHAR(60) NOT NULL,
        cue_Tipo CHAR(3) NOT NULL,
        cue_DEBE00 NUMERIC(7,2), cue_DEBE01 NUMERIC(7,2),
        cue_DEBE02 NUMERIC(7,2), cue_DEBE03 NUMERIC(7,2),
        cue_DEBE04 NUMERIC(7,2), cue_DEBE05 NUMERIC(7,2),
        cue_DEBE06 NUMERIC(7,2), cue_DEBE07 NUMERIC(7,2),
        cue_DEBE08 NUMERIC(7,2), cue_DEBE09 NUMERIC(7,2),
        cue_DEBE10 NUMERIC(7,2), cue_DEBE11 NUMERIC(7,2),
        cue_DEBE12 NUMERIC(7,2), cue_DEBE13 NUMERIC(7,2),
        cue_HABER00 NUMERIC(7,2), cue_HABER01 NUMERIC(7,2),
        cue_HABER02 NUMERIC(7,2), cue_HABER03 NUMERIC(7,2),
        cue_HABER04 NUMERIC(7,2), cue_HABER05 NUMERIC(7,2),
        cue_HABER06 NUMERIC(7,2), cue_HABER07 NUMERIC(7,2),
        cue_HABER08 NUMERIC(7,2), cue_HABER09 NUMERIC(7,2),
        cue_HABER10 NUMERIC(7,2), cue_HABER11 NUMERIC(7,2),
        cue_HABER12 NUMERIC(7,2), cue_HABER13 NUMERIC(7,2),
        ESTADO_CUE CHAR(3)
    );

CREATE TABLE ASIENTOS (
    id_Asiento CHAR(10) NOT NULL,
    asi_Descripcion CHAR(30) NOT NULL,
    asi_Total_Debe NUMERIC(7,2) NOT NULL,
    asi_Total_Haber NUMERIC(7,2) NOT NULL,
    asi_FechaHora TIMESTAMP NOT NULL,
    USER_ID CHAR(16),
    ESTADO_ASI CHAR(3)
);

CREATE TABLE CTAxASI (
    id_Asiento CHAR(10) NOT NULL,
    id_Cuenta CHAR(15) NOT NULL,
    id_CentroCosto CHAR(10) NOT NULL,
    cxa_Debe NUMERIC(7,2) NOT NULL,
    cxa_Haber NUMERIC(7,2) NOT NULL,
    ESTADO_CXA CHAR(3)
);

/* ============================================================
   MODULO 6: SEGURIDAD Y CONTROL DE ACCESO
   ============================================================ */
CREATE TABLE USUARIOS (
    id_Usuario CHAR(16) NOT NULL,
    id_Empleado CHAR(10) NOT NULL,
    usr_Username VARCHAR(50) NOT NULL,
    usr_PasswordHash VARCHAR(255) NOT NULL,
    usr_IntentosFallidos INT DEFAULT 0,
    usr_UltimoAcceso DATETIME,
    usr_RequiereCambioClave BOOLEAN DEFAULT TRUE,
    usr_FechaCambioClave DATETIME,
    usr_TokenRecuperacion VARCHAR(255),
    ESTADO_USR CHAR(3)
);

CREATE TABLE ROLES (
    id_Rol CHAR(10) NOT NULL,
    rol_Nombre VARCHAR(50) NOT NULL,
    rol_Descripcion VARCHAR(100),
    ESTADO_ROL CHAR(3)
);

CREATE TABLE USUARIOSxROLES (
    id_Usuario CHAR(16) NOT NULL,
    id_Rol CHAR(10) NOT NULL,
    ESTADO_UxR CHAR(3)
);

CREATE TABLE PERMISOS (
    id_Permiso CHAR(10) NOT NULL,
    prm_Modulo VARCHAR(50) NOT NULL,
    prm_Accion VARCHAR(50) NOT NULL,
    prm_Descripcion VARCHAR(100),
    ESTADO_PRM CHAR(3)
);

CREATE TABLE ROLESxPERMISOS (
    id_Rol CHAR(10) NOT NULL,
    id_Permiso CHAR(10) NOT NULL,
    ESTADO_RxP CHAR(3)
);

CREATE TABLE LOG_AUDITORIA (
    id_Log CHAR(15) NOT NULL,
    id_Usuario CHAR(16) NOT NULL,
    log_FechaHora DATETIME NOT NULL,
    log_TablaAfectada VARCHAR(50) NOT NULL,
    log_Accion VARCHAR(20) NOT NULL,
    log_IP VARCHAR(45),                 
    log_ValorAnterior TEXT,
    log_ValorNuevo TEXT                 
);