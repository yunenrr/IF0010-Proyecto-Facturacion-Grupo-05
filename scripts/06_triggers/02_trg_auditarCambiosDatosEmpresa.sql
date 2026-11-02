USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER TRG_AUDITARCAMBIOSDATOSEMPRESA
ON EMPRESA
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Se registra el cambio en la tabla historial
        DECLARE @IdRegistro INT;
        DECLARE @Descripcion VARCHAR(250);

        DECLARE CUREMPRESA CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            I.ID,
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
            ) AS DESCRIPCION
        FROM DELETED AS D
        INNER JOIN INSERTED AS I ON D.ID = I.ID;

        OPEN CUREMPRESA;
        FETCH NEXT FROM CUREMPRESA INTO @IdRegistro, @Descripcion;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC DBO.SP_INSERTARHISTORIALDATOS
                    @NombreTabla = 'EMPRESA',
                    @NombreOperacion = 'UPDATE',
                    @IdRegistro = @IdRegistro,
                    @Descripcion = @Descripcion;

                FETCH NEXT FROM CUREMPRESA INTO @IdRegistro, @Descripcion;
            END;

        CLOSE CUREMPRESA;
        DEALLOCATE CUREMPRESA;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg2 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR (
            'Error en trg_auditarCambiosDatosEmpresa: %s',
            16,
            1,
            @ErrorMsg2
        );
    END CATCH
END;
GO
