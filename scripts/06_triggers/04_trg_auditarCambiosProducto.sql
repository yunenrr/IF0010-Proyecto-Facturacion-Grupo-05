USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER TRG_AUDITARCAMBIOSPRODUCTO
ON PRODUCTO
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Se registra el cambio en la tabla historial
        DECLARE @IdRegistro INT;
        DECLARE @Descripcion VARCHAR(250);

        DECLARE CURPRODUCTO CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            I.ID,
            LEFT(
                'Desc: '
                + ISNULL(D.DESCRIPCION, '')
                + ' -> '
                + ISNULL(I.DESCRIPCION, '')
                + ' | Precio: '
                + ISNULL(CAST(D.PRECIO_UNITARIO AS VARCHAR), '')
                + ' -> '
                + ISNULL(CAST(I.PRECIO_UNITARIO AS VARCHAR), '')
                + ' | Imp: '
                + ISNULL(CAST(D.PORCENTAJE_IMPUESTO AS VARCHAR), '')
                + ' -> '
                + ISNULL(CAST(I.PORCENTAJE_IMPUESTO AS VARCHAR), '')
                + ' | Est: '
                + ISNULL(CAST(D.ESTADO_ACTIVO AS VARCHAR), '')
                + ' -> '
                + ISNULL(CAST(I.ESTADO_ACTIVO AS VARCHAR), '')
                + ' | Venc: '
                + ISNULL(CAST(D.FECHA_VENCIMIENTO AS VARCHAR), '')
                + ' -> '
                + ISNULL(CAST(I.FECHA_VENCIMIENTO AS VARCHAR), '')
                + ' | Exist: '
                + ISNULL(CAST(D.EXISTENCIAS AS VARCHAR), '')
                + ' -> '
                + ISNULL(CAST(I.EXISTENCIAS AS VARCHAR), ''),
                250
            ) AS DESCRIPCION
        FROM DELETED AS D
        INNER JOIN INSERTED AS I ON D.ID = I.ID;

        OPEN CURPRODUCTO;
        FETCH NEXT FROM CURPRODUCTO INTO @IdRegistro, @Descripcion;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC DBO.SP_INSERTARHISTORIALDATOS
                    @NombreTabla = 'PRODUCTO',
                    @NombreOperacion = 'UPDATE',
                    @IdRegistro = @IdRegistro,
                    @Descripcion = @Descripcion;

                FETCH NEXT FROM CURPRODUCTO INTO @IdRegistro, @Descripcion;
            END;

        CLOSE CURPRODUCTO;
        DEALLOCATE CURPRODUCTO;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg4 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR (
            'Error en trg_auditarCambiosProducto: %s',
            16,
            1,
            @ErrorMsg4
        );
    END CATCH
END;
GO
