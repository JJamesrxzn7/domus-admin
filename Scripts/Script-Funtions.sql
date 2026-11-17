DELIMITER //

/* ============================================================
   FUNCIÓN 1: TRADUCTOR DE ESTADOS PARA LA INTERFAZ (UI)
   ============================================================ */
-- En la BD guardas 'ABI', 'APR', pero en pantalla el usuario quiere leer 'Abierto', 'Aprobado'.
-- Esta función estandariza eso para cualquier módulo.

CREATE FUNCTION FN_TRADUCIR_ESTADO(codigo_estado CHAR(3)) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE descripcion VARCHAR(20);
    CASE codigo_estado
        WHEN 'ACT' THEN SET descripcion = 'Activo';
        WHEN 'INA' THEN SET descripcion = 'Inactivo';
        WHEN 'ABI' THEN SET descripcion = 'Abierto';
        WHEN 'APR' THEN SET descripcion = 'Aprobado';
        WHEN 'ANU' THEN SET descripcion = 'Anulado';
        WHEN 'PEN' THEN SET descripcion = 'Pendiente';
        WHEN 'ERR' THEN SET descripcion = 'Error';
        WHEN 'CON' THEN SET descripcion = 'Contabilizado';
        WHEN 'ENT' THEN SET descripcion = 'Entregado';
        WHEN 'REC' THEN SET descripcion = 'Recibido';
        ELSE SET descripcion = 'Desconocido';
    END CASE;
    RETURN descripcion;
END //

/* ============================================================
   FUNCIÓN 2: CALCULAR MARGEN DE GANANCIA (INVENTARIOS / GERENCIA)
   ============================================================ */
-- Ideal para tus reportes de gerencia. Le pasas el precio de compra y el de venta,
-- y te devuelve el porcentaje exacto de rentabilidad del licor.

CREATE FUNCTION FN_CALCULAR_MARGEN(precio_compra NUMERIC(7,2), precio_venta NUMERIC(7,2)) 
RETURNS NUMERIC(5,2)
DETERMINISTIC
BEGIN
    IF precio_compra = 0 OR precio_compra IS NULL THEN
        RETURN 100.00;
    END IF;
    RETURN ((precio_venta - precio_compra) / precio_compra) * 100;
END //

/* ============================================================
   FUNCIÓN 3: CALCULAR EDAD EXACTA (TALENTO HUMANO)
   ============================================================ */
-- En lugar de calcular edades a mano en tu código para saber si un empleado
-- es mayor de edad o si las cargas familiares aplican para bonos, usas esto en tus SELECT.

-- 1. Calcular Edad (Para el reporte de Cargas Familiares y regalos navideños)
CREATE FUNCTION fn_Calcular_Edad (p_fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_fecha_nacimiento, CURDATE());
END //

-- 2. Calcular IESS (Para automatizar la deducción del 9.45% en los roles de pago)
CREATE FUNCTION fn_Calcular_IESS (p_sueldo NUMERIC(7,2))
RETURNS NUMERIC(7,2)
DETERMINISTIC
BEGIN
    RETURN ROUND(p_sueldo * 0.0945, 2);
END //

/* ============================================================
   FUNCIÓN 4: FORMATEO DE NOMBRE COMPLETO (CLIENTES Y EMPLEADOS)
   ============================================================ */
-- Evita tener que concatenar nombres y lidiar con los espacios en blanco
-- o valores nulos (NULL) directamente en el código de tu aplicación.

CREATE FUNCTION FN_FORMATO_NOMBRE(nombre1 VARCHAR(30), nombre2 VARCHAR(30), apellido1 VARCHAR(30), apellido2 VARCHAR(30)) 
RETURNS VARCHAR(130)
DETERMINISTIC
BEGIN
    -- Concat_ws une con espacios, ignorando los nulos automáticamente
    RETURN CONCAT_WS(' ', 
        NULLIF(TRIM(nombre1), ''), 
        NULLIF(TRIM(nombre2), ''), 
        NULLIF(TRIM(apellido1), ''), 
        NULLIF(TRIM(apellido2), '')
    );
END //

DELIMITER ;
