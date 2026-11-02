USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER trg_auditarCambiosActualizacionUbicacion
ON DIRECCION 
AFTER UPDATE 
AS 
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Se registra el cambio en la tabla historial
        DECLARE @IdRegistro INT;
        DECLARE @Descripcion VARCHAR(250);

        DECLARE curDireccion CURSOR LOCAL FAST_FORWARD FOR
            SELECT 
                i.ID_DIRECCION,
                LEFT(
                    'Detalle: ' + ISNULL(d.DETALLE_DIRECCION, '') + ' -> ' + ISNULL(i.DETALLE_DIRECCION, '') +
                    ' | Prov: ' + ISNULL(CAST(d.ID_PROVINCIA AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.ID_PROVINCIA AS VARCHAR), '') +
                    ' | Cant: ' + ISNULL(CAST(d.ID_CANTON AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.ID_CANTON AS VARCHAR), '') +
                    ' | Dist: ' + ISNULL(CAST(d.ID_DISTRITO AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.ID_DISTRITO AS VARCHAR), ''),
                    250
                )
            FROM deleted d
            INNER JOIN inserted i ON d.ID_DIRECCION = i.ID_DIRECCION;

        OPEN curDireccion;
        FETCH NEXT FROM curDireccion INTO @IdRegistro, @Descripcion;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.sp_InsertarHistorialDatos
                @NombreTabla = 'DIRECCION',
                @NombreOperacion = 'UPDATE',
                @IdRegistro = @IdRegistro,
                @Descripcion = @Descripcion;

            FETCH NEXT FROM curDireccion INTO @IdRegistro, @Descripcion;
        END;

        CLOSE curDireccion;
        DEALLOCATE curDireccion;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg3 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR('Error en trg_auditarCambiosActualizacionUbicacion: %s', 16, 1, @ErrorMsg3);
    END CATCH
END;
GO
