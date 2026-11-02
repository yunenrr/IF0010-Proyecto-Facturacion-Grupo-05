USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER dbo.trg_auditarCambiosFactura 
ON dbo.FACTURA 
AFTER UPDATE 
AS 
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    BEGIN TRY
        -- Actualizar la fecha de modificación de la factura
        UPDATE f 
        SET f.FECHA_MODIFICACION = GETDATE()
        FROM dbo.FACTURA f
        INNER JOIN inserted i ON f.ID = i.ID;

        DECLARE @IdFactura INT;
        DECLARE @EstadoPrevio VARCHAR(25);
        DECLARE @EstadoNuevo VARCHAR(25);
        DECLARE @Usuario VARCHAR(100) = SUSER_SNAME();
        DECLARE @CodigoError INT;
        DECLARE @MensajeError VARCHAR(100);

        DECLARE curFactura CURSOR LOCAL FAST_FORWARD FOR
            SELECT 
                i.ID,
                CAST(d.ID_ESTADO_FACTURA AS VARCHAR),
                CAST(i.ID_ESTADO_FACTURA AS VARCHAR)
            FROM deleted d
            INNER JOIN inserted i ON d.ID = i.ID;

        OPEN curFactura;
        FETCH NEXT FROM curFactura INTO @IdFactura, @EstadoPrevio, @EstadoNuevo;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Se invoca el procedimiento dedicado para la tabla HISTORIAL
            EXEC dbo.PR_INSERTARHISTORIAL
                @ID_FACTURA = @IdFactura,
                @ID_REGISTRO_AFECTADO = @IdFactura,
                @OPERACION_REALIZADA = 'UPDATE',
                @ESTADO_PREVIO = @EstadoPrevio,
                @ESTADO_NUEVO = @EstadoNuevo,
                @TABLA_AFECTADA = 'FACTURA',
                @DESCRIPCION = 'Actualización en el encabezado de factura',
                @USUARIO_RESPONSABLE = @Usuario,
                @CODIGO_ERROR = @CodigoError OUTPUT,
                @MENSAJE_ERROR = @MensajeError OUTPUT;

            FETCH NEXT FROM curFactura INTO @IdFactura, @EstadoPrevio, @EstadoNuevo;
        END;

        CLOSE curFactura;
        DEALLOCATE curFactura;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg6 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR('Error en trg_auditarCambiosFactura: %s', 16, 1, @ErrorMsg6);
    END CATCH
END;
GO
