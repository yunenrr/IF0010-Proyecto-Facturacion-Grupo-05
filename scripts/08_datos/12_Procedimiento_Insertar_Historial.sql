USE FACTURACION_SA;
GO

-- INICIO
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Variable de control
DECLARE @FACTURA INT = 1;
DECLARE @ERR INT;
DECLARE @MSG VARCHAR(100);
DECLARE @ESTADOACTUAL VARCHAR(25);
DECLARE @USUARIO VARCHAR(100);

BEGIN TRY
    BEGIN TRANSACTION;

    WHILE @FACTURA <= 500
        BEGIN
            -- Mapeo circular simple para variabilidad de datos
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
            EXECUTE DBO.PR_INSERTARHISTORIAL
                @ID_FACTURA = @FACTURA,
                @ID_REGISTRO_AFECTADO = @FACTURA,
                @OPERACION_REALIZADA = 'INSERT',
                @ESTADO_PREVIO = 'N/A',
                @ESTADO_NUEVO = @ESTADOACTUAL,
                @TABLA_AFECTADA = 'FACTURA',
                @DESCRIPCION = 'Emision inicial de factura en bitacora',
                @USUARIO_RESPONSABLE = @USUARIO,
                @CODIGO_ERROR = @ERR OUTPUT,
                @MENSAJE_ERROR = @MSG OUTPUT;

            SET @FACTURA += 1;
        END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

    DECLARE @ERRORMSG VARCHAR(250) = ERROR_MESSAGE();
    RAISERROR (
        'Error en script 12: %s',
        16,
        1,
        @ERRORMSG
    );
END CATCH;
GO
-- FIN
