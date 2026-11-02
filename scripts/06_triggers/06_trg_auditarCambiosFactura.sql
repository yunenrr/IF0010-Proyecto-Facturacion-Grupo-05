USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER DBO.TRG_AUDITARCAMBIOSFACTURA
ON DBO.FACTURA
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    BEGIN TRY
        -- Actualizar la fecha de modificación de la factura
        UPDATE F
        SET F.FECHA_MODIFICACION = GETDATE()
        FROM DBO.FACTURA AS F
        INNER JOIN INSERTED AS I ON F.ID = I.ID;

        DECLARE @IdFactura INT;
        DECLARE @EstadoPrevio VARCHAR(25);
        DECLARE @EstadoNuevo VARCHAR(25);
        DECLARE @Usuario VARCHAR(100) = SUSER_SNAME();
        DECLARE @CodigoError INT;
        DECLARE @MensajeError VARCHAR(100);

        DECLARE CURFACTURA CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            I.ID,
            CAST(D.ID_ESTADO_FACTURA AS VARCHAR) AS ESTADO_PREVIO,
            CAST(I.ID_ESTADO_FACTURA AS VARCHAR) AS ESTADO_NUEVO
        FROM DELETED AS D
        INNER JOIN INSERTED AS I ON D.ID = I.ID;

        OPEN CURFACTURA;
        FETCH NEXT FROM CURFACTURA INTO @IdFactura, @EstadoPrevio, @EstadoNuevo;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Se invoca el procedimiento dedicado para la tabla HISTORIAL
                EXEC DBO.PR_INSERTARHISTORIAL
                    @ID_FACTURA = @IdFactura,
                    @ID_REGISTRO_AFECTADO = @IdFactura,
                    @OPERACION_REALIZADA = 'UPDATE',
                    @ESTADO_PREVIO = @EstadoPrevio,
                    @ESTADO_NUEVO = @EstadoNuevo,
                    @TABLA_AFECTADA = 'FACTURA',
                    @DESCRIPCION = 'Actualización en el encabezado de factura',
                    @USUARIO_RESPONSABLE = @Usuario,
                    @CODIGO_ERROR = @CodigoError OUTPUT,
                    @MENSAJE_ERROR = @MensajeError OUTPUT;

                FETCH NEXT FROM CURFACTURA INTO @IdFactura, @EstadoPrevio, @EstadoNuevo; -- noqa: LT05
            END;

        CLOSE CURFACTURA;
        DEALLOCATE CURFACTURA;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg6 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR (
            'Error en trg_auditarCambiosFactura: %s',
            16,
            1,
            @ErrorMsg6
        );
    END CATCH
END;
GO
