USE FACTURACION_SA;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'TRG_AUDITARCAMBIOSDATOS'
            AND TYPE = 'TR'
    )
    BEGIN
        DROP TRIGGER DBO.TRG_AUDITARCAMBIOSDATOS;
    END;
GO

CREATE TRIGGER DBO.TRG_AUDITARCAMBIOSDATOS
ON DBO.CLIENTE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    BEGIN TRY
        -- Actualizar la fecha de la última actualización
        IF EXISTS (SELECT 1 FROM INSERTED) AND EXISTS (SELECT 1 FROM DELETED)
            BEGIN
                UPDATE C
                SET C.FECHA_ULTIMA_ACTUALIZACION = GETDATE()
                FROM DBO.CLIENTE AS C
                INNER JOIN INSERTED AS I
                    ON C.ID = I.ID;
            END;

        DECLARE @USUARIO VARCHAR(100) = SUSER_SNAME();

        -- Registrar el cambio en la tabla de historial de datos
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
            COALESCE(I.ID, D.ID) AS ID_REGISTRO,
            SYSDATETIME() AS FECHA_HORA,
            CASE
                WHEN D.ID IS NULL
                    THEN
                        LEFT(
                            'Registro creado. Ced: '
                            + ISNULL(I.CEDULA, ''),
                            250
                        )
                WHEN I.ID IS NULL
                    THEN
                        LEFT(
                            'Registro eliminado. Ced: '
                            + ISNULL(D.CEDULA, ''),
                            250
                        )
                ELSE
                    LEFT(
                        'Ced: '
                        + ISNULL(D.CEDULA, '')
                        + ' -> '
                        + ISNULL(I.CEDULA, '')
                        + ' | Nom: '
                        + ISNULL(D.NOMBRE, '')
                        + ' -> '
                        + ISNULL(I.NOMBRE, '')
                        + ' | Ap1: '
                        + ISNULL(D.PRIMER_APELLIDO, '')
                        + ' -> '
                        + ISNULL(I.PRIMER_APELLIDO, '')
                        + ' | Ap2: '
                        + ISNULL(D.SEGUNDO_APELLIDO, '')
                        + ' -> '
                        + ISNULL(I.SEGUNDO_APELLIDO, '')
                        + ' | Tel: '
                        + ISNULL(D.TELEFONO, '')
                        + ' -> '
                        + ISNULL(I.TELEFONO, '')
                        + ' | Correo: '
                        + ISNULL(D.CORREO_ELECTRONICO, '')
                        + ' -> '
                        + ISNULL(I.CORREO_ELECTRONICO, ''),
                        250
                    )
            END AS DESCRIPCION,
            @USUARIO AS USUARIO_RESPONSABLE
        FROM DELETED AS D
        FULL OUTER JOIN INSERTED AS I
            ON D.ID = I.ID
        INNER JOIN DBO.TIPO_OPERACION AS TIPO
            ON TIPO.NOMBRE_OPERACION = CASE
                WHEN D.ID IS NULL
                    THEN 'INSERT'
                WHEN I.ID IS NULL
                    THEN 'DELETE'
                ELSE 'UPDATE'
            END
        INNER JOIN DBO.TABLA_AUDITADA AS TA
            ON TA.NOMBRE_TABLA = 'CLIENTE';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;

        DECLARE @ERRORMSG1 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR (
            'Error en TRG_AUDITARCAMBIOSDATOS: %s',
            16,
            1,
            @ERRORMSG1
        );
    END CATCH;
END;
GO
