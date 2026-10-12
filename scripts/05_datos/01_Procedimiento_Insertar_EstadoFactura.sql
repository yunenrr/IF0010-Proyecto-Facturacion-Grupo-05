GO
-- INICIO

DECLARE @Err INT;
DECLARE @Msg VARCHAR(100);

EXEC dbo.pr_InsertarEstadoFactura
    @ESTADO_FACTURA = 'BORRADOR',
    @DESCRIPCION = 'Se esta preparando la factura',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarEstadoFactura
    @ESTADO_FACTURA = 'EMITIDA',
    @DESCRIPCION = 'Factura realizada',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarEstadoFactura
    @ESTADO_FACTURA = 'PAGADA',
    @DESCRIPCION = 'Factura cancelada',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarEstadoFactura
    @ESTADO_FACTURA = 'CANCELADA',
    @DESCRIPCION = 'Factura Anulada',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;
GO
-- FIN