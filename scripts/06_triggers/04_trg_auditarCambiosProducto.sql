USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER trg_auditarCambiosProducto 
ON PRODUCTO 
AFTER UPDATE 
AS 
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Se registra el cambio en la tabla historial
        DECLARE @IdRegistro INT;
        DECLARE @Descripcion VARCHAR(250);

        DECLARE curProducto CURSOR LOCAL FAST_FORWARD FOR
            SELECT 
                i.ID,
                LEFT(
                    'Desc: ' + ISNULL(d.DESCRIPCION, '') + ' -> ' + ISNULL(i.DESCRIPCION, '') +
                    ' | Precio: ' + ISNULL(CAST(d.PRECIO_UNITARIO AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.PRECIO_UNITARIO AS VARCHAR), '') +
                    ' | Imp: ' + ISNULL(CAST(d.PORCENTAJE_IMPUESTO AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.PORCENTAJE_IMPUESTO AS VARCHAR), '') +
                    ' | Est: ' + ISNULL(CAST(d.ESTADO_ACTIVO AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.ESTADO_ACTIVO AS VARCHAR), '') +
                    ' | Venc: ' + ISNULL(CAST(d.FECHA_VENCIMIENTO AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.FECHA_VENCIMIENTO AS VARCHAR), '') +
                    ' | Exist: ' + ISNULL(CAST(d.EXISTENCIAS AS VARCHAR), '') + ' -> ' + ISNULL(CAST(i.EXISTENCIAS AS VARCHAR), ''),
                    250
                )
            FROM deleted d
            INNER JOIN inserted i ON d.ID = i.ID;

        OPEN curProducto;
        FETCH NEXT FROM curProducto INTO @IdRegistro, @Descripcion;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.sp_InsertarHistorialDatos
                @NombreTabla = 'PRODUCTO',
                @NombreOperacion = 'UPDATE',
                @IdRegistro = @IdRegistro,
                @Descripcion = @Descripcion;

            FETCH NEXT FROM curProducto INTO @IdRegistro, @Descripcion;
        END;

        CLOSE curProducto;
        DEALLOCATE curProducto;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg4 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR('Error en trg_auditarCambiosProducto: %s', 16, 1, @ErrorMsg4);
    END CATCH
END;
GO
