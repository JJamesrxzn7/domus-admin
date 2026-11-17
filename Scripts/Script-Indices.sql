/* ============================================================
   ÍNDICES DE CLAVES PRIMARIAS
   ============================================================ */

-- Las claves primarias generan automáticamente un índice
-- en MariaDB/MySQL, por lo que NO se crean nuevamente.
-- Se documentan aquí para mantener la equivalencia
-- con otros motores de bases de datos.

-- PK_CIUDADES          -> índice sobre (id_Ciudad)
-- PK_PROVEEDORES       -> índice sobre (id_Proveedor)
-- PK_COMPRAS           -> índice sobre (id_Compra)
-- PK_RECEPCIONES       -> índice sobre (id_Recibo)

-- PK_PROxOC            -> índice sobre (id_Compra, id_Producto)
-- PK_PROxREC           -> índice sobre (id_Recibo, id_Producto)
-- PK_PROxAJU           -> índice sobre (id_Ajuste, id_Producto)


/* ============================================================
   MÓDULO 1: COMPRAS
   ============================================================ */

-- PK_CIUDADES          -> índice sobre (id_Ciudad)
-- PK_PROVEEDORES       -> índice sobre (id_Proveedor)
-- PK_COMPRAS           -> índice sobre (id_Compra)
-- PK_RECEPCIONES       -> índice sobre (id_Recibo)

/* -------------------------
   CIUDADES
   ------------------------- */
CREATE INDEX IDX_CIUDADES_DESCRIPCION ON CIUDADES (ciu_Descripcion);
CREATE INDEX IDX_CIUDADES_PROVINCIA ON CIUDADES (ciu_Provincia);

/* -------------------------
   PROVEEDORES
   ------------------------- */
CREATE INDEX IDX_PROVEEDORES_NOMBRE ON PROVEEDORES (prv_Nombre);
CREATE INDEX IDX_PROVEEDORES_ESTADO ON PROVEEDORES (ESTADO_PRV);
CREATE INDEX IDX_PROVEEDORES_CIUDAD ON PROVEEDORES (id_Ciudad);
CREATE INDEX IDX_PROVEEDORES_RUC_CED ON PROVEEDORES (prv_RUC_CED);

/* -------------------------
   COMPRAS
   ------------------------- */
CREATE INDEX IDX_COMPRAS_ESTADO ON COMPRAS (ESTADO_OC);
CREATE INDEX IDX_COMPRAS_PROVEEDOR ON COMPRAS (id_Proveedor);
CREATE INDEX IDX_COMPRAS_FECHA ON COMPRAS (oc_Fecha);
CREATE INDEX IDX_COMPRAS_FECHA_ENTREGA ON COMPRAS (oc_FechaEntrega);

/* -------------------------
   RECEPCIONES
   ------------------------- */
CREATE INDEX IDX_RECEPCIONES_DESCRIPCION ON RECEPCIONES (rec_Descripcion);
CREATE INDEX IDX_RECEPCIONES_ESTADO ON RECEPCIONES (ESTADO_REC);
CREATE INDEX IDX_RECEPCIONES_COMPRA ON RECEPCIONES (id_Compra);
CREATE INDEX IDX_RECEPCIONES_FECHAHORA ON RECEPCIONES (rec_FechaHora);

/* ============================================================
   MÓDULO 2: INVENTARIOS
   ============================================================ */

/* -------------------------
   UNIDADES_MEDIDAS
   ------------------------- */
CREATE INDEX IDX_UNIDADES_DESCRIPCION ON UNIDADES_MEDIDAS (um_Descripcion);

/* -------------------------
   CATEGORIAS (Nuevo)
   ------------------------- */
CREATE INDEX IDX_CATEGORIAS_NOMBRE ON CATEGORIAS (cat_Nombre);
CREATE INDEX IDX_CATEGORIAS_ESTADO ON CATEGORIAS (ESTADO_CAT);

/* -------------------------
   MARCAS (Nuevo)
   ------------------------- */
CREATE INDEX IDX_MARCAS_NOMBRE ON MARCAS (mar_Nombre);
CREATE INDEX IDX_MARCAS_ESTADO ON MARCAS (ESTADO_MAR);

/* -------------------------
   PERCHAS (Nuevo)
   ------------------------- */
CREATE INDEX IDX_PERCHAS_UBICACION ON PERCHAS (pch_Letra, pch_Nivel);
CREATE INDEX IDX_PERCHAS_ESTADO ON PERCHAS (ESTADO_PCH);

/* -------------------------
   PRODUCTOS
   ------------------------- */
CREATE INDEX IDX_PRODUCTOS_DESCRIPCION ON PRODUCTOS (pro_Descripcion);
CREATE INDEX IDX_PRODUCTOS_ESTADO ON PRODUCTOS (ESTADO_PROD);
CREATE INDEX IDX_PRODUCTOS_CATEGORIA ON PRODUCTOS (id_Categoria);
CREATE INDEX IDX_PRODUCTOS_MARCA ON PRODUCTOS (id_Marca);
CREATE INDEX IDX_PRODUCTOS_UM_COMPRA ON PRODUCTOS (pro_UM_Compra);
CREATE INDEX IDX_PRODUCTOS_UM_VENTA ON PRODUCTOS (pro_UM_Venta);

/* -------------------------
   PROxOC
   ------------------------- */
CREATE INDEX IDX_PROXOC_ESTADO ON PROxOC (ESTADO_PxOC);
CREATE INDEX IDX_PROXOC_PRODUCTO ON PROxOC (id_Producto);

/* -------------------------
   PROxREC
   ------------------------- */
CREATE INDEX IDX_PROXREC_ESTADO ON PROxREC (ESTADO_PxREC);
CREATE INDEX IDX_PROXREC_PRODUCTO ON PROxREC (id_Producto);

/* -------------------------
   AJUSTES
   ------------------------- */
CREATE INDEX IDX_AJUSTES_DESCRIPCION ON AJUSTES (aju_Descripcion);
CREATE INDEX IDX_AJUSTES_ESTADO ON AJUSTES (ESTADO_AJU);
CREATE INDEX IDX_AJUSTES_EMPLEADO ON AJUSTES (id_Empleado);
CREATE INDEX IDX_AJUSTES_FECHAHORA ON AJUSTES (aju_FechaHora);

/* -------------------------
   PROxAJU
   ------------------------- */
CREATE INDEX IDX_PROXAJU_ESTADO ON PROxAJU (ESTADO_PxAJU);
CREATE INDEX IDX_PROXAJU_PRODUCTO ON PROxAJU (id_Producto);

/* ============================================================
   MÓDULO 3: VENTAS
   ============================================================ */

/* -------------------------
   CLIENTES
   ------------------------- */
CREATE INDEX IDX_CLIENTES_NOMBRE ON CLIENTES (cli_Nombre);
CREATE INDEX IDX_CLIENTES_ESTADO ON CLIENTES (ESTADO_CLI);
CREATE INDEX IDX_CLIENTES_CIUDAD ON CLIENTES (id_Ciudad);
CREATE INDEX IDX_CLIENTES_RUC_CED ON CLIENTES (cli_RUC_CED);

/* -------------------------
   FACTURAS
   ------------------------- */
CREATE INDEX IDX_FACTURAS_DESCRIPCION ON FACTURAS (fac_Descripcion);
CREATE INDEX IDX_FACTURAS_ESTADO ON FACTURAS (ESTADO_FAC);
CREATE INDEX IDX_FACTURAS_CLIENTE ON FACTURAS (id_Cliente);
CREATE INDEX IDX_FACTURAS_EMPLEADO ON FACTURAS (id_Empleado);
CREATE INDEX IDX_FACTURAS_FECHA ON FACTURAS (fac_Fecha);

/* -------------------------
   PROxFAC
   ------------------------- */
CREATE INDEX IDX_PROXFAC_ESTADO ON PROxFAC (ESTADO_PxFAC);
CREATE INDEX IDX_PROXFAC_PRODUCTO ON PROxFAC (id_Producto);

/* -------------------------
   ENTREGAS
   ------------------------- */
CREATE INDEX IDX_ENTREGAS_DESCRIPCION ON ENTREGAS (ent_Descripcion);
CREATE INDEX IDX_ENTREGAS_ESTADO ON ENTREGAS (ESTADO_ENT);
CREATE INDEX IDX_ENTREGAS_FACTURA ON ENTREGAS (id_Factura);
CREATE INDEX IDX_ENTREGAS_FECHAHORA ON ENTREGAS (ent_FechaHora);

/* -------------------------
   PROxENT
   ------------------------- */
CREATE INDEX IDX_PROXENT_ESTADO ON PROxENT (ESTADO_PxENT);
CREATE INDEX IDX_PROXENT_PRODUCTO ON PROxENT (id_Producto);

/* ============================================================
   MÓDULO 4: TALENTO HUMANO
   ============================================================ */

/* -------------------------
   DEPARTAMENTOS
   ------------------------- */
CREATE INDEX IDX_DEPARTAMENTOS_NOMBRE ON DEPARTAMENTOS (dep_Nombre);
CREATE INDEX IDX_DEPARTAMENTOS_ESTADO ON DEPARTAMENTOS (ESTADO_DEP);
CREATE INDEX IDX_DEPARTAMENTOS_RESPONSABLE ON DEPARTAMENTOS (id_Empleado);

/* -------------------------
   CENTROS_COSTOS (Nuevo)
   ------------------------- */
CREATE INDEX IDX_CCOSTOS_NOMBRE ON CENTROS_COSTOS (cco_Nombre);
CREATE INDEX IDX_CCOSTOS_DEPTO ON CENTROS_COSTOS (id_Departamento);
CREATE INDEX IDX_CCOSTOS_ESTADO ON CENTROS_COSTOS (ESTADO_CCO);

/* -------------------------
   CARGOS (Modificado de ROLES)
   ------------------------- */
CREATE INDEX IDX_CARGOS_DESCRIPCION ON CARGOS (cgo_Descripcion);
CREATE INDEX IDX_CARGOS_ESTADO ON CARGOS (ESTADO_CGO);

/* -------------------------
   EMPLEADOS
   ------------------------- */
CREATE INDEX IDX_EMPLEADOS_APELLIDO ON EMPLEADOS (emp_Apellido1);
CREATE INDEX IDX_EMPLEADOS_NOMBRE ON EMPLEADOS (emp_Nombre1);
CREATE INDEX IDX_EMPLEADOS_ESTADO ON EMPLEADOS (ESTADO_EMP);
CREATE INDEX IDX_EMPLEADOS_DEPARTAMENTO ON EMPLEADOS (id_Departamento);
CREATE INDEX IDX_EMPLEADOS_CEDULA ON EMPLEADOS (emp_Cedula);

/* -------------------------
   CARGOSxEMPLEADO (Modificado de ROLESxEMPLEADO)
   ------------------------- */
CREATE INDEX IDX_CARGOSXEMPLEADO_EMPLEADO ON CARGOSxEMPLEADO (id_Empleado);
CREATE INDEX IDX_CARGOSXEMPLEADO_ESTADO ON CARGOSxEMPLEADO (ESTADO_CxE);

/* -------------------------
   CARGAS
   ------------------------- */
CREATE INDEX IDX_CARGAS_APELLIDO ON CARGAS (car_Apellido1);
CREATE INDEX IDX_CARGAS_NOMBRE ON CARGAS (car_Nombre1);
CREATE INDEX IDX_CARGAS_EMPLEADO ON CARGAS (id_Empleado);
CREATE INDEX IDX_CARGAS_ESTADO ON CARGAS (ESTADO_CAR);
CREATE INDEX IDX_CARGAS_CEDULA ON CARGAS (car_Cedula);

/* -------------------------
   BANCOS (Nuevo)
   ------------------------- */
CREATE INDEX IDX_BANCOS_NOMBRE ON BANCOS (ban_Nombre);
CREATE INDEX IDX_BANCOS_ESTADO ON BANCOS (ESTADO_BAN);

/* -------------------------
   PAGOS
   ------------------------- */
CREATE INDEX IDX_PAGOS_DESCRIPCION ON PAGOS (pag_Descripcion);
CREATE INDEX IDX_PAGOS_ESTADO ON PAGOS (ESTADO_PAG);
CREATE INDEX IDX_PAGOS_FECHA_INICIO ON PAGOS (pag_Fecha_Inicio);
CREATE INDEX IDX_PAGOS_FECHA_FIN ON PAGOS (pag_Fecha_Fin);

/* -------------------------
   PAGxEMP
   ------------------------- */
CREATE INDEX IDX_PAGXEMP_EMPLEADO ON PAGxEMP (id_Empleado);
CREATE INDEX IDX_PAGXEMP_ESTADO ON PAGxEMP (ESTADO_PxE);

/* -------------------------
   BONIFICACIONES
   ------------------------- */
CREATE INDEX IDX_BONIFICACIONES_DESCRIPCION ON BONIFICACIONES (bon_Descripcion);
CREATE INDEX IDX_BONIFICACIONES_ESTADO ON BONIFICACIONES (ESTADO_BON);

/* -------------------------
   BONxEMPxPAG
   ------------------------- */
CREATE INDEX IDX_BONXEMPXPAG_EMPLEADO ON BONxEMPxPAG (id_Empleado);
CREATE INDEX IDX_BONXEMPXPAG_BONIFICACION ON BONxEMPxPAG (id_Bonificacion);
CREATE INDEX IDX_BONXEMPXPAG_ESTADO ON BONxEMPxPAG (ESTADO_BXE);
CREATE INDEX IDX_BONXEMPXPAG_FECHA ON BONxEMPxPAG (bxe_Fecha);

/* -------------------------
   DESCUENTOS
   ------------------------- */
CREATE INDEX IDX_DESCUENTOS_DESCRIPCION ON DESCUENTOS (des_Descripcion);
CREATE INDEX IDX_DESCUENTOS_ESTADO ON DESCUENTOS (ESTADO_DES);

/* -------------------------
   DESxEMPxPAG
   ------------------------- */
CREATE INDEX IDX_DESXEMPXPAG_EMPLEADO ON DESxEMPxPAG (id_Empleado);
CREATE INDEX IDX_DESXEMPXPAG_DESCUENTO ON DESxEMPxPAG (id_Descuento);
CREATE INDEX IDX_DESXEMPXPAG_ESTADO ON DESxEMPxPAG (ESTADO_DXE);
CREATE INDEX IDX_DESXEMPXPAG_FECHA ON DESxEMPxPAG (dxe_Fecha);

/* ============================================================
   MÓDULO 5: CONTABILIDAD
   ============================================================ */

/* -------------------------
   TIPO_CUENTA
   ------------------------- */
CREATE INDEX IDX_TIPO_CUENTA_DESCRIPCION ON TIPO_CUENTA (tip_Descripcion);

/* -------------------------
   CUENTAS
   ------------------------- */
CREATE INDEX IDX_CUENTAS_DESCRIPCION ON CUENTAS (cue_Descripcion);
CREATE INDEX IDX_CUENTAS_TIPO ON CUENTAS (cue_Tipo);
CREATE INDEX IDX_CUENTAS_ESTADO ON CUENTAS (ESTADO_CUE);

/* -------------------------
   ASIENTOS
   ------------------------- */
CREATE INDEX IDX_ASIENTOS_DESCRIPCION ON ASIENTOS (asi_Descripcion);
CREATE INDEX IDX_ASIENTOS_ESTADO ON ASIENTOS (ESTADO_ASI);
CREATE INDEX IDX_ASIENTOS_FECHAHORA ON ASIENTOS (asi_FechaHora);

/* -------------------------
   CTAxASI
   ------------------------- */
CREATE INDEX IDX_CTAXASI_CUENTA ON CTAxASI (id_Cuenta);
CREATE INDEX IDX_CTAXASI_ESTADO ON CTAxASI (ESTADO_CXA);

/* ============================================================
   MÓDULO 6: SEGURIDAD Y CONTROL DE ACCESO (RBAC) (Nuevo)
   ============================================================ */

/* -------------------------
   USUARIOS
   ------------------------- */
CREATE INDEX IDX_USUARIOS_USERNAME ON USUARIOS (usr_Username);
CREATE INDEX IDX_USUARIOS_EMPLEADO ON USUARIOS (id_Empleado);
CREATE INDEX IDX_USUARIOS_ESTADO ON USUARIOS (ESTADO_USR);

/* -------------------------
   ROLES (Seguridad)
   ------------------------- */
CREATE INDEX IDX_ROLES_SEG_NOMBRE ON ROLES (rol_Nombre);
CREATE INDEX IDX_ROLES_SEG_ESTADO ON ROLES (ESTADO_ROL);

/* -------------------------
   USUARIOSxROLES
   ------------------------- */
CREATE INDEX IDX_UXR_ROL ON USUARIOSxROLES (id_Rol);
CREATE INDEX IDX_UXR_ESTADO ON USUARIOSxROLES (ESTADO_UxR);

/* -------------------------
   PERMISOS
   ------------------------- */
CREATE INDEX IDX_PERMISOS_MODULO ON PERMISOS (prm_Modulo);
CREATE INDEX IDX_PERMISOS_ACCION ON PERMISOS (prm_Accion);
CREATE INDEX IDX_PERMISOS_ESTADO ON PERMISOS (ESTADO_PRM);

/* -------------------------
   ROLESxPERMISOS
   ------------------------- */
CREATE INDEX IDX_RXP_PERMISO ON ROLESxPERMISOS (id_Permiso);
CREATE INDEX IDX_RXP_ESTADO ON ROLESxPERMISOS (ESTADO_RxP);

/* -------------------------
   LOG_AUDITORIA
   ------------------------- */
CREATE INDEX IDX_LOG_USUARIO ON LOG_AUDITORIA (id_Usuario);
CREATE INDEX IDX_LOG_TABLA ON LOG_AUDITORIA (log_TablaAfectada);
CREATE INDEX IDX_LOG_ACCION ON LOG_AUDITORIA (log_Accion);
CREATE INDEX IDX_LOG_FECHAHORA ON LOG_AUDITORIA (log_FechaHora);