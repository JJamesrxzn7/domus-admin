DELIMITER //

/* ============================================================
   MÓDULO: VENTAS Y ENTREGAS
   ============================================================ */

-- Validación de stock antes de vender
CREATE TRIGGER TRG_BEFORE_INSERT_PROxFAC
BEFORE INSERT ON PROxFAC
FOR EACH ROW
BEGIN
    DECLARE v_stock_actual INT;
    SELECT pro_Saldo_Final INTO v_stock_actual FROM PRODUCTOS WHERE id_Producto = NEW.id_Producto;
    IF v_stock_actual < NEW.pxf_Cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Stock insuficiente en bodega para realizar esta venta.';
    END IF;
END //

-- Actualización automática de totales en factura y egresos parciales
CREATE TRIGGER TRG_AFTER_INSERT_PROxFAC
AFTER INSERT ON PROxFAC
FOR EACH ROW
BEGIN
    -- Descuenta inventario
    UPDATE PRODUCTOS
    SET pro_Qty_Egresos = pro_Qty_Egresos + NEW.pxf_Cantidad,
        pro_Saldo_Final = pro_Saldo_Final - NEW.pxf_Cantidad
    WHERE id_Producto = NEW.id_Producto;

    -- Recalcula los totales de la cabecera respetando el descuento (Subtotal - Descuento)
    UPDATE FACTURAS
    SET fac_Subtotal = fac_Subtotal + NEW.pxf_Subtotal,
        fac_IVA = (fac_Subtotal - fac_Descuento) * 0.15,
        fac_Total = (fac_Subtotal - fac_Descuento) + ((fac_Subtotal - fac_Descuento) * 0.15)
    WHERE id_Factura = NEW.id_Factura;
END //

-- Automatización al aprobar una venta (Genera entrega y asiento)
CREATE TRIGGER TRG_FAC_APR
AFTER UPDATE ON FACTURAS
FOR EACH ROW
BEGIN
    IF OLD.ESTADO_FAC = 'ABI' AND NEW.ESTADO_FAC = 'APR' THEN
        INSERT INTO ENTREGAS (id_Entrega, id_Factura, ent_Descripcion, ent_FechaHora, ent_Num_Produc, ESTADO_ENT) 
        VALUES (CONCAT('E-', RIGHT(NEW.id_Factura, 8)), NEW.id_Factura, 'Despacho por Venta Aprobada', NOW(), 0, 'PEN');
        
        INSERT INTO ASIENTOS (id_Asiento, asi_Descripcion, asi_Total_Debe, asi_Total_Haber, asi_FechaHora, USER_ID, ESTADO_ASI) 
        VALUES (CONCAT('ASI-', RIGHT(NEW.id_Factura, 8)), CONCAT('Ingreso por Factura: ', NEW.id_Factura), NEW.fac_Total, NEW.fac_Total, NOW(), 'SYS-AUTO', 'PEN');
    END IF;
END //

-- Descuento definitivo de inventario al despachar
CREATE TRIGGER TRG_ENT_CONF
AFTER UPDATE ON ENTREGAS
FOR EACH ROW
BEGIN
    IF OLD.ESTADO_ENT = 'PEN' AND NEW.ESTADO_ENT = 'ENT' THEN
        UPDATE PRODUCTOS P
        INNER JOIN PROxENT PE ON P.id_Producto = PE.id_Producto
        SET P.pro_Qty_Egresos = P.pro_Qty_Egresos + PE.pxe_Qty_Entregada,
            P.pro_Saldo_Final = P.pro_Saldo_Final - PE.pxe_Qty_Entregada
        WHERE PE.id_Entrega = NEW.id_Entrega;
    END IF;
END //

/* ============================================================
   MÓDULO: COMPRAS Y RECEPCIONES
   ============================================================ */

-- Automatización al aprobar una orden de compra
CREATE TRIGGER TRG_COMPRA_APR
AFTER UPDATE ON COMPRAS
FOR EACH ROW
BEGIN
    DECLARE v_id_asiento CHAR(10);
    IF OLD.ESTADO_OC = 'ABI' AND NEW.ESTADO_OC = 'APR' THEN
        -- 1. Genera la recepción pendiente para Bodegas
        INSERT INTO RECEPCIONES (id_Recibo, id_Compra, rec_Descripcion, rec_FechaHora, rec_Num_Produc, ESTADO_REC) 
        VALUES (CONCAT('REC-', RIGHT(NEW.id_Compra, 6)), NEW.id_Compra, 'Recepción automática OC', NOW(), 0, 'PEN');
        
        -- 2. Genera el Asiento Contable
        SET v_id_asiento = CONCAT('AS-', RIGHT(NEW.id_Compra, 7));
        
        -- Cabecera
        INSERT INTO ASIENTOS (id_Asiento, asi_Descripcion, asi_Total_Debe, asi_Total_Haber, asi_FechaHora, USER_ID, ESTADO_ASI) 
        VALUES (v_id_asiento, CONCAT('Compra OC: ', NEW.id_Compra), NEW.oc_Total, NEW.oc_Total, NOW(), 'SYS-AUTO', 'PEN');
        
        -- Detalles (Reemplaza los códigos por los de tu Plan de Cuentas)
        -- DEBE: Ingreso de Inventario
        INSERT INTO CTAxASI (id_Asiento, id_Cuenta, id_CentroCosto, cxa_Debe, cxa_Haber, ESTADO_CXA) 
        VALUES (v_id_asiento, '1.1.03.01.01', NULL, NEW.oc_Subtotal, 0, 'ACT');
        
        -- DEBE: IVA en Compras
        INSERT INTO CTAxASI (id_Asiento, id_Cuenta, id_CentroCosto, cxa_Debe, cxa_Haber, ESTADO_CXA) 
        VALUES (v_id_asiento, '1.1.05.01.01', NULL, NEW.oc_IVA, 0, 'ACT');
        
        -- HABER: Proveedores por Pagar
        INSERT INTO CTAxASI (id_Asiento, id_Cuenta, id_CentroCosto, cxa_Debe, cxa_Haber, ESTADO_CXA) 
        VALUES (v_id_asiento, '2.1.03.01.01', NULL, 0, NEW.oc_Total, 'ACT');
    END IF;
END //

-- Ingreso de stock físico al recibir mercadería parcial
CREATE TRIGGER TRG_AFTER_INSERT_PROxREC
AFTER INSERT ON PROxREC
FOR EACH ROW
BEGIN
    UPDATE PRODUCTOS
    SET pro_Qty_Ingresos = pro_Qty_Ingresos + NEW.pxr_Qty_Recibida,
        pro_Saldo_Final = pro_Saldo_Final + NEW.pxr_Qty_Recibida
    WHERE id_Producto = NEW.id_Producto;
END //

-- Ingreso definitivo de inventario recibido por lote
CREATE TRIGGER TRG_RECIBO_REC
AFTER UPDATE ON RECEPCIONES
FOR EACH ROW
BEGIN
    IF OLD.ESTADO_REC = 'PEN' AND NEW.ESTADO_REC = 'REC' THEN
        UPDATE PRODUCTOS P
        INNER JOIN PROxREC PR ON P.id_Producto = PR.id_Producto
        SET P.pro_Qty_Ingresos = P.pro_Qty_Ingresos + PR.pxr_Qty_Recibida,
            P.pro_Saldo_Final = P.pro_Saldo_Final + PR.pxr_Qty_Recibida
        WHERE PR.id_Recibo = NEW.id_Recibo;
    END IF;
END //

CREATE TRIGGER TRG_AFTER_INSERT_PROxOC
AFTER INSERT ON PROxOC
FOR EACH ROW
BEGIN
    -- Suma el subtotal del nuevo producto a la cabecera y recalcula el IVA (15%) y Total
    UPDATE COMPRAS
    SET oc_Subtotal = oc_Subtotal + NEW.pxo_Subtotal,
        oc_IVA = (oc_Subtotal + NEW.pxo_Subtotal) * 0.15,
        oc_Total = (oc_Subtotal + NEW.pxo_Subtotal) * 1.15
    WHERE id_Compra = NEW.id_Compra;
END //

/* ============================================================
   MÓDULO: AJUSTES E INVENTARIO GENERAL
   ============================================================ */

-- Automatización de ajuste de inventario aprobado
CREATE TRIGGER TRG_AJUSTE_APR
AFTER UPDATE ON AJUSTES
FOR EACH ROW
BEGIN
    DECLARE v_valor_perdida NUMERIC(7,2);
    IF OLD.ESTADO_AJU = 'ABI' AND NEW.ESTADO_AJU = 'APR' THEN
        UPDATE PRODUCTOS P
        INNER JOIN PROxAJU PA ON P.id_Producto = PA.id_Producto
        SET P.pro_Qty_Ajustes = P.pro_Qty_Ajustes + PA.pxa_Cantidad,
            P.pro_Saldo_Final = P.pro_Saldo_Final + PA.pxa_Cantidad
        WHERE PA.id_Ajuste = NEW.id_Ajuste;

        SELECT IFNULL(SUM(ABS(PA.pxa_Cantidad) * P.pro_Valor_Compra), 0) INTO v_valor_perdida
        FROM PROxAJU PA
        INNER JOIN PRODUCTOS P ON PA.id_Producto = P.id_Producto
        WHERE PA.id_Ajuste = NEW.id_Ajuste;

        INSERT INTO ASIENTOS (id_Asiento, asi_Descripcion, asi_Total_Debe, asi_Total_Haber, asi_FechaHora, USER_ID, ESTADO_ASI) 
        VALUES (CONCAT('ASI-AJ-', RIGHT(NEW.id_Ajuste, 5)), CONCAT('Ajuste de Inventario: ', NEW.id_Ajuste), v_valor_perdida, v_valor_perdida, NOW(), 'SYS-AUTO', 'PEN');
    END IF;
END //

-- Auditoría automática de cambio de precios
CREATE TRIGGER TRG_AFTER_UPDATE_PRODUCTOS_PRECIO
AFTER UPDATE ON PRODUCTOS
FOR EACH ROW
BEGIN
    IF OLD.pro_Precio_Venta <> NEW.pro_Precio_Venta THEN
        INSERT INTO LOG_AUDITORIA (id_Log, id_Usuario, log_FechaHora, log_TablaAfectada, log_Accion, log_ValorAnterior, log_ValorNuevo) 
        VALUES (CONCAT('LOG-', LEFT(UUID(), 11)), 'SYS-AUTO', NOW(), 'PRODUCTOS', 'UPDATE PRECIO', CONCAT('{"precio_anterior": ', OLD.pro_Precio_Venta, '}'), CONCAT('{"precio_nuevo": ', NEW.pro_Precio_Venta, '}'));
    END IF;
END //

/* ============================================================
   MÓDULO: TALENTO HUMANO (NÓMINA)
   ============================================================ */

-- 3. Auditoría Estricta de Sueldos (Protección contra fraude en la tabla EMPLEADOS)
CREATE TRIGGER TRG_AUDITORIA_SUELDOS
AFTER UPDATE ON EMPLEADOS
FOR EACH ROW
BEGIN
    -- Solo se dispara y registra en el LOG si el sueldo realmente fue modificado
    IF OLD.emp_Sueldo <> NEW.emp_Sueldo THEN
        INSERT INTO LOG_AUDITORIA (
            id_Log, id_Usuario, log_FechaHora, log_TablaAfectada, 
            log_Accion, log_IP, log_ValorAnterior, log_ValorNuevo
        ) VALUES (
            CONCAT('LOG-', UNIX_TIMESTAMP()), 
            IFNULL(NEW.USER_ID, 'SYS-DBA'), 
            NOW(), 
            'EMPLEADOS', 
            'UPDATE_SUELDO', 
            'N/A', 
            CONCAT('{"Sueldo_Anterior": ', OLD.emp_Sueldo, '}'), 
            CONCAT('{"Sueldo_Nuevo": ', NEW.emp_Sueldo, '}')
        );
    END IF;
END //

-- 4. Rol de Pagos Aprobado -> Generación de Asiento Contable Automático
CREATE TRIGGER TRG_PAGO_APR
AFTER UPDATE ON PAGOS
FOR EACH ROW
BEGIN
    DECLARE v_total_sueldo NUMERIC(10,2); DECLARE v_total_bonos NUMERIC(10,2);
    DECLARE v_total_desc NUMERIC(10,2);   DECLARE v_total_neto NUMERIC(10,2);
    DECLARE v_total_nomina NUMERIC(10,2); DECLARE v_id_asiento CHAR(10);

    -- Si el rol de pagos pasa de Abierto a Aprobado, se genera la contabilidad
    IF OLD.ESTADO_PAG = 'ABI' AND NEW.ESTADO_PAG = 'APR' THEN
        SET v_id_asiento = CONCAT('AS-', RIGHT(NEW.id_Pago, 7));

        -- Resumen de todos los empleados en ese rol de pago
        SELECT IFNULL(SUM(pxe_Sueldo), 0), IFNULL(SUM(pxe_Bonificaciones), 0), 
               IFNULL(SUM(pxe_Descuentos), 0), IFNULL(SUM(pxe_Valor_Neto), 0)
        INTO v_total_sueldo, v_total_bonos, v_total_desc, v_total_neto
        FROM PAGxEMP WHERE id_Pago = NEW.id_Pago;

        -- El gasto contable es el sueldo bruto (Sueldos + Bonos)
        SET v_total_nomina = v_total_sueldo + v_total_bonos;

        -- Inserción en ASIENTOS (Cabecera contable)
        INSERT INTO ASIENTOS (id_Asiento, asi_Descripcion, asi_Total_Debe, asi_Total_Haber, asi_FechaHora, USER_ID, ESTADO_ASI) 
        VALUES (v_id_asiento, CONCAT('Nómina ', NEW.id_Pago), v_total_nomina, v_total_nomina, NOW(), 'SYS-AUTO', 'PEN');

        -- Inserción en CTAxASI (Detalle contable aplicando la partida doble)
        INSERT INTO CTAxASI (id_Asiento, id_Cuenta, cxa_Debe, cxa_Haber, ESTADO_CXA) VALUES (v_id_asiento, 'CTA-GASTO', v_total_nomina, 0, 'ACT');
        INSERT INTO CTAxASI (id_Asiento, id_Cuenta, cxa_Debe, cxa_Haber, ESTADO_CXA) VALUES (v_id_asiento, 'CTA-PASIV', 0, v_total_desc, 'ACT');
        INSERT INTO CTAxASI (id_Asiento, id_Cuenta, cxa_Debe, cxa_Haber, ESTADO_CXA) VALUES (v_id_asiento, 'CTA-BANCO', 0, v_total_neto, 'ACT');
    END IF;
END //

DELIMITER ;
