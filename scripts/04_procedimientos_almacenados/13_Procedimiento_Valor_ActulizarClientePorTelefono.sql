USE FACTURACION_SA;
GO

-- INICIO
IF EXISTS (
    SELECT 1
    FROM SYS.OBJECTS
    WHERE NAME = 'pr_ActualizarTelefonoCliente'
        AND TYPE = 'P'
)
BEGIN
    DROP PROCEDURE DBO.PR_ACTUALIZARTELEFONOCLIENTE;
END;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZARTELEFONOCLIENTE (
    @ID_CLIENTE INT,
    @TELEFONO_ACTUALIZAR VARCHAR(20),
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
        BEGIN;
            THROW 50010, 'El id de cliente no puede ser nulo', 1;
        END;

        -- Regla de negocio: telefono max 8 digitos (CR) y solo numeros
        IF @TELEFONO_ACTUALIZAR IS NULL
            OR LEN(@TELEFONO_ACTUALIZAR) > 8
            OR @TELEFONO_ACTUALIZAR LIKE '%[^0-9]%'
        BEGIN;
            THROW 50011, 'Telefono invalido: maximo 8 digitos numericos', 1;
        END;

        -- Validar que el cliente exista
        IF NOT EXISTS (
            SELECT 1
            FROM DBO.CLIENTE AS C
            WHERE @ID_CLIENTE = C.ID
        )
        BEGIN;
            THROW 50004, 'El cliente no se encuentra registrado', 1;
        END;

        -- Validamos que el numero a actualizar no este registrado
        IF EXISTS (
            SELECT 1
            FROM DBO.CLIENTE AS CL
            WHERE CL.TELEFONO = @TELEFONO_ACTUALIZAR
                AND CL.ID <> @ID_CLIENTE
        )
        BEGIN;
            THROW 50005, 'No se puede actualizar un numero ya registrado', 1;
        END;

        UPDATE DBO.CLIENTE
        SET
            TELEFONO = @TELEFONO_ACTUALIZAR,
            FECHA_ULTIMA_ACTUALIZACION = CAST(GETDATE() AS DATE)
        WHERE ID = @ID_CLIENTE;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        -- Seteamos los mensajes obtenido
        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH
END;
GO
-- FIN
