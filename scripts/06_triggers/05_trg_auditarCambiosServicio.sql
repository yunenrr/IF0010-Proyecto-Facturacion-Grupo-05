USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER DBO.TRG_AUDITARCAMBIOSSERVICIO
ON DBO.SERVICIO
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @IdRegistro INT;
        DECLARE @Descripcion VARCHAR(250);

        DECLARE CURSERVICIO CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            I.ID,
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
            ) AS DESCRIPCION
        FROM DELETED AS D
        INNER JOIN INSERTED AS I ON D.ID = I.ID;

        OPEN CURSERVICIO;
        FETCH NEXT FROM CURSERVICIO INTO @IdRegistro, @Descripcion;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC DBO.SP_INSERTARHISTORIALDATOS
                    @NombreTabla = 'SERVICIO',
                    @NombreOperacion = 'UPDATE',
                    @IdRegistro = @IdRegistro,
                    @Descripcion = @Descripcion;

                FETCH NEXT FROM CURSERVICIO INTO @IdRegistro, @Descripcion;
            END;

        CLOSE CURSERVICIO;
        DEALLOCATE CURSERVICIO;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg5 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR (
            'Error en trg_auditarCambiosServicio: %s',
            16,
            1,
            @ErrorMsg5
        );
    END CATCH
END;
GO
