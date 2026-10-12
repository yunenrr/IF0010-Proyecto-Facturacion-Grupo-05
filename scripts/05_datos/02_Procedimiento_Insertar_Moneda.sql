USE FACTURACION_SA;
GO

-- INICIO
DECLARE @Err INT;
DECLARE @Msg VARCHAR(100);

EXEC dbo.pr_InsertarMoneda
    @CODIGO = 'CRC',
    @DESCRIPCION = 'Moneda Costarricense',
    @SIMBOLO = 'C',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarMoneda
    @CODIGO = 'USD',
    @DESCRIPCION = 'Moneda Estadounidense',
    @SIMBOLO = 'D',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;
GO
-- FIN