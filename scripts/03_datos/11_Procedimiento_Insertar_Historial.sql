USE FACTURACION_SA;
GO

-- INICIO
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Variables de control
DECLARE @FACTURA INT = 1;
DECLARE @ERR INT;
DECLARE @MSG VARCHAR(100);
DECLARE @ESTADOACTUAL VARCHAR(25);
DECLARE @USUARIO VARCHAR(100);

WHILE @FACTURA <= 500
BEGIN
    -- Mapeo circular simple para variabilidad de datos de auditoria
    SET @ESTADOACTUAL = CHOOSE(
        (@FACTURA % 4) + 1,
        'EMITIDA',
        'PAGADA',
        'ANULADA',
        'PENDIENTE'
    );
    
    SET @USUARIO = CHOOSE(
        (@FACTURA % 3) + 1,
        'admin_sistema',
        'operador_caja',
        'proceso_automatico'
    );

    -- Insercion del registro de trazabilidad
    EXEC dbo.pr_InsertarHistorial
        @ID_FACTURA = @FACTURA,
        @ID_REGISTRO_AFECTADO = @FACTURA,
        @OPERACION_REALIZADA = 'INSERT',
        @ESTADO_PREVIO = 'N/A',
        @ESTADO_NUEVO = @ESTADOACTUAL,
        @TABLA_AFECTADA = 'FACTURA',
        @DESCRIPCION = 'Emision inicial de factura registrada en bitacora',
        @USUARIO_RESPONSABLE = @USUARIO,
        @CODIGO_ERROR = @ERR OUTPUT,
        @MENSAJE_ERROR = @MSG OUTPUT;

    SET @FACTURA += 1;
END;
GO
-- FIN
