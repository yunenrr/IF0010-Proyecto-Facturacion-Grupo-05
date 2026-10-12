USE FACTURACION_SA;
GO

-- Inicio
DECLARE @CodigoError INT;
DECLARE @MensajeError VARCHAR(100);

EXEC dbo.pr_InsertarDocumento
    @DESCRIPCION = 'Factura Electronica',
    @CODIGO_ERROR = @CodigoError OUTPUT,
    @MENSAJE_ERROR = @MensajeError OUTPUT;

EXEC dbo.pr_InsertarDocumento
    @DESCRIPCION = 'Tiquete Electronica',
    @CODIGO_ERROR = @CodigoError OUTPUT,
    @MENSAJE_ERROR = @MensajeError OUTPUT;
GO
-- FIN