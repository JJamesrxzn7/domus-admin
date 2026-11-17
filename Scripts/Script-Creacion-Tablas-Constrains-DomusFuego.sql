/* ===========================================================================
   DOMUS FUEGO - RESTAURANTE & STEAKHOUSE
   SCRIPT DE CREACION DE TABLAS Y CONSTRAINTS
   Generado a partir del Modelo Fisico: PhysicalDataModel_4.pdm
   Total Tablas: 32
   =========================================================================== */

/* --------------------------------------------------------------------------
   TABLA: unidad_medida (unidad_medida)
   -------------------------------------------------------------------------- */
CREATE TABLE unidad_medida (
    id_unidad SERIAL NOT NULL,
    nombre VARCHAR(20) NOT NULL,
    simbolo VARCHAR(10) NOT NULL,
    factor_base NUMERIC(14,6) NOT NULL,
    tipo_magnitud VARCHAR(10) NOT NULL,
    CONSTRAINT pk_unidad_medida PRIMARY KEY (id_unidad)
);

/* --------------------------------------------------------------------------
   TABLA: categoria_item (categoria_item)
   -------------------------------------------------------------------------- */
CREATE TABLE categoria_item (
    id_categoria SERIAL NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    CONSTRAINT pk_categoria_item PRIMARY KEY (id_categoria)
);

/* --------------------------------------------------------------------------
   TABLA: proveedor (proveedor)
   -------------------------------------------------------------------------- */
CREATE TABLE proveedor (
    id_proveedor SERIAL NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    contacto VARCHAR(120) NULL,
    telefono VARCHAR(30) NULL,
    email VARCHAR(120) NULL,
    activo BOOLEAN NOT NULL,
    CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor)
);

/* --------------------------------------------------------------------------
   TABLA: tipo_movimiento (tipo_movimiento)
   -------------------------------------------------------------------------- */
CREATE TABLE tipo_movimiento (
    id_tipo_movimiento SERIAL NOT NULL,
    nombre VARCHAR(30) NOT NULL,
    signo SMALLINT NOT NULL,
    afecta_stock BOOLEAN NOT NULL,
    CONSTRAINT pk_tipo_movimiento PRIMARY KEY (id_tipo_movimiento)
);

/* --------------------------------------------------------------------------
   TABLA: cliente (cliente)
   -------------------------------------------------------------------------- */
CREATE TABLE cliente (
    id_cliente SERIAL NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    telefono VARCHAR(30) NULL,
    email VARCHAR(120) NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente)
);

/* --------------------------------------------------------------------------
   TABLA: mesa (mesa)
   -------------------------------------------------------------------------- */
CREATE TABLE mesa (
    id_mesa SERIAL NOT NULL,
    numero VARCHAR(10) NOT NULL,
    capacidad INTEGER NOT NULL,
    ubicacion VARCHAR(60) NULL,
    activa BOOLEAN NOT NULL,
    CONSTRAINT pk_mesa PRIMARY KEY (id_mesa)
);

/* --------------------------------------------------------------------------
   TABLA: caja_sesion (caja_sesion)
   -------------------------------------------------------------------------- */
CREATE TABLE caja_sesion (
    id_caja_sesion SERIAL NOT NULL,
    fecha_apertura TIMESTAMP NOT NULL,
    fecha_cierre TIMESTAMP NULL,
    monto_apertura NUMERIC(12,2) NOT NULL,
    monto_cierre NUMERIC(12,2) NULL,
    estado VARCHAR(15) NOT NULL,
    CONSTRAINT pk_caja_sesion PRIMARY KEY (id_caja_sesion)
);

/* --------------------------------------------------------------------------
   TABLA: item (item)
   -------------------------------------------------------------------------- */
CREATE TABLE item (
    id_item SERIAL NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    id_categoria INTEGER NOT NULL,
    tipo_item VARCHAR(20) NOT NULL,
    id_unidad_base INTEGER NOT NULL,
    maneja_lote BOOLEAN NOT NULL,
    perecedero BOOLEAN NOT NULL,
    vida_util_dias INTEGER NULL,
    politica_consumo VARCHAR(10) NOT NULL,
    stock_minimo NUMERIC(14,4) NOT NULL,
    activo BOOLEAN NOT NULL,
    CONSTRAINT pk_item PRIMARY KEY (id_item)
);

/* --------------------------------------------------------------------------
   TABLA: item_proveedor (item_proveedor)
   -------------------------------------------------------------------------- */
CREATE TABLE item_proveedor (
    id_item_proveedor SERIAL NOT NULL,
    id_item INTEGER NOT NULL,
    id_proveedor INTEGER NOT NULL,
    codigo_proveedor VARCHAR(60) NULL,
    precio_referencia NUMERIC(12,4) NULL,
    CONSTRAINT pk_item_proveedor PRIMARY KEY (id_item_proveedor)
);

/* --------------------------------------------------------------------------
   TABLA: item_presentacion (item_presentacion)
   -------------------------------------------------------------------------- */
CREATE TABLE item_presentacion (
    id_presentacion SERIAL NOT NULL,
    id_item INTEGER NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    id_unidad INTEGER NOT NULL,
    factor_unidad NUMERIC(14,6) NOT NULL,
    es_venta BOOLEAN NOT NULL,
    es_compra BOOLEAN NOT NULL,
    CONSTRAINT pk_item_presentacion PRIMARY KEY (id_presentacion)
);

/* --------------------------------------------------------------------------
   TABLA: receta (receta)
   -------------------------------------------------------------------------- */
CREATE TABLE receta (
    id_receta SERIAL NOT NULL,
    id_item_resultante INTEGER NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    tipo VARCHAR(15) NOT NULL,
    rendimiento NUMERIC(14,4) NOT NULL,
    id_unidad_rendimiento INTEGER NOT NULL,
    activa BOOLEAN NOT NULL,
    CONSTRAINT pk_receta PRIMARY KEY (id_receta)
);

/* --------------------------------------------------------------------------
   TABLA: orden_compra (orden_compra)
   -------------------------------------------------------------------------- */
CREATE TABLE orden_compra (
    id_orden_compra SERIAL NOT NULL,
    id_proveedor INTEGER NOT NULL,
    fecha_emision TIMESTAMP NOT NULL,
    estado VARCHAR(20) NOT NULL,
    observaciones TEXT NULL,
    CONSTRAINT pk_orden_compra PRIMARY KEY (id_orden_compra)
);

/* --------------------------------------------------------------------------
   TABLA: reserva (reserva)
   -------------------------------------------------------------------------- */
CREATE TABLE reserva (
    id_reserva SERIAL NOT NULL,
    id_cliente INTEGER NOT NULL,
    id_mesa INTEGER NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    cantidad_comensales INTEGER NOT NULL,
    estado VARCHAR(15) NOT NULL,
    observaciones TEXT NULL,
    CONSTRAINT pk_reserva PRIMARY KEY (id_reserva)
);

/* --------------------------------------------------------------------------
   TABLA: precio_venta (precio_venta)
   -------------------------------------------------------------------------- */
CREATE TABLE precio_venta (
    id_precio SERIAL NOT NULL,
    id_presentacion INTEGER NOT NULL,
    precio NUMERIC(12,2) NOT NULL,
    vigente_desde TIMESTAMP NOT NULL,
    vigente_hasta TIMESTAMP NULL,
    CONSTRAINT pk_precio_venta PRIMARY KEY (id_precio)
);

/* --------------------------------------------------------------------------
   TABLA: receta_detalle (receta_detalle)
   -------------------------------------------------------------------------- */
CREATE TABLE receta_detalle (
    id_receta_detalle SERIAL NOT NULL,
    id_receta INTEGER NOT NULL,
    id_item_insumo INTEGER NOT NULL,
    cantidad NUMERIC(14,4) NOT NULL,
    id_unidad INTEGER NOT NULL,
    merma_esperada_pct NUMERIC(5,2) NOT NULL,
    CONSTRAINT pk_receta_detalle PRIMARY KEY (id_receta_detalle)
);

/* --------------------------------------------------------------------------
   TABLA: orden_compra_detalle (orden_compra_detalle)
   -------------------------------------------------------------------------- */
CREATE TABLE orden_compra_detalle (
    id_oc_detalle SERIAL NOT NULL,
    id_orden_compra INTEGER NOT NULL,
    id_item INTEGER NOT NULL,
    cantidad_solicitada NUMERIC(14,4) NOT NULL,
    id_unidad INTEGER NOT NULL,
    precio_pactado NUMERIC(12,4) NOT NULL,
    CONSTRAINT pk_orden_compra_detalle PRIMARY KEY (id_oc_detalle)
);

/* --------------------------------------------------------------------------
   TABLA: reserva_detalle (reserva_detalle)
   -------------------------------------------------------------------------- */
CREATE TABLE reserva_detalle (
    id_reserva_detalle SERIAL NOT NULL,
    id_reserva INTEGER NOT NULL,
    id_item INTEGER NOT NULL,
    cantidad NUMERIC(14,4) NOT NULL,
    observaciones TEXT NULL,
    CONSTRAINT pk_reserva_detalle PRIMARY KEY (id_reserva_detalle)
);

/* --------------------------------------------------------------------------
   TABLA: recepcion (recepcion)
   -------------------------------------------------------------------------- */
CREATE TABLE recepcion (
    id_recepcion SERIAL NOT NULL,
    id_orden_compra INTEGER NOT NULL,
    fecha_recepcion TIMESTAMP NOT NULL,
    estado VARCHAR(15) NOT NULL,
    observaciones TEXT NULL,
    CONSTRAINT pk_recepcion PRIMARY KEY (id_recepcion)
);

/* --------------------------------------------------------------------------
   TABLA: pedido (pedido)
   -------------------------------------------------------------------------- */
CREATE TABLE pedido (
    id_pedido SERIAL NOT NULL,
    id_reserva INTEGER NULL,
    fecha_hora TIMESTAMP NOT NULL,
    estado VARCHAR(15) NOT NULL,
    observaciones TEXT NULL,
    CONSTRAINT pk_pedido PRIMARY KEY (id_pedido)
);

/* --------------------------------------------------------------------------
   TABLA: orden_produccion (orden_produccion)
   -------------------------------------------------------------------------- */
CREATE TABLE orden_produccion (
    id_orden_produccion SERIAL NOT NULL,
    id_receta INTEGER NOT NULL,
    tipo VARCHAR(15) NOT NULL,
    estado VARCHAR(15) NOT NULL,
    fecha_planificada TIMESTAMP NULL,
    fecha_ejecucion TIMESTAMP NULL,
    rendimiento_real NUMERIC(14,4) NULL,
    observaciones TEXT NULL,
    CONSTRAINT pk_orden_produccion PRIMARY KEY (id_orden_produccion)
);

/* --------------------------------------------------------------------------
   TABLA: recepcion_detalle (recepcion_detalle)
   -------------------------------------------------------------------------- */
CREATE TABLE recepcion_detalle (
    id_recepcion_detalle SERIAL NOT NULL,
    id_recepcion INTEGER NOT NULL,
    id_oc_detalle INTEGER NOT NULL,
    cantidad_recibida NUMERIC(14,4) NOT NULL,
    id_unidad INTEGER NOT NULL,
    costo_real_unitario NUMERIC(12,4) NOT NULL,
    CONSTRAINT pk_recepcion_detalle PRIMARY KEY (id_recepcion_detalle)
);

/* --------------------------------------------------------------------------
   TABLA: pedido_detalle (pedido_detalle)
   -------------------------------------------------------------------------- */
CREATE TABLE pedido_detalle (
    id_pedido_detalle SERIAL NOT NULL,
    id_pedido INTEGER NOT NULL,
    id_presentacion INTEGER NOT NULL,
    cantidad NUMERIC(14,4) NOT NULL,
    precio_unitario NUMERIC(12,2) NOT NULL,
    origen VARCHAR(15) NOT NULL,
    CONSTRAINT pk_pedido_detalle PRIMARY KEY (id_pedido_detalle)
);

/* --------------------------------------------------------------------------
   TABLA: orden_produccion_detalle (orden_produccion_detalle)
   -------------------------------------------------------------------------- */
CREATE TABLE orden_produccion_detalle (
    id_op_detalle SERIAL NOT NULL,
    id_orden_produccion INTEGER NOT NULL,
    id_item_insumo INTEGER NOT NULL,
    cantidad_teorica NUMERIC(14,4) NOT NULL,
    cantidad_real NUMERIC(14,4) NULL,
    id_unidad INTEGER NOT NULL,
    merma_asociada NUMERIC(14,4) NOT NULL,
    CONSTRAINT pk_orden_produccion_detalle PRIMARY KEY (id_op_detalle)
);

/* --------------------------------------------------------------------------
   TABLA: lote_inventario (lote_inventario)
   -------------------------------------------------------------------------- */
CREATE TABLE lote_inventario (
    id_lote SERIAL NOT NULL,
    id_item INTEGER NOT NULL,
    codigo_lote VARCHAR(60) NOT NULL,
    origen VARCHAR(15) NOT NULL,
    id_recepcion_detalle INTEGER NULL,
    id_orden_produccion INTEGER NULL,
    fecha_ingreso TIMESTAMP NOT NULL,
    fecha_vencimiento DATE NULL,
    cantidad_inicial NUMERIC(14,4) NOT NULL,
    costo_unitario NUMERIC(12,4) NOT NULL,
    id_unidad INTEGER NOT NULL,
    estado VARCHAR(15) NOT NULL,
    CONSTRAINT pk_lote_inventario PRIMARY KEY (id_lote)
);

/* --------------------------------------------------------------------------
   TABLA: movimiento_inventario (movimiento_inventario)
   -------------------------------------------------------------------------- */
CREATE TABLE movimiento_inventario (
    id_movimiento BIGSERIAL NOT NULL,
    id_item INTEGER NOT NULL,
    id_tipo_movimiento INTEGER NOT NULL,
    id_lote INTEGER NULL,
    cantidad NUMERIC(14,4) NOT NULL,
    id_unidad INTEGER NOT NULL,
    costo_unitario NUMERIC(12,4) NOT NULL,
    origen_tipo VARCHAR(30) NOT NULL,
    origen_id BIGINT NOT NULL,
    fecha_movimiento TIMESTAMP NOT NULL,
    id_usuario INTEGER NULL,
    observaciones TEXT NULL,
    CONSTRAINT pk_movimiento_inventario PRIMARY KEY (id_movimiento)
);

/* --------------------------------------------------------------------------
   TABLA: merma (merma)
   -------------------------------------------------------------------------- */
CREATE TABLE merma (
    id_merma SERIAL NOT NULL,
    id_movimiento BIGINT NOT NULL,
    motivo VARCHAR(20) NOT NULL,
    id_usuario_responsable INTEGER NULL,
    descripcion TEXT NULL,
    CONSTRAINT pk_merma PRIMARY KEY (id_merma)
);

/* --------------------------------------------------------------------------
   TABLA: pedido_detalle_orden (pedido_detalle_orden)
   -------------------------------------------------------------------------- */
CREATE TABLE pedido_detalle_orden (
    id_pedido_detalle_orden SERIAL NOT NULL,
    id_pedido_detalle INTEGER NOT NULL,
    id_orden_produccion INTEGER NOT NULL,
    CONSTRAINT pk_pedido_detalle_orden PRIMARY KEY (id_pedido_detalle_orden)
);

/* --------------------------------------------------------------------------
   TABLA: venta (venta)
   -------------------------------------------------------------------------- */
CREATE TABLE venta (
    id_venta SERIAL NOT NULL,
    id_pedido INTEGER NOT NULL,
    id_caja_sesion INTEGER NOT NULL,
    fecha_venta TIMESTAMP NOT NULL,
    estado VARCHAR(15) NOT NULL,
    CONSTRAINT pk_venta PRIMARY KEY (id_venta)
);

/* --------------------------------------------------------------------------
   TABLA: pago (pago)
   -------------------------------------------------------------------------- */
CREATE TABLE pago (
    id_pago SERIAL NOT NULL,
    id_venta INTEGER NOT NULL,
    medio VARCHAR(20) NOT NULL,
    monto NUMERIC(12,2) NOT NULL,
    estado VARCHAR(15) NOT NULL,
    fecha_pago TIMESTAMP NOT NULL,
    CONSTRAINT pk_pago PRIMARY KEY (id_pago)
);

/* --------------------------------------------------------------------------
   TABLA: costo_receta (costo_receta)
   -------------------------------------------------------------------------- */
CREATE TABLE costo_receta (
    id_costo_receta SERIAL NOT NULL,
    id_receta INTEGER NOT NULL,
    fecha_calculo TIMESTAMP NOT NULL,
    costo_total NUMERIC(14,4) NOT NULL,
    costo_porcion NUMERIC(14,4) NOT NULL,
    detalle_json JSONB NULL,
    CONSTRAINT pk_costo_receta PRIMARY KEY (id_costo_receta)
);

/* --------------------------------------------------------------------------
   TABLA: gasto_operativo (gasto_operativo)
   -------------------------------------------------------------------------- */
CREATE TABLE gasto_operativo (
    id_gasto SERIAL NOT NULL,
    concepto VARCHAR(120) NOT NULL,
    categoria VARCHAR(40) NULL,
    monto NUMERIC(12,2) NOT NULL,
    fecha DATE NOT NULL,
    id_caja_sesion INTEGER NULL,
    CONSTRAINT pk_gasto_operativo PRIMARY KEY (id_gasto)
);

/* --------------------------------------------------------------------------
   TABLA: movimiento_contable (movimiento_contable)
   -------------------------------------------------------------------------- */
CREATE TABLE movimiento_contable (
    id_movimiento_contable BIGSERIAL NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    id_venta INTEGER NULL,
    id_costo_receta INTEGER NULL,
    id_gasto INTEGER NULL,
    monto NUMERIC(14,2) NOT NULL,
    signo SMALLINT NOT NULL,
    fecha TIMESTAMP NOT NULL,
    CONSTRAINT pk_movimiento_contable PRIMARY KEY (id_movimiento_contable)
);

/* ===========================================================================
   FOREIGN KEYS & INTEGRITY CONSTRAINTS
   =========================================================================== */

ALTER TABLE item
    ADD CONSTRAINT fk_item_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria_item (id_categoria);
ALTER TABLE item
    ADD CONSTRAINT fk_item_unidad FOREIGN KEY (id_unidad_base)
    REFERENCES unidad_medida (id_unidad);
ALTER TABLE item_proveedor
    ADD CONSTRAINT fk_ip_item FOREIGN KEY (id_item)
    REFERENCES item (id_item);
ALTER TABLE item_proveedor
    ADD CONSTRAINT fk_ip_proveedor FOREIGN KEY (id_proveedor)
    REFERENCES proveedor (id_proveedor);
ALTER TABLE item_presentacion
    ADD CONSTRAINT fk_ipres_item FOREIGN KEY (id_item)
    REFERENCES item (id_item);
ALTER TABLE item_presentacion
    ADD CONSTRAINT fk_ipres_unidad FOREIGN KEY (id_unidad)
    REFERENCES unidad_medida (id_unidad);
ALTER TABLE receta
    ADD CONSTRAINT fk_receta_item FOREIGN KEY (id_item_resultante)
    REFERENCES item (id_item);
ALTER TABLE receta
    ADD CONSTRAINT fk_receta_unidad FOREIGN KEY (id_unidad_rendimiento)
    REFERENCES unidad_medida (id_unidad);
ALTER TABLE orden_compra
    ADD CONSTRAINT fk_oc_proveedor FOREIGN KEY (id_proveedor)
    REFERENCES proveedor (id_proveedor);
ALTER TABLE reserva
    ADD CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente);
ALTER TABLE reserva
    ADD CONSTRAINT fk_reserva_mesa FOREIGN KEY (id_mesa)
    REFERENCES mesa (id_mesa);
ALTER TABLE precio_venta
    ADD CONSTRAINT fk_pv_presentacion FOREIGN KEY (id_presentacion)
    REFERENCES item_presentacion (id_presentacion);
ALTER TABLE receta_detalle
    ADD CONSTRAINT fk_rd_receta FOREIGN KEY (id_receta)
    REFERENCES receta (id_receta);
ALTER TABLE receta_detalle
    ADD CONSTRAINT fk_rd_insumo FOREIGN KEY (id_item_insumo)
    REFERENCES item (id_item);
ALTER TABLE receta_detalle
    ADD CONSTRAINT fk_rd_unidad FOREIGN KEY (id_unidad)
    REFERENCES unidad_medida (id_unidad);
ALTER TABLE orden_compra_detalle
    ADD CONSTRAINT fk_ocd_orden FOREIGN KEY (id_orden_compra)
    REFERENCES orden_compra (id_orden_compra);
ALTER TABLE orden_compra_detalle
    ADD CONSTRAINT fk_ocd_item FOREIGN KEY (id_item)
    REFERENCES item (id_item);
ALTER TABLE orden_compra_detalle
    ADD CONSTRAINT fk_ocd_unidad FOREIGN KEY (id_unidad)
    REFERENCES unidad_medida (id_unidad);
ALTER TABLE reserva_detalle
    ADD CONSTRAINT fk_rdet_reserva FOREIGN KEY (id_reserva)
    REFERENCES reserva (id_reserva);
ALTER TABLE reserva_detalle
    ADD CONSTRAINT fk_rdet_item FOREIGN KEY (id_item)
    REFERENCES item (id_item);
ALTER TABLE recepcion
    ADD CONSTRAINT fk_recepcion_orden FOREIGN KEY (id_orden_compra)
    REFERENCES orden_compra (id_orden_compra);
ALTER TABLE orden_produccion
    ADD CONSTRAINT fk_op_receta FOREIGN KEY (id_receta)
    REFERENCES receta (id_receta);
ALTER TABLE recepcion_detalle
    ADD CONSTRAINT fk_rd_recepcion FOREIGN KEY (id_recepcion)
    REFERENCES recepcion (id_recepcion);
ALTER TABLE recepcion_detalle
    ADD CONSTRAINT fk_rd_ocd FOREIGN KEY (id_oc_detalle)
    REFERENCES orden_compra_detalle (id_oc_detalle);
ALTER TABLE recepcion_detalle
    ADD CONSTRAINT fk_rd_unidad FOREIGN KEY (id_unidad)
    REFERENCES unidad_medida (id_unidad);
ALTER TABLE pedido_detalle
    ADD CONSTRAINT fk_pd_pedido FOREIGN KEY (id_pedido)
    REFERENCES pedido (id_pedido);
ALTER TABLE pedido_detalle
    ADD CONSTRAINT fk_pd_presentacion FOREIGN KEY (id_presentacion)
    REFERENCES item_presentacion (id_presentacion);
ALTER TABLE orden_produccion_detalle
    ADD CONSTRAINT fk_opd_orden FOREIGN KEY (id_orden_produccion)
    REFERENCES orden_produccion (id_orden_produccion);
ALTER TABLE orden_produccion_detalle
    ADD CONSTRAINT fk_opd_insumo FOREIGN KEY (id_item_insumo)
    REFERENCES item (id_item);
ALTER TABLE orden_produccion_detalle
    ADD CONSTRAINT fk_opd_unidad FOREIGN KEY (id_unidad)
    REFERENCES unidad_medida (id_unidad);
ALTER TABLE lote_inventario
    ADD CONSTRAINT fk_lote_item FOREIGN KEY (id_item)
    REFERENCES item (id_item);
ALTER TABLE lote_inventario
    ADD CONSTRAINT fk_lote_recepcion FOREIGN KEY (id_recepcion_detalle)
    REFERENCES recepcion_detalle (id_recepcion_detalle);
ALTER TABLE lote_inventario
    ADD CONSTRAINT fk_lote_unidad FOREIGN KEY (id_unidad)
    REFERENCES unidad_medida (id_unidad);
ALTER TABLE movimiento_inventario
    ADD CONSTRAINT fk_mov_item FOREIGN KEY (id_item)
    REFERENCES item (id_item);
ALTER TABLE movimiento_inventario
    ADD CONSTRAINT fk_mov_tipo FOREIGN KEY (id_tipo_movimiento)
    REFERENCES tipo_movimiento (id_tipo_movimiento);
ALTER TABLE movimiento_inventario
    ADD CONSTRAINT fk_mov_lote FOREIGN KEY (id_lote)
    REFERENCES lote_inventario (id_lote);
ALTER TABLE movimiento_inventario
    ADD CONSTRAINT fk_mov_unidad FOREIGN KEY (id_unidad)
    REFERENCES unidad_medida (id_unidad);
ALTER TABLE merma
    ADD CONSTRAINT fk_merma_movimiento FOREIGN KEY (id_movimiento)
    REFERENCES movimiento_inventario (id_movimiento);
ALTER TABLE pedido_detalle_orden
    ADD CONSTRAINT fk_pdo_detalle FOREIGN KEY (id_pedido_detalle)
    REFERENCES pedido_detalle (id_pedido_detalle);
ALTER TABLE pedido_detalle_orden
    ADD CONSTRAINT fk_pdo_orden FOREIGN KEY (id_orden_produccion)
    REFERENCES orden_produccion (id_orden_produccion);
ALTER TABLE venta
    ADD CONSTRAINT fk_venta_pedido FOREIGN KEY (id_pedido)
    REFERENCES pedido (id_pedido);
ALTER TABLE venta
    ADD CONSTRAINT fk_venta_caja FOREIGN KEY (id_caja_sesion)
    REFERENCES caja_sesion (id_caja_sesion);
ALTER TABLE pago
    ADD CONSTRAINT fk_pago_venta FOREIGN KEY (id_venta)
    REFERENCES venta (id_venta);
ALTER TABLE costo_receta
    ADD CONSTRAINT fk_costo_receta FOREIGN KEY (id_receta)
    REFERENCES receta (id_receta);
ALTER TABLE gasto_operativo
    ADD CONSTRAINT fk_gasto_caja FOREIGN KEY (id_caja_sesion)
    REFERENCES caja_sesion (id_caja_sesion);
ALTER TABLE movimiento_contable
    ADD CONSTRAINT fk_mc_venta FOREIGN KEY (id_venta)
    REFERENCES venta (id_venta);
ALTER TABLE movimiento_contable
    ADD CONSTRAINT fk_mc_costo FOREIGN KEY (id_costo_receta)
    REFERENCES costo_receta (id_costo_receta);
ALTER TABLE movimiento_contable
    ADD CONSTRAINT fk_mc_gasto FOREIGN KEY (id_gasto)
    REFERENCES gasto_operativo (id_gasto);
ALTER TABLE lote_inventario
    ADD CONSTRAINT fk_lote_orden_produccion FOREIGN KEY (id_orden_produccion)
    REFERENCES orden_produccion (id_orden_produccion);
ALTER TABLE pedido
    ADD CONSTRAINT fk_pedido_reserva FOREIGN KEY (id_reserva)
    REFERENCES reserva (id_reserva);
