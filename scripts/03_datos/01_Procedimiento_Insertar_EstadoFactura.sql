USE FACTURACION_SA;
GO

-- INICIO
DECLARE @ERR INT;
DECLARE @MSG VARCHAR(100);

EXEC dbo.pr_InsertarEstadoFactura
    @ESTADO_FACTURA = 'BORRADOR',
    @DESCRIPCION = 'Se esta preparando la factura',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC dbo.pr_InsertarEstadoFactura
    @ESTADO_FACTURA = 'EMITIDA',
    @DESCRIPCION = 'Factura realizada',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC dbo.pr_InsertarEstadoFactura
    @ESTADO_FACTURA = 'PAGADA',
    @DESCRIPCION = 'Factura cancelada',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC dbo.pr_InsertarEstadoFactura
    @ESTADO_FACTURA = 'CANCELADA',
    @DESCRIPCION = 'Factura Anulada',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;
GO
-- FIN
