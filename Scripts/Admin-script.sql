/* =========================================================================
   PASO 1: DEPARTAMENTO ADMINISTRATIVO (Requerido por FK de EMPLEADOS)
   ========================================================================= */
INSERT INTO DEPARTAMENTOS (id_Departamento, id_Empleado, dep_Nombre, dep_Telefono, dep_Mail, ESTADO_DEP)
VALUES ('DEP-ADM', NULL, 'Administración General', '022999999', 'admin@lacava.com', 'ACT')
ON DUPLICATE KEY UPDATE dep_Nombre = dep_Nombre;

/* =========================================================================
   PASO 2: CREACIÓN DEL EMPLEADO DE RESPALDO
   ========================================================================= */
INSERT INTO EMPLEADOS (
    id_Empleado, id_Departamento, emp_Cedula, emp_Apellido1, emp_Apellido2, 
    emp_Nombre1, emp_Nombre2, emp_Sexo, emp_FechaNacimiento, emp_Sueldo, 
    emp_Direccion, emp_Telefono, emp_Celular, emp_Fotografia, emp_Mail, 
    USER_ID, ESTADO_EMP
) 
VALUES (
    'EMP-000001', 'DEP-ADM', '1741598872', 'Ramll', NULL, 
    'Jamws', NULL, 'M', '1981-09-12', 0.00, 
    'Calle Bernardo Valdivieso', NULL, NULL, NULL, 'jamwsr@lacava.com', 
    'USR-000001', 'ACT'
);

/* =========================================================================
   PASO 3: CREACIÓN DEL USUARIO (Mapeo exacto de las 10 columnas)
   ========================================================================= */
INSERT INTO USUARIOS (
    id_Usuario, id_Empleado, usr_Username, usr_PasswordHash, 
    usr_IntentosFallidos, usr_UltimoAcceso, usr_RequiereCambioClave, 
    usr_FechaCambioClave, usr_TokenRecuperacion, ESTADO_USR
) 
VALUES (
    'USR-000001', 'EMP-000001', 'jamwsr', '123.789.52', 
    0, '2026-10-08 08:14:15', FALSE, 
    NULL, NULL, 'ACT'
);

/* =========================================================================
   PASO 4: REGISTRO DEL ROL SUPERADMINISTRADOR
   ========================================================================= */
INSERT INTO ROLES (id_Rol, rol_Nombre, rol_Descripcion, ESTADO_ROL)
VALUES ('ROL-ADM', 'SuperAdministrador', 'Acceso total y absoluto al sistema', 'ACT')
ON DUPLICATE KEY UPDATE rol_Nombre = rol_Nombre;

/* =========================================================================
   PASO 5: ASIGNAR EL ROL AL USUARIO
   ========================================================================= */
INSERT INTO USUARIOSxROLES (id_Usuario, id_Rol, ESTADO_UxR)
VALUES ('USR-000001', 'ROL-ADM', 'ACT');

/* =========================================================================
   PASO 6: ASIGNACIÓN DINÁMICA DE TODOS LOS PERMISOS DEL SISTEMA
   ========================================================================= */
INSERT INTO ROLESxPERMISOS (id_Rol, id_Permiso, ESTADO_RxP)
SELECT 'ROL-ADM', id_Permiso, 'ACT'
FROM PERMISOS
WHERE ESTADO_PRM = 'ACT'
ON DUPLICATE KEY UPDATE ESTADO_RxP = 'ACT';