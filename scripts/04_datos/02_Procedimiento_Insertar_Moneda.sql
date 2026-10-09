USE FACTURACION_SA;
GO

-- INICIO
DECLARE @ERR INT;
DECLARE @MSG VARCHAR(100);

-- Evitar duplicados validando la existencia de la moneda
IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.MONEDA
        WHERE CODIGO = 'CRC'
    )
    BEGIN
        EXEC DBO.PR_INSERTARMONEDA
            @CODIGO = 'CRC',
            @DESCRIPCION = 'Moneda Costarricense',
            @SIMBOLO = 'C',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.MONEDA
        WHERE CODIGO = 'USD'
    )
    BEGIN
        EXEC DBO.PR_INSERTARMONEDA
            @CODIGO = 'USD',
            @DESCRIPCION = 'Moneda Estadounidense',
            @SIMBOLO = 'D',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;
GO
-- FIN
