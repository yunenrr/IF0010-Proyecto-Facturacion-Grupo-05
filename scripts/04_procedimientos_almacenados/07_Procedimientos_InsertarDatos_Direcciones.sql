USE FACTURACION_SA;
GO

-- INICIO
IF
    EXISTS (
        SELECT 1
        FROM sys.objects
        WHERE
            name = 'pr_InsertarDireccion'
            AND type = 'P'
    )
BEGIN
    DROP PROCEDURE dbo.pr_InsertarDireccion;
END;
GO

CREATE PROCEDURE dbo.pr_InsertarDireccion (
    @ID_PROVINCIA INT,
    @ID_CANTON INT,
    @ID_DISTRITO INT,
    @DETALLE_DIRECCION VARCHAR(100),
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
        IF 
            @ID_PROVINCIA IS NULL
            OR @ID_CANTON IS NULL
            OR @ID_DISTRITO IS NULL
            OR @DETALLE_DIRECCION IS NULL
        BEGIN;
            THROW 50100, 'Parámetros nulos', 1;
        END

        INSERT INTO dbo.DIRECCION (
            ID_PROVINCIA,
            ID_CANTON,
            ID_DISTRITO,
            DETALLE_DIRECCION
        )
        VALUES (
            @ID_PROVINCIA,
            @ID_CANTON,
            @ID_DISTRITO,
            @DETALLE_DIRECCION
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
