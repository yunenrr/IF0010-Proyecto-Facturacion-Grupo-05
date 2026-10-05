USE [FACTURACION_SA];
GO

-- INICIO
IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE [name] = 'pr_ActualizarTelefonoCliente' AND [type] = 'P')
BEGIN
    DROP PROCEDURE [dbo].[pr_ActualizarTelefonoCliente];
END;
GO

CREATE PROCEDURE [dbo].[pr_ActualizarTelefonoCliente] (
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

        -- Como regla de negocio propuesta el telefono no debe tener mas de 8 numeros esto a nivel de CR que es el mercado que queremos alcanzar
        IF @TELEFONO_ACTUALIZAR IS NULL OR LEN(@TELEFONO_ACTUALIZAR) > 8 OR @TELEFONO_ACTUALIZAR LIKE '%[^0-9]%'
        BEGIN;
            THROW 50010, 'El numero proporcionado no debe ser mayor a 8 y solo deben contener caracteres numericos', 1;
        END;

        -- Validar que el cliente exista
        IF NOT EXISTS (SELECT 1 FROM [dbo].[CLIENTE] AS [C] WHERE @ID_CLIENTE = [C].[ID])
        BEGIN;
            THROW 50004, 'El cliente no se encuentra registrado', 1;
        END;

        -- Validamos que el numero a actualizar no este registrado
        IF EXISTS (
            SELECT 1 
            FROM [dbo].[CLIENTE] AS [CL] 
            WHERE @TELEFONO_ACTUALIZAR = [CL].[TELEFONO] 
            AND [CL].[ID] <> @ID_CLIENTE
        )
        BEGIN;
            THROW 50004, 'No se puede actualizar un numero ya registrado', 1;
        END;

        UPDATE [dbo].[CLIENTE] 
        SET 
            [TELEFONO] = @TELEFONO_ACTUALIZAR, 
            [FECHA_ULTIMA_ACTUALIZACION] = CAST(GETDATE() AS DATE)
        WHERE [ID] = @ID_CLIENTE;

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
    END CATCH
END;
GO
-- FIN
