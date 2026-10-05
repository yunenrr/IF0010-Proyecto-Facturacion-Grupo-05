USE FACTURACION_SA;
GO

-- INICIO
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Variables de control
DECLARE @Factura INT = 1;
DECLARE @Err INT;
DECLARE @Msg VARCHAR(100);
DECLARE @EstadoActual VARCHAR(25);
DECLARE @Usuario VARCHAR(100);

WHILE @Factura <= 500
BEGIN
    -- Mapeo circular simple para variabilidad de datos de auditoría
    SET @EstadoActual = CHOOSE((@Factura % 4) + 1, 'EMITIDA', 'PAGADA', 'ANULADA', 'PENDIENTE');
    SET @Usuario = CHOOSE((@Factura % 3) + 1, 'admin_sistema', 'operador_caja', 'proceso_automatico');

    -- Inserción del registro de trazabilidad
    EXEC dbo.pr_InsertarHistorial
        @ID_FACTURA = @Factura,
        @ID_REGISTRO_AFECTADO = @Factura,
        @OPERACION_REALIZADA = 'INSERT',
        @ESTADO_PREVIO = 'N/A',
        @ESTADO_NUEVO = @EstadoActual,
        @TABLA_AFECTADA = 'FACTURA',
        @DESCRIPCION = 'Emision inicial de factura registrada en bitacora',
        @USUARIO_RESPONSABLE = @Usuario,
        @CODIGO_ERROR = @Err OUTPUT,
        @MENSAJE_ERROR = @Msg OUTPUT;

    SET @Factura += 1;
END;
GO
-- FIN