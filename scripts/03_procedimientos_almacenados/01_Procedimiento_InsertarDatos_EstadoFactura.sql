USE FACTURACION_SA;
GO

-- INICIO
IF EXISTS (
    SELECT 1
    FROM SYS.OBJECTS
    WHERE NAME = 'pr_InsertarEstadoFactura'
        AND TYPE = 'P'
)
BEGIN
    DROP PROCEDURE DBO.PR_INSERTARESTADOFACTURA;
END;
GO

CREATE PROCEDURE DBO.PR_INSERTARESTADOFACTURA (
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

        -- Validar parametros nulos
        IF @ESTADO_FACTURA IS NULL
            OR @DESCRIPCION IS NULL
        BEGIN;
            THROW 50100, 'Los parametros obligatorios no pueden ser nulos', 1; -- noqa: LT05
        END;

        -- Validacion para evitar registros duplicados
        IF EXISTS (
            SELECT 1
            FROM DBO.ESTADO_FACTURA
            WHERE ESTADO_FACTURA = @ESTADO_FACTURA
        )
        BEGIN;
            THROW 50101, 'El estado de factura ya se encuentra registrado', 1;
        END;

        INSERT INTO DBO.ESTADO_FACTURA (
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
