USE FACTURACION_SA;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @Factura INT = 1;
DECLARE @tamBloque INT = 10000;

DECLARE @NumeroConsecutivo INT;
DECLARE @Fecha DATE;
DECLARE @Descuento DECIMAL(10, 2);
DECLARE @IdEmpresa INT;
DECLARE @IdCliente INT;
DECLARE @Moneda CHAR(3);
DECLARE @IdEstado INT;
DECLARE @IdDocumento INT;
DECLARE @Err INT;
DECLARE @Msg VARCHAR(255);

BEGIN TRANSACTION;

WHILE @Factura <= 500000
BEGIN
    SET @NumeroConsecutivo = @Factura;
    SET @IdEmpresa = ((@Factura - 1) % 100) + 1;       
    SET @IdCliente = ((@Factura - 1) % 50000) + 1;     
    SET @IdEstado = ((@Factura - 1) % 4) + 1;          
    SET @IdDocumento = ((@Factura - 1) % 2) + 1;      
    SET @Fecha = DATEADD(DAY, -(@Factura % 365), CAST(GETDATE() AS DATE));
    SET @Descuento = CAST((@Factura % 101) AS DECIMAL(10, 2));
    SET @Moneda = CASE WHEN (@Factura % 2) = 0 THEN 'USD' ELSE 'CRC' END;

    -- Inserción llamando al procedimiento simplificado
    EXEC dbo.pr_EmitirFactura
        @NUMERO_CONSECUTIVO = @NumeroConsecutivo,
        @FECHA_CREACION = @Fecha,
        @FECHA_MODIFICACION = @Fecha,
        @FECHA_EMISION = @Fecha,
        @SUBTOTAL = 0.00,
        @TOTAL_DESCUENTO = @Descuento,
        @TOTAL_IMPUESTOS = 0.00,
        @MONTO_TOTAL = 0.00,
        @OBSERVACIONES = 'Factura generada automaticamente',
        @CODIGO_MONEDA = @Moneda,
        @ID_ESTADO_FACTURA = @IdEstado,
        @ID_EMPRESA = @IdEmpresa,
        @ID_CLIENTE = @IdCliente,
        @CODIGO_DOCUMENTO = @IdDocumento,
        @CODIGO_ERROR = @Err OUTPUT,
        @MENSAJE_ERROR = @Msg OUTPUT;

    -- Control de transacciones en bloques de 10,000
    IF @Factura % @tamBloque = 0
    BEGIN
        COMMIT TRANSACTION;
        BEGIN TRANSACTION;
    END;

    SET @Factura += 1;
END;

IF @@TRANCOUNT > 0
BEGIN
    COMMIT TRANSACTION;
END;
GO






