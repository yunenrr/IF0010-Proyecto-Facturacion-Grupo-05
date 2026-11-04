USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER DBO.TRG_AUDITARCAMBIOSFACTURA
ON DBO.FACTURA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    BEGIN TRY
        -- Actualizar la fecha de modificación de la factura (solo UPDATE)
        IF EXISTS (SELECT 1 FROM INSERTED) AND EXISTS (SELECT 1 FROM DELETED)
            BEGIN
                UPDATE F
                SET F.FECHA_MODIFICACION = GETDATE()
                FROM DBO.FACTURA AS F
                INNER JOIN INSERTED AS I
                    ON F.ID = I.ID;
            END;

        DECLARE @USUARIO VARCHAR(100) = SUSER_SNAME();

        -- Se inserta masivamente en la tabla HISTORIAL
        INSERT INTO DBO.HISTORIAL (
            ID_FACTURA,
            ID_REGISTRO_AFECTADO,
            OPERACION_REALIZADA,
            ESTADO_PREVIO,
            ESTADO_NUEVO,
            FECHA_HORA,
            TABLA_AFECTADA,
            DESCRIPCION,
            USUARIO_RESPONSABLE
        )
        SELECT
            COALESCE(I.ID, D.ID) AS ID_FACTURA,
            COALESCE(I.ID, D.ID) AS ID_REGISTRO_AFECTADO,
            CASE
                WHEN D.ID IS NULL
                    THEN 'INSERT'
                WHEN I.ID IS NULL
                    THEN 'DELETE'
                ELSE 'UPDATE'
            END AS OPERACION_REALIZADA,
            ISNULL(CAST(D.ID_ESTADO_FACTURA AS VARCHAR), 'N/A')
                AS ESTADO_PREVIO,
            ISNULL(CAST(I.ID_ESTADO_FACTURA AS VARCHAR), 'N/A')
                AS ESTADO_NUEVO,
            SYSDATETIME() AS FECHA_HORA,
            'FACTURA' AS TABLA_AFECTADA,
            CASE
                WHEN D.ID IS NULL
                    THEN 'Factura creada'
                WHEN I.ID IS NULL
                    THEN 'Factura eliminada'
                ELSE 'Actualización en el encabezado de factura'
            END AS DESCRIPCION,
            @USUARIO AS USUARIO_RESPONSABLE
        FROM DELETED AS D
        FULL OUTER JOIN INSERTED AS I
            ON D.ID = I.ID;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;

        DECLARE @ERRORMSG6 VARCHAR(250) = ERROR_MESSAGE();

        RAISERROR (
            'Error en TRG_AUDITARCAMBIOSFACTURA: %s',
            16,
            1,
            @ERRORMSG6
        );
    END CATCH;
END;
GO
