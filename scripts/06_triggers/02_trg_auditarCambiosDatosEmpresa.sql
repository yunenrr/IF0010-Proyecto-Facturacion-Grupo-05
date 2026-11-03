USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER DBO.TRG_AUDITARCAMBIOSDATOSEMPRESA
ON DBO.EMPRESA
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
                WHEN D.ID IS NULL THEN 'INSERT'
                WHEN I.ID IS NULL THEN 'DELETE'
                ELSE 'UPDATE'
            END AS OPERACION_REALIZADA,
            'N/A' AS ESTADO_PREVIO,
            'N/A' AS ESTADO_NUEVO,
            SYSDATETIME() AS FECHA_HORA,
            'EMPRESA' AS TABLA_AFECTADA,
            CASE
                WHEN D.ID IS NULL THEN
                    LEFT(
                        'Registro creado. Ced: '
                        + ISNULL(I.CEDULA_JURIDICA, ''),
                        250
                    )
                WHEN I.ID IS NULL THEN
                    LEFT(
                        'Registro eliminado. Ced: '
                        + ISNULL(D.CEDULA_JURIDICA, ''),
                        250
                    )
                ELSE
                    LEFT(
                        'Ced: '
                        + ISNULL(D.CEDULA_JURIDICA, '')
                        + ' -> '
                        + ISNULL(I.CEDULA_JURIDICA, '')
                        + ' | Nom: '
                        + ISNULL(D.NOMBRE, '')
                        + ' -> '
                        + ISNULL(I.NOMBRE, '')
                        + ' | Tel: '
                        + ISNULL(D.TELEFONO, '')
                        + ' -> '
                        + ISNULL(I.TELEFONO, '')
                        + ' | Correo: '
                        + ISNULL(D.CORREO_ELECTRONICO, '')
                        + ' -> '
                        + ISNULL(I.CORREO_ELECTRONICO, '')
                        + ' | Permiso: '
                        + ISNULL(CAST(D.PERMISO_OPERAR AS VARCHAR), '')
                        + ' -> '
                        + ISNULL(CAST(I.PERMISO_OPERAR AS VARCHAR), ''),
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

        DECLARE @ERRORMSG2 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR (
            'Error en TRG_AUDITARCAMBIOSDATOSEMPRESA: %s',
            16,
            1,
            @ERRORMSG2
        );
    END CATCH;
END;
GO
