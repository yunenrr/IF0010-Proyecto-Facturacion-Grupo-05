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
        INNER JOIN INSERTED AS I
            ON F.ID = I.ID;

        DECLARE @Usuario VARCHAR(100) = SUSER_SNAME();

        -- Se inserta masivamente en la tabla HISTORIAL
        -- usando Set-Based (sin cursores)
        INSERT INTO DBO.HISTORIAL (
            ID_FACTURA,
            ID_REGISTRO_AFECTADO,
            OPERACION_REALIZADA,
            ESTADO_PREVIO,
            ESTADO_NUEVO,
            TABLA_AFECTADA,
            DESCRIPCION,
            USUARIO_RESPONSABLE
        )
        SELECT
            I.ID AS ID_FACTURA,
            I.ID AS ID_REGISTRO_AFECTADO,
            'UPDATE' AS OPERACION_REALIZADA,
            CAST(D.ID_ESTADO_FACTURA AS VARCHAR) AS ESTADO_PREVIO,
            CAST(I.ID_ESTADO_FACTURA AS VARCHAR) AS ESTADO_NUEVO,
            'FACTURA' AS TABLA_AFECTADA,
            'Actualización en el encabezado de factura' AS DESCRIPCION,
            @Usuario AS USUARIO_RESPONSABLE
        FROM DELETED AS D
        INNER JOIN INSERTED AS I
            ON D.ID = I.ID;

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
    END CATCH;
END;
GO
