USE FACTURACION_SA;
GO

-- INICIO
IF EXISTS (
    SELECT 1
    FROM sys.objects
    WHERE name = 'pr_InsertarEstadoFactura'
        AND type = 'P'
)
BEGIN
    DROP PROCEDURE dbo.pr_InsertarEstadoFactura;
END;
GO

CREATE PROCEDURE dbo.pr_InsertarEstadoFactura (
    @ESTADO_FACTURA VARCHAR(25),
    @DESCRIPCION VARCHAR(70),
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

        -- Validacion de parametros nulos
        IF @ESTADO_FACTURA IS NULL
            OR @DESCRIPCION IS NULL
        BEGIN;
            THROW 50100, 'Los parametros obligatorios no pueden ser nulos', 1;
        END;

        INSERT INTO dbo.ESTADO_FACTURA (
            ESTADO_FACTURA,
            DESCRIPCION
        )
        VALUES (
            @ESTADO_FACTURA,
            @DESCRIPCION
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH
END;
GO
-- FIN
