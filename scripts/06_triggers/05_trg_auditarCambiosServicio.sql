USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER DBO.TRG_AUDITARCAMBIOSSERVICIO
ON DBO.SERVICIO
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
            'SERVICIO' AS TABLA_AFECTADA,
            CASE
                WHEN D.ID IS NULL
                    THEN
                        LEFT(
                            'Registro creado. Cod: '
                            + ISNULL(I.CODIGO, ''),
                            250
                        )
                WHEN I.ID IS NULL
                    THEN
                        LEFT(
                            'Registro eliminado. Cod: '
                            + ISNULL(D.CODIGO, ''),
                            250
                        )
                ELSE
                    LEFT(
                        'Cod: '
                        + ISNULL(D.CODIGO, '')
                        + ' -> '
                        + ISNULL(I.CODIGO, '')
                        + ' | Desc: '
                        + ISNULL(D.DESCRIPCION, '')
                        + ' -> '
                        + ISNULL(I.DESCRIPCION, '')
                        + ' | Precio: '
                        + ISNULL(CAST(D.PRECIO_UNITARIO AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.PRECIO_UNITARIO AS VARCHAR), '')
                        + ' | Activo: '
                        + ISNULL(CAST(D.ESTADO_ACTIVO AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.ESTADO_ACTIVO AS VARCHAR), ''),
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

        DECLARE @ERRORMSG5 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR (
            'Error en TRG_AUDITARCAMBIOSSERVICIO: %s',
            16,
            1,
            @ERRORMSG5
        );
    END CATCH;
END;
GO
