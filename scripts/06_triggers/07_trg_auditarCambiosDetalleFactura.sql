USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER DBO.TRG_AUDITARCAMBIOSDETALLEFACTURA
ON DBO.DETALLE_FACTURA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @USUARIO VARCHAR(100) = SUSER_SNAME();

        -- Solo INSERT: un unico registro de historial por factura
        IF NOT EXISTS (SELECT 1 FROM DELETED)
            BEGIN
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
                    I.ID_FACTURA,
                    MIN(I.NUMERO_LINEA) AS ID_REGISTRO_AFECTADO,
                    'INSERT' AS OPERACION_REALIZADA,
                    'N/A' AS ESTADO_PREVIO,
                    'N/A' AS ESTADO_NUEVO,
                    SYSDATETIME() AS FECHA_HORA,
                    'DETALLE_FACTURA' AS TABLA_AFECTADA,
                    LEFT(
                        CONCAT(
                            'Registro creado. Lineas: ',
                            COUNT(*),
                            ' | ',
                            STRING_AGG(
                                CONCAT(
                                    'L',
                                    I.NUMERO_LINEA,
                                    ' Prod: ',
                                    I.ID_PRODUCTO
                                ),
                                ' ; '
                            )
                        ),
                        200
                    ) AS DESCRIPCION,
                    @USUARIO AS USUARIO_RESPONSABLE
                FROM INSERTED AS I
                GROUP BY I.ID_FACTURA;

                RETURN;
            END;

        -- UPDATE y DELETE: se conserva un registro por linea
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
            COALESCE(I.ID_FACTURA, D.ID_FACTURA) AS ID_FACTURA,
            COALESCE(I.NUMERO_LINEA, D.NUMERO_LINEA) AS ID_REGISTRO_AFECTADO,
            CASE
                WHEN D.ID_FACTURA IS NULL
                    THEN 'INSERT'
                WHEN I.ID_FACTURA IS NULL
                    THEN 'DELETE'
                ELSE 'UPDATE'
            END AS OPERACION_REALIZADA,
            'N/A' AS ESTADO_PREVIO,
            'N/A' AS ESTADO_NUEVO,
            SYSDATETIME() AS FECHA_HORA,
            'DETALLE_FACTURA' AS TABLA_AFECTADA,
            CASE
                WHEN D.ID_FACTURA IS NULL
                    THEN
                        LEFT(
                            'Registro creado. Prod: '
                            + ISNULL(CAST(I.ID_PRODUCTO AS VARCHAR), ''),
                            200
                        )
                WHEN I.ID_FACTURA IS NULL
                    THEN
                        LEFT(
                            'Registro eliminado. Prod: '
                            + ISNULL(CAST(D.ID_PRODUCTO AS VARCHAR), ''),
                            200
                        )
                ELSE
                    LEFT(
                        'Cant: '
                        + ISNULL(CAST(D.CANTIDAD AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.CANTIDAD AS VARCHAR), '')
                        + ' | Precio: '
                        + ISNULL(
                            CAST(D.PRECIO_UNITARIO_VENTA AS VARCHAR),
                            ''
                        )
                        + ' -> '
                        + ISNULL(
                            CAST(I.PRECIO_UNITARIO_VENTA AS VARCHAR),
                            ''
                        )
                        + ' | Prod: '
                        + ISNULL(CAST(D.ID_PRODUCTO AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.ID_PRODUCTO AS VARCHAR), ''),
                        200
                    )
            END AS DESCRIPCION,
            @USUARIO AS USUARIO_RESPONSABLE
        FROM DELETED AS D
        FULL OUTER JOIN INSERTED AS I
            ON
                D.ID_FACTURA = I.ID_FACTURA
                AND D.NUMERO_LINEA = I.NUMERO_LINEA;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;

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
