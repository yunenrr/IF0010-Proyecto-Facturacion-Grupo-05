USE FACTURACION_SA;
GO

-- INICIO
IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'pr_InsertarDistrito'
            AND TYPE = 'P'
    )
        BEGIN
            DROP PROCEDURE DBO.PR_INSERTARDISTRITO;
        END;
GO

CREATE PROCEDURE DBO.PR_INSERTARDISTRITO (
    @NOMBRE VARCHAR(30),
    @DETALLE_DISTRITO VARCHAR(100),
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

        -- Validar de parametros nulos
        IF
            @NOMBRE IS NULL
            OR @DETALLE_DISTRITO IS NULL
                BEGIN
                    THROW 50100, 'Parametros nulos', 1;
                END;

        INSERT INTO DBO.DISTRITO (
            NOMBRE,
            DETALLE_DISTRITO
        )
        VALUES (
            @NOMBRE,
            @DETALLE_DISTRITO
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
