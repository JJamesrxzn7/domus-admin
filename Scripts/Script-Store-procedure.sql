DELIMITER //

/* =========================================================================
   PROCEDIMIENTO CENTRAL DE AUDITORÍA
   ========================================================================= */
CREATE PROCEDURE SP_REGISTRAR_LOG(
    IN p_id_Usuario CHAR(16), 
    IN p_Tabla VARCHAR(50), 
    IN p_Accion VARCHAR(20), 
    IN p_Anterior TEXT, 
    IN p_Nuevo TEXT
)
BEGIN
    INSERT INTO LOG_AUDITORIA (
        id_Log, id_Usuario, log_FechaHora, log_TablaAfectada, log_Accion, log_ValorAnterior, log_ValorNuevo
    ) 
    VALUES (
        LEFT(REPLACE(UUID(), '-', ''), 15), p_id_Usuario, NOW(), p_Tabla, p_Accion, p_Anterior, p_Nuevo
    );
END //

/* =========================================================================
   MÓDULO 1: COMPRAS Y RECEPCIONES
   ========================================================================= */
CREATE PROCEDURE SP_COMPRA_CREAR(
    IN p_id_Compra CHAR(10), 
    IN p_id_Proveedor CHAR(10), 
    IN p_FechaEntrega DATETIME, 
    IN p_Subtotal NUMERIC(7,2), 
    IN p_IVA NUMERIC(7,2), 
    IN p_Total NUMERIC(7,2), 
    IN p_id_Usuario CHAR(16)
)
BEGIN
    INSERT INTO COMPRAS (
        id_Compra, id_Proveedor, oc_Fecha, oc_FechaEntrega, oc_Subtotal, oc_IVA, oc_Total, ESTADO_OC
    ) 
    VALUES (
        p_id_Compra, p_id_Proveedor, NOW(), p_FechaEntrega, p_Subtotal, p_IVA, p_Total, 'ABI'
    );
    CALL SP_REGISTRAR_LOG(p_id_Usuario, 'COMPRAS', 'INSERT', NULL, CONCAT('{"id_Compra": "', p_id_Compra, '"}'));
END //

CREATE PROCEDURE SP_COMPRA_VER(IN p_id_Compra CHAR(10))
BEGIN
    SELECT * FROM VW_COMPRAS_PROVEEDORES WHERE id_Compra = p_id_Compra;
END //

CREATE PROCEDURE SP_COMPRA_ANULAR(IN p_id_Compra CHAR(10), IN p_id_Usuario CHAR(16))
BEGIN
    DECLARE v_estado CHAR(3);
    SELECT ESTADO_OC INTO v_estado FROM COMPRAS WHERE id_Compra = p_id_Compra;
    
    IF v_estado = 'ABI' THEN
        UPDATE COMPRAS SET ESTADO_OC = 'ANU' WHERE id_Compra = p_id_Compra;
        UPDATE PROxOC SET ESTADO_PxOC = 'ANU' WHERE id_Compra = p_id_Compra;
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'COMPRAS', 'UPDATE-ANULAR', CONCAT('{"Estado_Anterior": "', v_estado, '"}'), '{"Estado_Nuevo": "ANU"}');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Solo se puede anular una orden en estado Abierto (ABI).';
    END IF;
END //

CREATE PROCEDURE SP_COMPRA_APROBAR(IN p_id_Compra CHAR(10), IN p_id_Usuario CHAR(16))
BEGIN
    DECLARE v_estado CHAR(3);
    SELECT ESTADO_OC INTO v_estado FROM COMPRAS WHERE id_Compra = p_id_Compra;
    
    IF v_estado = 'ABI' THEN
        UPDATE COMPRAS SET ESTADO_OC = 'APR' WHERE id_Compra = p_id_Compra;
        UPDATE PROxOC SET ESTADO_PxOC = 'APR' WHERE id_Compra = p_id_Compra;
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'COMPRAS', 'UPDATE-APROBAR', '{"Estado": "ABI"}', '{"Estado": "APR"}');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La orden no está Abierta (ABI).';
    END IF;
END //

CREATE PROCEDURE SP_COMPRA_AGREGAR_PRODUCTO(
    IN p_id_Compra CHAR(10), 
    IN p_id_Producto CHAR(10), 
    IN p_Cantidad INT, 
    IN p_Valor NUMERIC(7,2), 
    IN p_id_Usuario CHAR(16)
)
BEGIN
    DECLARE v_estado CHAR(3);
    SELECT ESTADO_OC INTO v_estado FROM COMPRAS WHERE id_Compra = p_id_Compra;
    
    IF v_estado = 'ABI' THEN
        INSERT INTO PROxOC (
            id_Compra, id_Producto, pxo_Cantidad, pxo_Valor, pxo_Subtotal, ESTADO_PxOC
        ) VALUES (
            p_id_Compra, p_id_Producto, p_Cantidad, p_Valor, (p_Cantidad * p_Valor), 'ACT'
        );
        
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'PROxOC', 'INSERT', NULL, CONCAT('{"id_Compra": "', p_id_Compra, '", "id_Producto": "', p_id_Producto, '"}'));
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Solo puede agregar productos a órdenes en estado Abierto (ABI).';
    END IF;
END //

CREATE PROCEDURE SP_RECEPCION_RECIBIR(IN p_id_Recibo CHAR(10), IN p_id_Usuario CHAR(16))
BEGIN
    DECLARE v_estado CHAR(3);
    SELECT ESTADO_REC INTO v_estado FROM RECEPCIONES WHERE id_Recibo = p_id_Recibo;
    
    IF v_estado = 'PEN' THEN
        UPDATE RECEPCIONES SET ESTADO_REC = 'REC', rec_FechaHora = NOW() WHERE id_Recibo = p_id_Recibo;
        UPDATE PROxREC SET ESTADO_PxREC = 'REC' WHERE id_Recibo = p_id_Recibo;
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'RECEPCIONES', 'UPDATE-RECIBIR', '{"Estado": "PEN"}', '{"Estado": "REC"}');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Solo se confirman recepciones Pendientes (PEN).';
    END IF;
END //

/* =========================================================================
   MÓDULO 2: INVENTARIOS (PRODUCTOS Y AJUSTES)
   ========================================================================= */
CREATE PROCEDURE SP_PRODUCTO_CREAR(
    IN p_id_Producto CHAR(10), IN p_id_Categoria CHAR(10), IN p_id_Marca CHAR(10), 
    IN p_Descripcion CHAR(40), IN p_UM_Compra CHAR(3), IN p_UM_Venta CHAR(3), 
    IN p_Valor_Compra NUMERIC(7,2), IN p_Precio_Venta NUMERIC(7,2), 
    IN p_Saldo_Inicial INT, IN p_id_Usuario CHAR(16)
)
BEGIN
    INSERT INTO PRODUCTOS (
        id_Producto, id_Categoria, id_Marca, pro_Descripcion, pro_UM_Compra, pro_UM_Venta, 
        pro_Valor_Compra, pro_Precio_Venta, pro_Saldo_Inicial, pro_Qty_Ingresos, 
        pro_Qty_Egresos, pro_Qty_Ajustes, pro_Saldo_Final, ESTADO_PROD
    ) VALUES (
        p_id_Producto, p_id_Categoria, p_id_Marca, p_Descripcion, p_UM_Compra, p_UM_Venta, 
        p_Valor_Compra, p_Precio_Venta, p_Saldo_Inicial, 0, 0, 0, p_Saldo_Inicial, 'ACT'
    );
    CALL SP_REGISTRAR_LOG(p_id_Usuario, 'PRODUCTOS', 'INSERT', NULL, CONCAT('{"id_Producto": "', p_id_Producto, '"}'));
END //

CREATE PROCEDURE SP_AJUSTE_CREAR(
    IN p_id_Ajuste CHAR(15), IN p_id_Empleado CHAR(10), IN p_Descripcion CHAR(30), 
    IN p_Num_Produc INT, IN p_id_Usuario CHAR(16)
)
BEGIN
    INSERT INTO AJUSTES (id_Ajuste, id_Empleado, aju_Descripcion, aju_FechaHora, aju_Num_Produc, ESTADO_AJU) 
    VALUES (p_id_Ajuste, p_id_Empleado, p_Descripcion, NOW(), p_Num_Produc, 'ABI');
    CALL SP_REGISTRAR_LOG(p_id_Usuario, 'AJUSTES', 'INSERT', NULL, CONCAT('{"id_Ajuste": "', p_id_Ajuste, '"}'));
END //

CREATE PROCEDURE SP_AJUSTE_VER(IN p_id_Ajuste CHAR(15))
BEGIN
    SELECT * FROM VW_AJUSTES_INVENTARIO WHERE id_Ajuste = p_id_Ajuste;
END //

CREATE PROCEDURE SP_AJUSTE_ANULAR(IN p_id_Ajuste CHAR(15), IN p_id_Usuario CHAR(16))
BEGIN
    DECLARE v_estado CHAR(3);
    SELECT ESTADO_AJU INTO v_estado FROM AJUSTES WHERE id_Ajuste = p_id_Ajuste;
    
    IF v_estado = 'ABI' THEN
        UPDATE AJUSTES SET ESTADO_AJU = 'ANU' WHERE id_Ajuste = p_id_Ajuste;
        UPDATE PROxAJU SET ESTADO_PxAJU = 'ANU' WHERE id_Ajuste = p_id_Ajuste;
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'AJUSTES', 'UPDATE-ANULAR', '{"Estado": "ABI"}', '{"Estado": "ANU"}');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Solo se pueden anular ajustes en estado Abierto (ABI).';
    END IF;
END //

CREATE PROCEDURE SP_AJUSTE_APROBAR(IN p_id_Ajuste CHAR(15), IN p_id_Usuario CHAR(16))
BEGIN
    DECLARE v_estado CHAR(3);
    SELECT ESTADO_AJU INTO v_estado FROM AJUSTES WHERE id_Ajuste = p_id_Ajuste;
    
    IF v_estado = 'ABI' THEN
        UPDATE AJUSTES SET ESTADO_AJU = 'APR' WHERE id_Ajuste = p_id_Ajuste;
        UPDATE PROxAJU SET ESTADO_PxAJU = 'APR' WHERE id_Ajuste = p_id_Ajuste;
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'AJUSTES', 'UPDATE-APROBAR', '{"Estado": "ABI"}', '{"Estado": "APR"}');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El ajuste no está en estado Abierto.';
    END IF;
END //

CREATE PROCEDURE SP_AJUSTE_AGREGAR_PRODUCTO(
    IN p_id_Ajuste CHAR(15), 
    IN p_id_Producto CHAR(10), 
    IN p_Cantidad INT, 
    IN p_Tipo_Ajuste VARCHAR(10), /* 'Ingreso' o 'Salida' desde la UI */
    IN p_id_Usuario CHAR(16)
)
BEGIN
    DECLARE v_estado CHAR(3);
    DECLARE v_cantidad_final INT;
    
    SELECT ESTADO_AJU INTO v_estado FROM AJUSTES WHERE id_Ajuste = p_id_Ajuste;
    
    IF v_estado = 'ABI' THEN
        IF p_Tipo_Ajuste = 'Salida' THEN
            SET v_cantidad_final = p_Cantidad * -1;
        ELSE
            SET v_cantidad_final = p_Cantidad;
        END IF;

        INSERT INTO PROxAJU (id_Ajuste, id_Producto, pxa_Cantidad, ESTADO_PxAJU)
        VALUES (p_id_Ajuste, p_id_Producto, v_cantidad_final, 'ACT');
        
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'PROxAJU', 'INSERT', NULL, CONCAT('{"id_Ajuste": "', p_id_Ajuste, '", "id_Producto": "', p_id_Producto, '", "Cantidad": ', v_cantidad_final, '}'));
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Solo puede agregar productos a ajustes en estado Abierto (ABI).';
    END IF;
END //

/* =========================================================================
   MÓDULO 3: VENTAS Y ENTREGAS
   ========================================================================= */
CREATE PROCEDURE SP_FACTURA_CREAR(
    IN p_id_Factura CHAR(15), 
    IN p_id_Cliente CHAR(10), 
    IN p_id_Empleado CHAR(10), 
    IN p_Descripcion CHAR(60), 
    IN p_Subtotal NUMERIC(7,2), 
    IN p_Descuento NUMERIC(7,2), 
    IN p_IVA NUMERIC(7,2), 
    IN p_Total NUMERIC(7,2), 
    IN p_FormaPago VARCHAR(20), 
    IN p_id_Usuario CHAR(16)
)
BEGIN
    INSERT INTO FACTURAS (
        id_Factura, id_Cliente, id_Empleado, fac_Descripcion, fac_Fecha, 
        fac_Subtotal, fac_Descuento, fac_IVA, fac_Total, fac_FormaPago, ESTADO_FAC
    ) VALUES (
        p_id_Factura, p_id_Cliente, p_id_Empleado, p_Descripcion, NOW(), 
        p_Subtotal, p_Descuento, p_IVA, p_Total, p_FormaPago, 'ABI'
    );
    CALL SP_REGISTRAR_LOG(p_id_Usuario, 'FACTURAS', 'INSERT', NULL, CONCAT('{"id_Factura": "', p_id_Factura, '"}'));
END //

CREATE PROCEDURE SP_FACTURA_VER(IN p_id_Factura CHAR(15))
BEGIN
    SELECT * FROM VW_FACTURAS_CLIENTES WHERE id_Factura = p_id_Factura;
END //

CREATE PROCEDURE SP_FACTURA_ANULAR(IN p_id_Factura CHAR(15), IN p_id_Usuario CHAR(16))
BEGIN
    DECLARE v_estado CHAR(3);
    SELECT ESTADO_FAC INTO v_estado FROM FACTURAS WHERE id_Factura = p_id_Factura;
    
    IF v_estado IN ('ABI', 'PEN') THEN
        UPDATE FACTURAS SET ESTADO_FAC = 'ANU' WHERE id_Factura = p_id_Factura;
        UPDATE PROxFAC SET ESTADO_PxFAC = 'ANU' WHERE id_Factura = p_id_Factura;
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'FACTURAS', 'UPDATE-ANULAR', CONCAT('{"Estado_Anterior": "', v_estado, '"}'), '{"Estado_Nuevo": "ANU"}');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Factura ya aprobada o entregada, no se puede anular.';
    END IF;
END //

CREATE PROCEDURE SP_FACTURA_APROBAR(IN p_id_Factura CHAR(15), IN p_id_Usuario CHAR(16))
BEGIN
    DECLARE v_estado CHAR(3);
    SELECT ESTADO_FAC INTO v_estado FROM FACTURAS WHERE id_Factura = p_id_Factura;
    
    IF v_estado = 'ABI' THEN
        UPDATE FACTURAS SET ESTADO_FAC = 'APR' WHERE id_Factura = p_id_Factura;
        UPDATE PROxFAC SET ESTADO_PxFAC = 'APR' WHERE id_Factura = p_id_Factura;
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'FACTURAS', 'UPDATE-APROBAR', '{"Estado": "ABI"}', '{"Estado": "APR"}');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Solo se aprueban facturas en estado Abierto (ABI).';
    END IF;
END //

CREATE PROCEDURE SP_ENTREGA_CONFIRMAR(IN p_id_Entrega CHAR(15), IN p_id_Usuario CHAR(16))
BEGIN
    DECLARE v_estado CHAR(3);
    SELECT ESTADO_ENT INTO v_estado FROM ENTREGAS WHERE id_Entrega = p_id_Entrega;
    
    IF v_estado = 'PEN' THEN
        UPDATE ENTREGAS SET ESTADO_ENT = 'ENT', ent_FechaHora = NOW() WHERE id_Entrega = p_id_Entrega;
        UPDATE PROxENT SET ESTADO_PxENT = 'ENT' WHERE id_Entrega = p_id_Entrega;
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'ENTREGAS', 'UPDATE-ENTREGAR', '{"Estado": "PEN"}', '{"Estado": "ENT"}');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Solo se pueden confirmar entregas en estado Pendiente (PEN).';
    END IF;
END //

/* =========================================================================
   MÓDULO 4: TALENTO HUMANO (NÓMINA)
   ========================================================================= */
CREATE PROCEDURE SP_PAGO_CREAR(
    IN p_id_Pago CHAR(10), IN p_Descripcion CHAR(40), IN p_Fecha_Inicio DATE, 
    IN p_Fecha_Fin DATE, IN p_id_Usuario CHAR(16)
)
BEGIN
    INSERT INTO PAGOS (id_Pago, pag_Descripcion, pag_Fecha_Inicio, pag_Fecha_Fin, USER_ID, ESTADO_PAG) 
    VALUES (p_id_Pago, p_Descripcion, p_Fecha_Inicio, p_Fecha_Fin, p_id_Usuario, 'ABI');
    CALL SP_REGISTRAR_LOG(p_id_Usuario, 'PAGOS', 'INSERT', NULL, CONCAT('{"id_Pago": "', p_id_Pago, '"}'));
END //

CREATE PROCEDURE SP_PAGO_VER(IN p_id_Pago CHAR(10))
BEGIN
    SELECT * FROM VW_PAGOS_EMPLEADOS WHERE id_Pago = p_id_Pago;
END //

CREATE PROCEDURE SP_PAGO_ANULAR(IN p_id_Pago CHAR(10), IN p_id_Usuario CHAR(16))
BEGIN
    DECLARE v_estado CHAR(3);
    SELECT ESTADO_PAG INTO v_estado FROM PAGOS WHERE id_Pago = p_id_Pago;
    
    IF v_estado = 'ABI' THEN
        UPDATE PAGOS SET ESTADO_PAG = 'ANU' WHERE id_Pago = p_id_Pago;
        UPDATE PAGxEMP SET ESTADO_PxE = 'ANU' WHERE id_Pago = p_id_Pago;
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'PAGOS', 'UPDATE-ANULAR', '{"Estado": "ABI"}', '{"Estado": "ANU"}');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Solo se pueden anular roles de pago en estado Abierto (ABI).';
    END IF;
END //

CREATE PROCEDURE SP_PAGO_APROBAR(IN p_id_Pago CHAR(10), IN p_id_Usuario CHAR(16))
BEGIN
    DECLARE v_estado CHAR(3);
    SELECT ESTADO_PAG INTO v_estado FROM PAGOS WHERE id_Pago = p_id_Pago;
    
    IF v_estado = 'ABI' THEN
        UPDATE PAGOS SET ESTADO_PAG = 'APR' WHERE id_Pago = p_id_Pago;
        UPDATE PAGxEMP SET ESTADO_PxE = 'APR' WHERE id_Pago = p_id_Pago;
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'PAGOS', 'UPDATE-APROBAR', '{"Estado": "ABI"}', '{"Estado": "APR"}');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El rol de pagos no está en estado Abierto.';
    END IF;
END //

/* =========================================================================
   MÓDULO 5: CONTABILIDAD (TRANSACCIONES ACID)
   ========================================================================= */
CREATE PROCEDURE SP_ASIENTO_CREAR(
    IN p_id_Asiento CHAR(10), IN p_Descripcion CHAR(30), IN p_Total_Debe NUMERIC(7,2), 
    IN p_Total_Haber NUMERIC(7,2), IN p_id_Usuario CHAR(16)
)
BEGIN
    INSERT INTO ASIENTOS (id_Asiento, asi_Descripcion, asi_Total_Debe, asi_Total_Haber, asi_FechaHora, USER_ID, ESTADO_ASI) 
    VALUES (p_id_Asiento, p_Descripcion, p_Total_Debe, p_Total_Haber, NOW(), p_id_Usuario, 'ABI');
    CALL SP_REGISTRAR_LOG(p_id_Usuario, 'ASIENTOS', 'INSERT', NULL, CONCAT('{"id_Asiento": "', p_id_Asiento, '"}'));
END //

CREATE PROCEDURE SP_ASIENTO_VER(IN p_id_Asiento CHAR(10))
BEGIN
    SELECT * FROM VW_DETALLE_ASIENTOS WHERE id_Asiento = p_id_Asiento;
END //

CREATE PROCEDURE SP_ASIENTO_ANULAR(IN p_id_Asiento CHAR(10), IN p_id_Usuario CHAR(16))
BEGIN
    DECLARE v_estado CHAR(3);
    SELECT ESTADO_ASI INTO v_estado FROM ASIENTOS WHERE id_Asiento = p_id_Asiento;
    
    IF v_estado IN ('ABI', 'PEN', 'ERR') THEN
        UPDATE ASIENTOS SET ESTADO_ASI = 'ANU' WHERE id_Asiento = p_id_Asiento;
        UPDATE CTAxASI SET ESTADO_CXA = 'ANU' WHERE id_Asiento = p_id_Asiento;
        CALL SP_REGISTRAR_LOG(p_id_Usuario, 'ASIENTOS', 'UPDATE-ANULAR', CONCAT('{"Estado_Anterior": "', v_estado, '"}'), '{"Estado_Nuevo": "ANU"}');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El asiento ya fue contabilizado o anulado previamente.';
    END IF;
END //

CREATE PROCEDURE SP_ASIENTO_APROBAR(IN p_id_Asiento CHAR(10), IN p_id_Usuario CHAR(16))
BEGIN
    DECLARE v_estado CHAR(3);
    DECLARE v_debe NUMERIC(10,2);
    DECLARE v_haber NUMERIC(10,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error crítico en la transacción. Se ejecutó un ROLLBACK de emergencia para evitar corrupción de datos.';
    END;

    START TRANSACTION;
    
    SELECT ESTADO_ASI, asi_Total_Debe, asi_Total_Haber INTO v_estado, v_debe, v_haber 
    FROM ASIENTOS WHERE id_Asiento = p_id_Asiento;
    
    IF v_estado IN ('ABI', 'PEN', 'ERR') THEN
        IF v_debe = v_haber THEN
            SAVEPOINT PuntoAntesDeMayorizar;
            
            UPDATE ASIENTOS SET ESTADO_ASI = 'CON' WHERE id_Asiento = p_id_Asiento;
            UPDATE CTAxASI SET ESTADO_CXA = 'CON' WHERE id_Asiento = p_id_Asiento;
            CALL SP_REGISTRAR_LOG(p_id_Usuario, 'ASIENTOS', 'UPDATE-APROBAR', CONCAT('{"Estado_Anterior": "', v_estado, '"}'), '{"Estado_Nuevo": "CON"}');
            
            COMMIT;
        ELSE
            ROLLBACK; 
            START TRANSACTION;
            UPDATE ASIENTOS SET ESTADO_ASI = 'ERR' WHERE id_Asiento = p_id_Asiento;
            CALL SP_REGISTRAR_LOG(p_id_Usuario, 'ASIENTOS', 'UPDATE-ERROR', '{"Motivo": "Descuadre Debe/Haber"}', '{"Estado_Nuevo": "ERR"}');
            COMMIT;
            
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Partida Doble: El asiento no cuadra. Transacción original abortada (ROLLBACK) y movido a estado ERR.';
        END IF;
    ELSE
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error transaccional: Solo se pueden aprobar asientos abiertos, pendientes o con error.';
    END IF;
END //

DELIMITER ;