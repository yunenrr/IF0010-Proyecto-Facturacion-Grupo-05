USE FACTURACION_SA;
GO

-- INICIO
IF EXISTS (
    SELECT 1
    FROM SYS.OBJECTS
    WHERE
        NAME = 'PR_ACTUALIZARCORREOCLIENTE'
        AND TYPE = 'P'
)
BEGIN
    DROP PROCEDURE DBO.PR_ACTUALIZARCORREOCLIENTE;
END;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZARCORREOCLIENTE (
    @ID_CLIENTE INT,
    @CORREO_ELECTRONICO_ACTUALIZAR VARCHAR(100),
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

        -- Validamos que los datos no sean nulos
        IF @ID_CLIENTE IS NULL
        BEGIN
            THROW 50100, 'El ID de cliente no puede ser nulo', 1;
        END;

        -- Regla: el correo debe tener uno de los siguientes dominios:
        -- @ucr.ac.cr, @gmail.com, @hotmail.com, @outlook.com
        IF
            @CORREO_ELECTRONICO_ACTUALIZAR IS NULL
            OR NOT (
                @CORREO_ELECTRONICO_ACTUALIZAR LIKE '%ucr.ac.cr'
                OR @CORREO_ELECTRONICO_ACTUALIZAR LIKE '%gmail.com'
                OR @CORREO_ELECTRONICO_ACTUALIZAR LIKE '%hotmail.com'
                OR @CORREO_ELECTRONICO_ACTUALIZAR LIKE '%outlook.com'
            )
        BEGIN
            THROW 50101, 'El correo no es valido o dominio no permitido', 1;
        END;

        -- Validar que el cliente exista
        IF NOT EXISTS (
            SELECT 1
            FROM DBO.CLIENTE AS C
            WHERE @ID_CLIENTE = C.ID
        )
        BEGIN
            THROW 50102, 'El cliente no se encuentra registrado', 1;
        END;

        -- Validamos que el correo a actualizar no este inscrito
        IF EXISTS (
            SELECT 1
            FROM DBO.CLIENTE AS CL
            WHERE
                CL.CORREO_ELECTRONICO = @CORREO_ELECTRONICO_ACTUALIZAR
                AND CL.ID <> @ID_CLIENTE
        )
        BEGIN
            THROW 50103, 'No se puede actualizar el correo, ya existe', 1;
        END;

        UPDATE DBO.CLIENTE
        SET
            CORREO_ELECTRONICO = @CORREO_ELECTRONICO_ACTUALIZAR,
            FECHA_ULTIMA_ACTUALIZACION = CAST(GETDATE() AS DATE)
        WHERE ID = @ID_CLIENTE;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        -- Seteamos los mensajes obtenidos
        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH;
END;
GO
-- FIN
