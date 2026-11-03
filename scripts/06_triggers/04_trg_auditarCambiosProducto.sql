USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER DBO.TRG_AUDITARCAMBIOSPRODUCTO
ON DBO.PRODUCTO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @USUARIO VARCHAR(100) = SUSER_SNAME();

        -- Se registra el cambio
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
            CAST(NULL AS INT) AS ID_FACTURA,
            COALESCE(I.ID, D.ID) AS ID_REGISTRO_AFECTADO,
            CASE
                WHEN D.ID IS NULL
                    THEN 'INSERT'
                WHEN I.ID IS NULL
                    THEN 'DELETE'
                ELSE 'UPDATE'
            END AS OPERACION_REALIZADA,
            'N/A' AS ESTADO_PREVIO,
            'N/A' AS ESTADO_NUEVO,
            SYSDATETIME() AS FECHA_HORA,
            'PRODUCTO' AS TABLA_AFECTADA,
            CASE
                WHEN D.ID IS NULL
                    THEN
                        LEFT(
                            'Registro creado. Desc: '
                            + ISNULL(I.DESCRIPCION, ''),
                            250
                        )
                WHEN I.ID IS NULL
                    THEN
                        LEFT(
                            'Registro eliminado. Desc: '
                            + ISNULL(D.DESCRIPCION, ''),
                            250
                        )
                ELSE
                    LEFT(
                        'Desc: '
                        + ISNULL(D.DESCRIPCION, '')
                        + ' -> '
                        + ISNULL(I.DESCRIPCION, '')
                        + ' | Precio: '
                        + ISNULL(CAST(D.PRECIO_UNITARIO AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.PRECIO_UNITARIO AS VARCHAR), '')
                        + ' | Imp: '
                        + ISNULL(CAST(D.PORCENTAJE_IMPUESTO AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.PORCENTAJE_IMPUESTO AS VARCHAR), '')
                        + ' | Est: '
                        + ISNULL(CAST(D.ESTADO_ACTIVO AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.ESTADO_ACTIVO AS VARCHAR), '')
                        + ' | Venc: '
                        + ISNULL(CAST(D.FECHA_VENCIMIENTO AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.FECHA_VENCIMIENTO AS VARCHAR), '')
                        + ' | Exist: '
                        + ISNULL(CAST(D.EXISTENCIAS AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.EXISTENCIAS AS VARCHAR), ''),
                        250
                    )
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

        DECLARE @ERRORMSG4 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR (
            'Error en TRG_AUDITARCAMBIOSPRODUCTO: %s',
            16,
            1,
            @ERRORMSG4
        );
    END CATCH;
END;
GO
