USE [FACTURACION_SA];
GO

-- INICIO
IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE [name] = 'pr_InsertarCanton' AND [type] = 'P')
BEGIN
    DROP PROCEDURE [dbo].[pr_InsertarCanton];
END;
GO

CREATE PROCEDURE [dbo].[pr_InsertarCanton] (
    @NOMBRE VARCHAR(30),
    @DETALLE_CANTON VARCHAR(100),
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
        IF @NOMBRE IS NULL OR @DETALLE_CANTON IS NULL
        BEGIN;
            THROW 50100, 'Parametros nulos', 1;
        END;

        INSERT INTO [dbo].[CANTON] (
            [NOMBRE],
            [DETALLE_CANTON]
        )
        VALUES (
            @NOMBRE,
            @DETALLE_CANTON
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
