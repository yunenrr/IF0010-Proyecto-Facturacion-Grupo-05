USE FACTURACION_SA;
GO

-- INICIO
IF EXISTS (
    SELECT 1
    FROM sys.objects
    WHERE name = 'pr_InsertarHistorial'
        AND type = 'P'
)
BEGIN
    DROP PROCEDURE dbo.pr_InsertarHistorial;
END;
GO

CREATE PROCEDURE dbo.pr_InsertarHistorial (
    @ID_FACTURA INT,
    @ID_REGISTRO_AFECTADO INT,
    @OPERACION_REALIZADA VARCHAR(30),
    @ESTADO_PREVIO VARCHAR(25),
    @ESTADO_NUEVO VARCHAR(25),
    @TABLA_AFECTADA VARCHAR(50),
    @DESCRIPCION VARCHAR(200),
    @USUARIO_RESPONSABLE VARCHAR(100),
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

        IF @ID_FACTURA IS NULL
            OR @ID_REGISTRO_AFECTADO IS NULL
            OR @OPERACION_REALIZADA IS NULL
            OR @TABLA_AFECTADA IS NULL
            OR @USUARIO_RESPONSABLE IS NULL
        BEGIN;
            THROW 50010, 'Los parametros obligatorios no pueden ser nulos', 1;
        END;

        INSERT INTO dbo.HISTORIAL (
            ID_FACTURA,
            ID_REGISTRO_AFECTADO,
            OPERACION_REALIZADA,
            ESTADO_PREVIO,
            ESTADO_NUEVO,
            FECHA_HORA,
            TABLA_AFECTADA,
            DESCRIPCION,
            USUARIO_RESPONSABLE
        )
        VALUES (
            @ID_FACTURA,
            @ID_REGISTRO_AFECTADO,
            @OPERACION_REALIZADA,
            @ESTADO_PREVIO,
            @ESTADO_NUEVO,
            SYSDATETIME(),
            @TABLA_AFECTADA,
            ISNULL(@DESCRIPCION, 'N/A'),
            @USUARIO_RESPONSABLE
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
