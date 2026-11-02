USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER TRG_AUDITARCAMBIOSACTUALIZACIONUBICACION
ON DIRECCION
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Se registra el cambio en la tabla historial
        DECLARE @IdRegistro INT;
        DECLARE @Descripcion VARCHAR(250);

        DECLARE CURDIRECCION CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            I.ID_DIRECCION,
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
            ) AS DESCRIPCION
        FROM DELETED AS D
        INNER JOIN INSERTED AS I ON D.ID_DIRECCION = I.ID_DIRECCION;

        OPEN CURDIRECCION;
        FETCH NEXT FROM CURDIRECCION INTO @IdRegistro, @Descripcion;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC DBO.SP_INSERTARHISTORIALDATOS
                    @NombreTabla = 'DIRECCION',
                    @NombreOperacion = 'UPDATE',
                    @IdRegistro = @IdRegistro,
                    @Descripcion = @Descripcion;

                FETCH NEXT FROM CURDIRECCION INTO @IdRegistro, @Descripcion;
            END;

        CLOSE CURDIRECCION;
        DEALLOCATE CURDIRECCION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg3 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR (
            'Error en trg_auditarCambiosActualizacionUbicacion: %s',
            16,
            1,
            @ErrorMsg3
        );
    END CATCH
END;
GO
