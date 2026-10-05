USE FACTURACION_SA;
GO

-- INICIO
IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'pr_InsertarMoneda' AND type = 'P')
BEGIN
    DROP PROCEDURE dbo.pr_InsertarMoneda;
END;
GO

CREATE PROCEDURE dbo.pr_InsertarMoneda (
    @CODIGO CHAR(3),
    @DESCRIPCION VARCHAR(100),
    @SIMBOLO VARCHAR(6),
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

        -- Validación de parámetros nulos
        IF @CODIGO IS NULL OR @DESCRIPCION IS NULL OR @SIMBOLO IS NULL
        BEGIN;
            THROW 50100, 'Los parámetros obligatorios no pueden ser nulos', 1;
        END

        INSERT INTO dbo.MONEDA (CODIGO, DESCRIPCION, SIMBOLO)
        VALUES (@CODIGO, @DESCRIPCION, @SIMBOLO);

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