USE FACTURACION_SA;
GO

--verificar roles
IF DATABASE_PRINCIPAL_ID('Auditor') IS NULL 
    BEGIN
        CREATE ROLE Auditor;
    END;

IF DATABASE_PRINCIPAL_ID('DBA') IS NULL 
    BEGIN
        CREATE ROLE DBA;
    END;

--Limpiar usuarios de prueba
IF DATABASE_PRINCIPAL_ID('TestAuditor') IS NOT NULL DROP USER TestAuditor;
IF DATABASE_PRINCIPAL_ID('TestUsuario') IS NOT NULL DROP USER TestUsuario;
IF DATABASE_PRINCIPAL_ID('TestSinAcceso') IS NOT NULL DROP USER TestSinAcceso;

--Crear usuarios sin loggin
CREATE USER TestAuditor WITHOUT LOGIN;
CREATE USER TestUsuario WITHOUT LOGIN;
CREATE USER TestSinAcceso WITHOUT LOGIN;

-- Asignar el rol de Auditor al usuario correspondiente
ALTER ROLE Auditor ADD MEMBER TestAuditor;

--permisos
GRANT SELECT ON DBO.FN_CONSULTAR_HISTORIAL TO Auditor;
GRANT SELECT ON DBO.FN_CONSULTAR_HISTORIAL TO TestUsuario;
GRANT SELECT ON DBO.HISTORIAL TO TestAuditor;
GRANT SELECT ON DBO.HISTORIAL TO TestUsuario;
GO

--Ejecutar como administrador para que demostrar que devuelve datos
EXECUTE AS USER = 'TestAuditor';

SELECT
    USER_NAME() AS UsuarioPrueba,
    'Auditor' AS RolEvaluado,
    IS_ROLEMEMBER('Auditor') AS EsAuditor;

SELECT TOP 5 *
FROM DBO.FN_CONSULTAR_HISTORIAL();

REVERT;
GO

--Ejecutar como usuario normal, no da error pero devulve 0
EXECUTE AS USER = 'TestUsuario';

SELECT
    USER_NAME() AS UsuarioPrueba,
    'UsuarioComun' AS RolEvaluado,
    IS_ROLEMEMBER('Auditor') AS EsAuditor;

SELECT TOP 5 *
FROM DBO.FN_CONSULTAR_HISTORIAL();

REVERT;
GO

--Ejecutar sin usuario provoca una falla porque no se tiene permisos
EXECUTE AS USER = 'TestSinAcceso';

SELECT
    USER_NAME() AS UsuarioPrueba,
    'SinAcceso' AS RolEvaluado;

BEGIN TRY
    SELECT TOP 5 * FROM DBO.FN_CONSULTAR_HISTORIAL();
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS NumeroError,
        ERROR_MESSAGE() AS MensajeErrorExclusividad;
END CATCH;

REVERT;
GO

--Limpieza de pruebas
ALTER ROLE Auditor DROP MEMBER TestAuditor;
DROP USER TestAuditor;
DROP USER TestUsuario;
DROP USER TestSinAcceso;
GO
