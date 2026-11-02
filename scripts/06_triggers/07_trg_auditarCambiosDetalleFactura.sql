USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER dbo.trg_auditarCambiosDetalleFactura 
ON dbo.DETALLE_FACTURA 
AFTER UPDATE 
AS 
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @IdFactura INT;
        DECLARE @NumeroLinea INT;
        DECLARE @Descripcion VARCHAR(200);
        DECLARE @Usuario VARCHAR(100) = SUSER_SNAME();
        DECLARE @CodigoError INT;
        DECLARE @MensajeError VARCHAR(100);

        DECLARE curDetalle CURSOR LOCAL FAST_FORWARD FOR
            SELECT 
                i.ID_FACTURA,
                i.NUMERO_LINEA,
                LEFT(
                    'Cant: ' + ISNULL(CAST(d.CANTIDAD AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.CANTIDAD AS VARCHAR), '') +
                    ' | Precio: ' + ISNULL(CAST(d.PRECIO_UNITARIO_VENTA AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.PRECIO_UNITARIO_VENTA AS VARCHAR), '') +
                    ' | Prod: ' + ISNULL(CAST(d.ID_PRODUCTO AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.ID_PRODUCTO AS VARCHAR), ''),
                    200
                )
            FROM deleted d
            INNER JOIN inserted i ON d.ID_FACTURA = i.ID_FACTURA 
                                 AND d.NUMERO_LINEA = i.NUMERO_LINEA;

        OPEN curDetalle;
        FETCH NEXT FROM curDetalle INTO @IdFactura, @NumeroLinea, @Descripcion;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.PR_INSERTARHISTORIAL
                @ID_FACTURA = @IdFactura,
                @ID_REGISTRO_AFECTADO = @NumeroLinea,
                @OPERACION_REALIZADA = 'UPDATE',
                @ESTADO_PREVIO = 'N/A',
                @ESTADO_NUEVO = 'N/A',
                @TABLA_AFECTADA = 'DETALLE_FACTURA',
                @DESCRIPCION = @Descripcion,
                @USUARIO_RESPONSABLE = @Usuario,
                @CODIGO_ERROR = @CodigoError OUTPUT,
                @MENSAJE_ERROR = @MensajeError OUTPUT;

            FETCH NEXT FROM curDetalle INTO @IdFactura, @NumeroLinea, @Descripcion;
        END;

        CLOSE curDetalle;
        DEALLOCATE curDetalle;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg7 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR('Error en trg_auditarCambiosDetalleFactura: %s', 16, 1, @ErrorMsg7);
    END CATCH
END;
GO
