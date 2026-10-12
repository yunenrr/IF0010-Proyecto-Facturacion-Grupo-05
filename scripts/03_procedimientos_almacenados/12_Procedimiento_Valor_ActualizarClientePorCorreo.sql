USE FACTURACION_SA;

GO --INICIO

GO --Inicio

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'pr_ActualizarCorreoCliente' AND type = 'P')
BEGIN
	DROP PROCEDURE dbo.pr_ActualizarCorreoCliente;
END

GO

CREATE PROCEDURE dbo.pr_ActualizarCorreoCliente (
	@ID_CLIENTE INT,@CORREO_ELECTRONICO_ACTUALIZAR VARCHAR(100),
    @CODIGO_ERROR INT OUTPUT,@MENSAJE_ERROR VARCHAR(100) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	SET @CODIGO_ERROR = 0;
	SET @MENSAJE_ERROR = 'Exitoso';
	
	BEGIN TRY
		BEGIN TRANSACTION;

		--Validamos que los datos no sean nulos
		IF @ID_CLIENTE IS NULL
			THROW 5010, 'El id de cliente no puede ser nulo',1;

		--Como regla de negocio propuesta el correo debe tener obligatoriamente uno de los siguientes dominios.
		--@ucr.ac.cr, @gmail.com, @hotmail.com,@outlook.com
		IF @CORREO_ELECTRONICO_ACTUALIZAR IS NULL OR NOT (
		   @CORREO_ELECTRONICO_ACTUALIZAR LIKE '%ucr.ac.cr' OR
		   @CORREO_ELECTRONICO_ACTUALIZAR LIKE '%gmail.com' OR
		   @CORREO_ELECTRONICO_ACTUALIZAR LIKE '%hotmail.com' OR
		   @CORREO_ELECTRONICO_ACTUALIZAR LIKE '%outlook.com' )

		   THROW 5010, 'El correo proporcionado no es valido o no pertenece al dominio permitido',1;

		--Validar que el cliente exista
		IF NOT EXISTS (SELECT 1 FROM dbo.CLIENTE as c WHERE @ID_CLIENTE = c.ID)
			THROW 5004, 'El cliente no se encuentra registrado',1;

		--Validamos que el correo a actualizar no este inscrito

		IF EXISTS( SELECT 1 FROM dbo.CLIENTE as cl WHERE @CORREO_ELECTRONICO_ACTUALIZAR = CL.CORREO_ELECTRONICO 
		AND cl.ID <>@ID_CLIENTE)
			THROW 5004 ,'No se puede actualizar el correo',1;

		UPDATE dbo.CLIENTE SET CORREO_ELECTRONICO = @CORREO_ELECTRONICO_ACTUALIZAR,
		FECHA_ULTIMA_ACTUALIZACION = CAST(GETDATE() AS DATE) WHERE @ID_CLIENTE = dbo.CLIENTE.ID;

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION;

		--Seteamos los mensajes obtenidos
		SET @CODIGO_ERROR = ERROR_NUMBER();
		SET @MENSAJE_ERROR = ERROR_MESSAGE();

	END CATCH
END
GO --FIN
