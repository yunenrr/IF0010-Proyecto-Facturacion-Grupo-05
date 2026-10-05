USE [FACTURACION_SA];
GO

-- INICIO
IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE [name] = 'pr_ActualizarDireccionCliente' AND [type] = 'P')
BEGIN
    DROP PROCEDURE [dbo].[pr_ActualizarDireccionCliente];
END;
GO

CREATE PROCEDURE [dbo].[pr_ActualizarDireccionCliente] (
    @ID_CLIENTE INT,
    @ID_DIRECCION_ACTUALIZAR INT,
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

        -- Validar que los datos no sean nulos
        IF @ID_CLIENTE IS NULL
        BEGIN;
            THROW 50010, 'El id de cliente no puede ser nulo', 1;
        END;

        IF @ID_DIRECCION_ACTUALIZAR IS NULL
        BEGIN;
            THROW 50010, 'El id de la direccion no puede ser nulo', 1;
        END;

        -- Validar que el cliente exista
        IF NOT EXISTS (SELECT 1 FROM [dbo].[CLIENTE] AS [C] WHERE @ID_CLIENTE = [C].[ID])
        BEGIN;
            THROW 50004, 'El cliente no se encuentra registrado', 1;
        END;

        -- Validar que la direccion a actualizar exista en el catalogo
        IF NOT EXISTS (SELECT 1 FROM [dbo].[DIRECCION] AS [D] WHERE @ID_DIRECCION_ACTUALIZAR = [D].[ID_DIRECCION])
        BEGIN;
            THROW 50006, 'La direccion proporcionada no se encuentra registrada', 1;
        END;

        UPDATE [dbo].[CLIENTE] 
        SET 
            [ID_DIRECCION] = @ID_DIRECCION_ACTUALIZAR,
            [FECHA_ULTIMA_ACTUALIZACION] = CAST(GETDATE() AS DATE) 
        WHERE [ID] = @ID_CLIENTE;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        -- Mensajes de error
        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH
END;
GO
-- FIN
