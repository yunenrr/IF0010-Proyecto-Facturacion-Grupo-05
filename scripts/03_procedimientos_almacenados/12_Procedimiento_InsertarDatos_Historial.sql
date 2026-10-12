USE FACTURACION_SA;
GO

-- INICIO
IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_INSERTARHISTORIAL'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_INSERTARHISTORIAL;
    END;
GO

CREATE PROCEDURE DBO.PR_INSERTARHISTORIAL (
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

        -- Validaciones de parametros nulos
        IF
            @ID_FACTURA IS NULL
            OR @ID_REGISTRO_AFECTADO IS NULL
            OR @OPERACION_REALIZADA IS NULL
            OR @TABLA_AFECTADA IS NULL
            OR @USUARIO_RESPONSABLE IS NULL
            BEGIN
                DECLARE @MSG_NULOS VARCHAR(100);
                SET @MSG_NULOS = 'Los parametros obligatorios no '
                    + 'pueden ser nulos';

                THROW 50010, @MSG_NULOS, 1;
            END;

        -- Validacion de duplicado
        IF
            EXISTS (
                SELECT 1
                FROM DBO.HISTORIAL
                WHERE
                    ID_FACTURA = @ID_FACTURA
                    AND ID_REGISTRO_AFECTADO = @ID_REGISTRO_AFECTADO
                    AND OPERACION_REALIZADA = @OPERACION_REALIZADA
                    AND ISNULL(ESTADO_PREVIO, '') = ISNULL(@ESTADO_PREVIO, '')
                    AND ISNULL(ESTADO_NUEVO, '') = ISNULL(@ESTADO_NUEVO, '')
                    AND TABLA_AFECTADA = @TABLA_AFECTADA
            )
            BEGIN
                DECLARE @MSG_ERR VARCHAR(100);
                SET @MSG_ERR = 'El registro de historial exacto ya se '
                    + 'encuentra en la bitacora';

                THROW 50101, @MSG_ERR, 1;
            END;

        INSERT INTO DBO.HISTORIAL (
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
            ISNULL(@ESTADO_PREVIO, ''),
            ISNULL(@ESTADO_NUEVO, ''),
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
    END CATCH;
END;
GO
-- FIN
