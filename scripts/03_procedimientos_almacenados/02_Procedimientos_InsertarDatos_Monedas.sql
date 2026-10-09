USE FACTURACION_SA;
GO

-- INICIO
IF EXISTS (
    SELECT 1
    FROM SYS.OBJECTS
    WHERE NAME = 'pr_InsertarMoneda'
        AND TYPE = 'P'
)
BEGIN
    DROP PROCEDURE DBO.PR_INSERTARMONEDA;
END;
GO

CREATE PROCEDURE DBO.PR_INSERTARMONEDA (
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

        -- Validar parametros nulos
        IF @CODIGO IS NULL
            OR @DESCRIPCION IS NULL
            OR @SIMBOLO IS NULL
        BEGIN;
            THROW 50100, 'Los parametros obligatorios no pueden ser nulos', 1; -- noqa: LT05
        END;

        -- Validacion para evitar registros duplicados
        IF EXISTS (
            SELECT 1
            FROM DBO.MONEDA
            WHERE CODIGO = @CODIGO
        )
        BEGIN;
            THROW 50101, 'La moneda ya se encuentra registrada', 1;
        END;

        INSERT INTO DBO.MONEDA (
            CODIGO,
            DESCRIPCION,
            SIMBOLO
        )
        VALUES (
            @CODIGO,
            @DESCRIPCION,
            @SIMBOLO
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
