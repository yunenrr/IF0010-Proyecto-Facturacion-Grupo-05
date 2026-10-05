USE [FACTURACION_SA];
GO

-- INICIO
DECLARE @ERR INT;
DECLARE @MSG VARCHAR(100);

EXEC [dbo].[pr_InsertarMoneda]
    @CODIGO = 'CRC',
    @DESCRIPCION = 'Moneda Costarricense',
    @SIMBOLO = 'C',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC [dbo].[pr_InsertarMoneda]
    @CODIGO = 'USD',
    @DESCRIPCION = 'Moneda Estadounidense',
    @SIMBOLO = 'D',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;
GO
-- FIN
