USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER DBO.TRG_AUDITARCAMBIOSACTUALIZACIONUBICACION
ON DBO.DIRECCION
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @USUARIO VARCHAR(100) = SUSER_SNAME();

        -- Se registra el cambio
        INSERT INTO DBO.HISTORIAL_DATOS (
            ID_TABLA,
            ID_OPERACION,
            ID_REGISTRO,
            FECHA_HORA,
            DESCRIPCION,
            USUARIO_RESPONSABLE
        )
        SELECT
            TA.ID AS ID_TABLA,
            TIPO.ID AS ID_OPERACION,
            COALESCE(I.ID_DIRECCION, D.ID_DIRECCION) AS ID_REGISTRO,
            SYSDATETIME() AS FECHA_HORA,
            CASE
                WHEN D.ID_DIRECCION IS NULL
                    THEN
                        LEFT(
                            'Registro creado. Detalle: '
                            + ISNULL(I.DETALLE_DIRECCION, ''),
                            250
                        )
                WHEN I.ID_DIRECCION IS NULL
                    THEN
                        LEFT(
                            'Registro eliminado. Detalle: '
                            + ISNULL(D.DETALLE_DIRECCION, ''),
                            250
                        )
                ELSE
                    LEFT(
                        'Detalle: '
                        + ISNULL(D.DETALLE_DIRECCION, '')
                        + ' -> '
                        + ISNULL(I.DETALLE_DIRECCION, '')
                        + ' | Prov: '
                        + ISNULL(CAST(D.ID_PROVINCIA AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.ID_PROVINCIA AS VARCHAR), '')
                        + ' | Cant: '
                        + ISNULL(CAST(D.ID_CANTON AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.ID_CANTON AS VARCHAR), '')
                        + ' | Dist: '
                        + ISNULL(CAST(D.ID_DISTRITO AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.ID_DISTRITO AS VARCHAR), ''),
                        250
                    )
            END AS DESCRIPCION,
            @USUARIO AS USUARIO_RESPONSABLE
        FROM DELETED AS D
        FULL OUTER JOIN INSERTED AS I
            ON D.ID_DIRECCION = I.ID_DIRECCION
        INNER JOIN DBO.TIPO_OPERACION AS TIPO
            ON TIPO.NOMBRE_OPERACION = CASE
                WHEN D.ID_DIRECCION IS NULL
                    THEN 'INSERT'
                WHEN I.ID_DIRECCION IS NULL
                    THEN 'DELETE'
                ELSE 'UPDATE'
            END
        INNER JOIN DBO.TABLA_AUDITADA AS TA
            ON TA.NOMBRE_TABLA = 'DIRECCION';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;

        DECLARE @ERRORMSG3 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR (
            'Error en TRG_AUDITARCAMBIOSACTUALIZACIONUBICACION: %s',
            16,
            1,
            @ERRORMSG3
        );
    END CATCH;
END;
GO
