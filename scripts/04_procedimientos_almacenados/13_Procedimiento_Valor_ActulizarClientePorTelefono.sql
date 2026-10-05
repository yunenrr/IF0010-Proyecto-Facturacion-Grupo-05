USE FACTURACION_SA;

GO --INICIO

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'pr_ActualizarTelefonoCliente' AND type = 'P')
BEGIN
	DROP PROCEDURE dbo.pr_ActualizarTelefonoCliente;
END

GO

CREATE PROCEDURE dbo.pr_ActualizarTelefonoCliente (
	@ID_CLIENTE INT,@telefono_actualizar VARCHAR(20),
    @CODIGO_ERROR INT OUTPUT,@MENSAJE_ERROR VARCHAR(100) OUTPUT) AS

BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	SET @CODIGO_ERROR = 0;
	SET @MENSAJE_ERROR = 'Exitoso';
	
	BEGIN TRY
		BEGIN TRANSACTION

		--Validamos que los datos no sean nulos
		IF @ID_CLIENTE IS NULL
			THROW 5010, 'El id de cliente no puede ser nulo',1;

		--Como regla de negocio propuesta el telefono no debe tener mas de 8 numeros esto a nivel de CR que es el mercado que queremos alcanzar
		IF @telefono_actualizar IS NULL OR LEN(@telefono_actualizar) > 8 OR @telefono_actualizar LIKE '%[^0-9]%'

		   THROW 5010, 'El numero proporcionado no debe ser mayor a 8 y solo deben contener caracteres numericos',1;

		--Validar que el cliente exista
		IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTE as c WHERE @ID_CLIENTE = c.ID)
			THROW 5004, 'El cliente no se encuentra registrado',1;

		--Validamos que el numero a actualizar no este registrado

		IF EXISTS( SELECT 1 FROM dbo.CLIENTE as cl WHERE @telefono_actualizar = CL.TELEFONO AND ID<> @ID_CLIENTE)
			THROW 5004 ,'No se puede actualizar un numero ya registrado',1;

		UPDATE dbo.CLIENTE SET TELEFONO = @telefono_actualizar, FECHA_ULTIMA_ACTUALIZACION = CAST(GETDATE() AS DATE)
		WHERE @ID_CLIENTE = dbo.CLIENTE.ID;

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION

		--Seteamos los mensajes obtenidos
		SET @CODIGO_ERROR = ERROR_NUMBER();
		SET @MENSAJE_ERROR = ERROR_MESSAGE();

	END CATCH
END
GO --FIN
