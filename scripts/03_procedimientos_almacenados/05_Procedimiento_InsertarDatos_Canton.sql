USE FACTURACION_SA;
GO

-- INICIO
IF EXISTS (
    SELECT 1
    FROM SYS.OBJECTS
    WHERE NAME = 'pr_InsertarCanton'
        AND TYPE = 'P'
)
BEGIN
    DROP PROCEDURE DBO.PR_INSERTARCANTON;
END;
GO

CREATE PROCEDURE DBO.PR_INSERTARCANTON (
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

        -- Validar parametros nulos
        IF @NOMBRE IS NULL
            OR @DETALLE_CANTON IS NULL
        BEGIN;
            THROW 50100, 'Parametros nulos', 1;
        END;

        -- Validacion para evitar registros duplicados
        IF EXISTS (
            SELECT 1
            FROM DBO.CANTON
            WHERE NOMBRE = @NOMBRE
        )
        BEGIN;
            THROW 50101, 'El canton ya se encuentra registrado', 1;
        END;

        INSERT INTO DBO.CANTON (
            NOMBRE,
            DETALLE_CANTON
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
