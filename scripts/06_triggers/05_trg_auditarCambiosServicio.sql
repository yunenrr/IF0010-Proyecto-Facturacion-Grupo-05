USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER dbo.trg_auditarCambiosServicio 
ON dbo.SERVICIO 
AFTER UPDATE 
AS 
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @IdRegistro INT;
        DECLARE @Descripcion VARCHAR(250);

        DECLARE curServicio CURSOR LOCAL FAST_FORWARD FOR
            SELECT 
                i.ID,
                LEFT(
                    'Cod: ' + ISNULL(d.CODIGO, '') + ' -> ' + ISNULL(i.CODIGO, '') +
                    ' | Desc: ' + ISNULL(d.DESCRIPCION, '') + ' -> ' + ISNULL(i.DESCRIPCION, '') +
                    ' | Precio: ' + ISNULL(CAST(d.PRECIO_UNITARIO AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.PRECIO_UNITARIO AS VARCHAR), '') +
                    ' | Activo: ' + ISNULL(CAST(d.ESTADO_ACTIVO AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.ESTADO_ACTIVO AS VARCHAR), ''),
                    250
                )
            FROM deleted d
            INNER JOIN inserted i ON d.ID = i.ID;

        OPEN curServicio;
        FETCH NEXT FROM curServicio INTO @IdRegistro, @Descripcion;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.sp_InsertarHistorialDatos
                @NombreTabla = 'SERVICIO',
                @NombreOperacion = 'UPDATE',
                @IdRegistro = @IdRegistro,
                @Descripcion = @Descripcion;

            FETCH NEXT FROM curServicio INTO @IdRegistro, @Descripcion;
        END;

        CLOSE curServicio;
        DEALLOCATE curServicio;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg5 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR('Error en trg_auditarCambiosServicio: %s', 16, 1, @ErrorMsg5);
    END CATCH
END;
GO
