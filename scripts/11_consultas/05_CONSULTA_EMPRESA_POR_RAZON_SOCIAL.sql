USE FACTURACION_SA;
GO

-- INICIO
IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'CONSULTA_EMPRESA_POR_RAZON_SOCIAL'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.CONSULTA_EMPRESA_POR_RAZON_SOCIAL;
    END;
GO

CREATE PROCEDURE DBO.CONSULTA_EMPRESA_POR_RAZON_SOCIAL (
    @RAZON_SOCIAL VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @RAZON_SOCIAL = TRIM(@RAZON_SOCIAL);

    BEGIN TRY
        SELECT
            ID,
            CEDULA_JURIDICA,
            RAZON_SOCIAL,
            NOMBRE AS NOMBRE_COMERCIAL,
            CORREO_ELECTRONICO,
            TELEFONO,
            FECHA_CREACION,
            PERMISO_OPERAR
        FROM DBO.EMPRESA
        WHERE
            RAZON_SOCIAL LIKE @RAZON_SOCIAL + '%';
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMSG VARCHAR(250) = ERROR_MESSAGE();

        RAISERROR (
            'Error al consultar empresa por razón social: %s',
            16,
            1,
            @ERRORMSG
        );
    END CATCH;
END;
GO
-- FIN
