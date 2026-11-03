USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER DBO.TRG_AUDITARCAMBIOSDETALLEFACTURA
ON DBO.DETALLE_FACTURA
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @USUARIO VARCHAR(100) = SUSER_SNAME();

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
            I.ID_FACTURA,
            I.NUMERO_LINEA,
            'UPDATE' AS OPERACION_REALIZADA,
            'N/A' AS ESTADO_PREVIO,
            'N/A' AS ESTADO_NUEVO,
            'DETALLE_FACTURA' AS TABLA_AFECTADA,
            LEFT(
                'Cant: '
                + ISNULL(CAST(D.CANTIDAD AS VARCHAR), '')
                + ' -> '
                + ISNULL(CAST(I.CANTIDAD AS VARCHAR), '')
                + ' | Precio: '
                + ISNULL(CAST(D.PRECIO_UNITARIO_VENTA AS VARCHAR), '')
                + ' -> '
                + ISNULL(CAST(I.PRECIO_UNITARIO_VENTA AS VARCHAR), '')
                + ' | Prod: '
                + ISNULL(CAST(D.ID_PRODUCTO AS VARCHAR), '')
                + ' -> '
                + ISNULL(CAST(I.ID_PRODUCTO AS VARCHAR), ''),
                200
            ) AS DESCRIPCION,
            @USUARIO AS USUARIO_RESPONSABLE
        FROM DELETED AS D
        INNER JOIN INSERTED AS I
            ON
                D.ID_FACTURA = I.ID_FACTURA
                AND D.NUMERO_LINEA = I.NUMERO_LINEA;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ERRORMSG7 VARCHAR(250) = ERROR_MESSAGE();

        RAISERROR (
            'Error en TRG_AUDITARCAMBIOSDETALLEFACTURA: %s',
            16,
            1,
            @ERRORMSG7
        );
    END CATCH;
END;
GO
