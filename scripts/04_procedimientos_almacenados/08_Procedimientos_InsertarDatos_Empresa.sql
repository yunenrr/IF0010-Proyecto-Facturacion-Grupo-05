USE FACTURACION_SA;
GO

-- INICIO
IF 
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE NAME = 'pr_InsertarEmpresa'
        AND TYPE = 'P'
)
BEGIN
    DROP PROCEDURE DBO.PR_INSERTAREMPRESA;
END;
GO

CREATE PROCEDURE DBO.PR_INSERTAREMPRESA (
    @CEDULA_JURIDICA VARCHAR(30),
    @RAZON_SOCIAL VARCHAR(50),
    @NOMBRE VARCHAR(50),
    @CORREO_ELECTRONICO VARCHAR(70),
    @TELEFONO VARCHAR(20),
    @FECHA_CREACION DATE,
    @PERMISO_OPERAR BIT,
    @ID_DIRECCION INT,
    @CODIGO_ERROR INT OUTPUT,
    @MENSAJE_ERROR VARCHAR(100) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @CODIGO_ERROR = 0;
    SET @MENSAJE_ERROR = 'Exitoso';

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar parametros nulos
        IF 
            @CEDULA_JURIDICA IS NULL
            OR @RAZON_SOCIAL IS NULL
            OR @NOMBRE IS NULL
            OR @CORREO_ELECTRONICO IS NULL
            OR @TELEFONO IS NULL
            OR @FECHA_CREACION IS NULL
            OR @PERMISO_OPERAR IS NULL
            OR @ID_DIRECCION IS NULL
        BEGIN
            THROW 50100, 'Los parametros obligatorios no pueden ser nulos', 1;
        END

        INSERT INTO DBO.EMPRESA (
            CEDULA_JURIDICA,
            RAZON_SOCIAL,
            NOMBRE,
            CORREO_ELECTRONICO,
            TELEFONO,
            FECHA_CREACION,
            PERMISO_OPERAR,
            ID_DIRECCION
        )
        VALUES (
            @CEDULA_JURIDICA,
            @RAZON_SOCIAL,
            @NOMBRE,
            @CORREO_ELECTRONICO,
            @TELEFONO,
            @FECHA_CREACION,
            @PERMISO_OPERAR,
            @ID_DIRECCION
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH
END;
GO
-- FIN
