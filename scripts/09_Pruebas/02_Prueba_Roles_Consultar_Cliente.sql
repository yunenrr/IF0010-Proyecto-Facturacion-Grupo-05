USE FACTURACION_SA;
GO

--Roles para la prueba
IF DATABASE_PRINCIPAL_ID('Administrativo') IS NULL 
    BEGIN
        CREATE ROLE Administrativo;
    END;

IF DATABASE_PRINCIPAL_ID('Operativo') IS NULL 
    BEGIN
        CREATE ROLE Operativo;
    END;

--Limpieza usuario de prueba
IF DATABASE_PRINCIPAL_ID('TestAdmin') IS NOT NULL DROP USER TestAdmin;
IF DATABASE_PRINCIPAL_ID('TestOperativo') IS NOT NULL DROP USER TestOperativo;
IF DATABASE_PRINCIPAL_ID('TestSinAcceso') IS NOT NULL DROP USER TestSinAcceso;

--Crear usuarios de prueba sin login
CREATE USER TestAdmin WITHOUT LOGIN;
CREATE USER TestOperativo WITHOUT LOGIN;
CREATE USER TestSinAcceso WITHOUT LOGIN;

--Asignar miembros a sus respectivos roles
ALTER ROLE Administrativo ADD MEMBER TestAdmin;
ALTER ROLE Operativo ADD MEMBER TestOperativo;

--Otorgar permisos exclusivamente a Administrativo y Operativo
GRANT SELECT ON DBO.FN_CONSULTAR_CLIENTE_IDENTIFICACION TO Administrativo;
GRANT SELECT ON DBO.FN_CONSULTAR_CLIENTE_IDENTIFICACION TO Operativo;

-- Permisos sobre las tablas
GRANT SELECT ON DBO.CLIENTE TO TestAdmin;
GRANT SELECT ON DBO.CLIENTE TO TestOperativo;
GRANT SELECT ON DBO.CLIENTE TO TestSinAcceso;
GRANT SELECT ON DBO.EMPRESA TO TestAdmin;
GRANT SELECT ON DBO.EMPRESA TO TestOperativo;
GRANT SELECT ON DBO.EMPRESA TO TestSinAcceso;
GO

--Ejecutamos como rol administrativo tiene que mostrar datos
EXECUTE AS USER = 'TestAdmin';

SELECT 
    USER_NAME() AS UsuarioPrueba,
    'Administrativo' AS RolEvaluado,
    IS_ROLEMEMBER('Administrativo') AS EsMiembro;

SELECT * 
FROM DBO.FN_CONSULTAR_CLIENTE_IDENTIFICACION('100000001');

REVERT;
GO

--Ejecutamos como rol administreativo muestra datos enmascarados
EXECUTE AS USER = 'TestOperativo';

SELECT 
    USER_NAME() AS UsuarioPrueba,
    'Operativo' AS RolEvaluado,
    IS_ROLEMEMBER('Operativo') AS EsMiembro;

SELECT * 
FROM DBO.FN_CONSULTAR_CLIENTE_IDENTIFICACION('100000001');

REVERT;
GO

--Ejecutamos sin rol
EXECUTE AS USER = 'TestSinAcceso';

SELECT 
    USER_NAME() AS UsuarioPrueba,
    'SinAcceso' AS RolEvaluado;

-- Esta consulta debe fallar por denegación de permisos
BEGIN TRY
    SELECT * FROM DBO.FN_CONSULTAR_CLIENTE_IDENTIFICACION('100000001');
END TRY
BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS NumeroError,
        ERROR_MESSAGE() AS MensajeErrorExclusividad;
END CATCH;

REVERT;
GO

--Limpieza de usuario de prueba
ALTER ROLE Administrativo DROP MEMBER TestAdmin;
ALTER ROLE Operativo DROP MEMBER TestOperativo;
DROP USER TestAdmin;
DROP USER TestOperativo;
DROP USER TestSinAcceso;
GO
