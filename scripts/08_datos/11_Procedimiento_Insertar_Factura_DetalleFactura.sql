USE FACTURACION_SA;
GO

-- INICIO
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @FACTURA INT = 1;
DECLARE @TAMBLOQUE INT = 10000;

DECLARE @NUMEROCONSECUTIVO INT; -- Declarada correctamente
DECLARE @FECHA DATETIME2;
DECLARE @DESCUENTO DECIMAL(10, 2);
DECLARE @IDEMPRESA INT;
DECLARE @IDCLIENTE INT;
DECLARE @MONEDA CHAR(3);
DECLARE @IDESTADO INT;
DECLARE @IDDOCUMENTO INT;
DECLARE @ERR INT;
DECLARE @MSG VARCHAR(255);

BEGIN TRANSACTION;

WHILE @FACTURA <= 500000
    BEGIN
        SET @NUMEROCONSECUTIVO = @FACTURA;
        SET @IDEMPRESA = ((@FACTURA - 1) % 100) + 1;
        SET @IDCLIENTE = ((@FACTURA - 1) % 50000) + 1;
        SET @IDESTADO = ((@FACTURA - 1) % 4) + 1;
        SET @IDDOCUMENTO = ((@FACTURA - 1) % 2) + 1;

        -- Asignamos la fecha/hora para la emision
        SET @FECHA = DATEADD(
            SECOND,
            @FACTURA,
            DATEADD(DAY, -(@FACTURA % 365), CAST(GETDATE() AS DATETIME2))
        );
        SET @DESCUENTO = CAST((@FACTURA % 101) AS DECIMAL(10, 2));
        SET @MONEDA = CASE WHEN (@FACTURA % 2) = 0 THEN 'USD' ELSE 'CRC' END;

        EXECUTE DBO.PR_EMITIRFACTURA
            @IDENTIFICADOR_FACTURA = NULL, -- Usa generacion interna
            @NUMERO_CONSECUTIVO = @NUMEROCONSECUTIVO,
            @FECHA_CREACION = @FECHA,
            @FECHA_MODIFICACION = @FECHA,
            @FECHA_EMISION = @FECHA,
            @SUBTOTAL = 0.00,
            @TOTAL_DESCUENTO = @DESCUENTO,
            @TOTAL_IMPUESTOS = 0.00,
            @MONTO_TOTAL = 0.00,
            @OBSERVACIONES = 'Factura generada automaticamente',
            @CODIGO_MONEDA = @MONEDA,
            @ID_ESTADO_FACTURA = @IDESTADO,
            @ID_EMPRESA = @IDEMPRESA,
            @ID_CLIENTE = @IDCLIENTE,
            @CODIGO_DOCUMENTO = @IDDOCUMENTO,
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;

        IF @ERR <> 0 OR XACT_STATE() = -1
            BEGIN
                IF XACT_STATE() <> 0
                    BEGIN
                        ROLLBACK TRANSACTION;
                    END;

                BREAK;
            END;

        -- Control de transacciones en bloques de 10000
        IF @FACTURA % @TAMBLOQUE = 0
            BEGIN
                COMMIT TRANSACTION;
                BEGIN TRANSACTION;
            END;

        SET @FACTURA += 1;
    END;

IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;
    END;
GO
-- FIN
