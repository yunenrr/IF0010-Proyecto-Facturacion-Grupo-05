USE FACTURACION_SA;
GO

CREATE OR ALTER TRIGGER DBO.TRG_AUDITARCAMBIOSDETALLEFACTURA
ON DBO.DETALLE_FACTURA
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @IDFACTURA INT;
        DECLARE @NUMEROLINEA INT;
        DECLARE @DESCRIPCION VARCHAR(200);
        DECLARE @USUARIO VARCHAR(100) = SUSER_SNAME();
        DECLARE @CODIGOERROR INT;
        DECLARE @MENSAJEERROR VARCHAR(100);

        DECLARE CURDETALLE CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            I.ID_FACTURA,
            I.NUMERO_LINEA,
            LEFT(
                'Cant: '
                + ISNULL(CAST(D.CANTIDAD AS VARCHAR), '')
                + ' -> '
                + ISNULL(CAST(I.CANTIDAD AS VARCHAR), '')
                + ' | Precio: '
                + ISNULL(CAST(D.PRECIO_UNITARIO_VENTA AS VARCHAR), '')
                + ' -> '
                + ISNULL(CAST(I.PRECIO_UNITARIO_VENTA AS VARCHAR), '')
                + ' | Prod: '
                + ISNULL(CAST(D.ID_PRODUCTO AS VARCHAR), '')
                + ' -> '
                + ISNULL(CAST(I.ID_PRODUCTO AS VARCHAR), ''),
                200
            ) AS DESCRIPCION_CAMBIO
        FROM DELETED AS D
        INNER JOIN INSERTED AS I
            ON
                D.ID_FACTURA = I.ID_FACTURA
                AND D.NUMERO_LINEA = I.NUMERO_LINEA;

        OPEN CURDETALLE;

        FETCH NEXT FROM CURDETALLE
        INTO @IDFACTURA, @NUMEROLINEA, @DESCRIPCION;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC DBO.PR_INSERTARHISTORIAL
                    @ID_FACTURA = @IDFACTURA,
                    @ID_REGISTRO_AFECTADO = @NUMEROLINEA,
                    @OPERACION_REALIZADA = 'UPDATE',
                    @ESTADO_PREVIO = 'N/A',
                    @ESTADO_NUEVO = 'N/A',
                    @TABLA_AFECTADA = 'DETALLE_FACTURA',
                    @DESCRIPCION = @DESCRIPCION,
                    @USUARIO_RESPONSABLE = @USUARIO,
                    @CODIGO_ERROR = @CODIGOERROR OUTPUT,
                    @MENSAJE_ERROR = @MENSAJEERROR OUTPUT;

                FETCH NEXT FROM CURDETALLE
                INTO @IDFACTURA, @NUMEROLINEA, @DESCRIPCION;
            END;

        CLOSE CURDETALLE;
        DEALLOCATE CURDETALLE;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ERRORMSG7 VARCHAR(250) = ERROR_MESSAGE();

        RAISERROR (
            'Error en TRG_AUDITARCAMBIOSDETALLEFACTURA: %s',
            16,
            1,
            @ERRORMSG7
        );
    END CATCH;
END;
GO
