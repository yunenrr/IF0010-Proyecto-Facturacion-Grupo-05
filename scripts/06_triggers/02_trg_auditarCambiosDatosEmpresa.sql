USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER trg_auditarCambiosDatosEmpresa
ON EMPRESA 
AFTER UPDATE 
AS 
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Se registra el cambio en la tabla historial
        DECLARE @IdRegistro INT;
        DECLARE @Descripcion VARCHAR(250);

        DECLARE curEmpresa CURSOR LOCAL FAST_FORWARD FOR
            SELECT 
                i.ID,
                LEFT(
                    'Ced: ' + ISNULL(d.CEDULA_JURIDICA, '') + ' -> ' + ISNULL(i.CEDULA_JURIDICA, '') +
                    ' | Nom: ' + ISNULL(d.NOMBRE, '') + ' -> ' + ISNULL(i.NOMBRE, '') +
                    ' | Tel: ' + ISNULL(d.TELEFONO, '') + ' -> ' + ISNULL(i.TELEFONO, '') +
                    ' | Correo: ' + ISNULL(d.CORREO_ELECTRONICO, '') + ' -> ' + ISNULL(i.CORREO_ELECTRONICO, '') +
                    ' | Permiso: ' + ISNULL(CAST(d.PERMISO_OPERAR AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.PERMISO_OPERAR AS VARCHAR), ''),
                    250
                )
            FROM deleted d
            INNER JOIN inserted i ON d.ID = i.ID;

        OPEN curEmpresa;
        FETCH NEXT FROM curEmpresa INTO @IdRegistro, @Descripcion;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.sp_InsertarHistorialDatos
                @NombreTabla = 'EMPRESA',
                @NombreOperacion = 'UPDATE',
                @IdRegistro = @IdRegistro,
                @Descripcion = @Descripcion;

            FETCH NEXT FROM curEmpresa INTO @IdRegistro, @Descripcion;
        END;

        CLOSE curEmpresa;
        DEALLOCATE curEmpresa;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMsg2 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR('Error en trg_auditarCambiosDatosEmpresa: %s', 16, 1, @ErrorMsg2);
    END CATCH
END;
GO
