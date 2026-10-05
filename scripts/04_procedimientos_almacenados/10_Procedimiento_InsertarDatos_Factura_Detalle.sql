USE FACTURACION_SA;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'pr_EmitirFactura' AND type = 'P')
BEGIN
    DROP PROCEDURE dbo.pr_EmitirFactura;
END;
GO

CREATE PROCEDURE dbo.pr_EmitirFactura (
    @NUMERO_CONSECUTIVO INT,
    @FECHA_CREACION DATE,
    @FECHA_MODIFICACION DATE,
    @FECHA_EMISION DATE,
    @SUBTOTAL DECIMAL(18, 2),
    @TOTAL_DESCUENTO DECIMAL(10, 2),
    @TOTAL_IMPUESTOS DECIMAL(19, 2),
    @MONTO_TOTAL DECIMAL(19, 2),
    @OBSERVACIONES VARCHAR(100),
    @CODIGO_MONEDA CHAR(3),
    @ID_ESTADO_FACTURA INT,
    @ID_EMPRESA INT,
    @ID_CLIENTE INT,
    @CODIGO_DOCUMENTO INT,
    @CODIGO_ERROR INT OUTPUT,
    @MENSAJE_ERROR VARCHAR(255) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @CODIGO_ERROR = 0;
    SET @MENSAJE_ERROR = 'Exitoso';

    DECLARE @IdFactura INT;
    DECLARE @LineasTotales INT;
    DECLARE @Linea INT = 1;
    DECLARE @IdProd INT;
    DECLARE @Cant INT;
    DECLARE @PrecioUnit DECIMAL(18, 2);
    DECLARE @ImpPct DECIMAL(5, 2);
    DECLARE @DescLinea DECIMAL(18, 2);
    DECLARE @SubtotalLinea DECIMAL(18, 2);
    DECLARE @ImpuestoLinea DECIMAL(18, 2);

    BEGIN TRY
        -- Validaciones de parametros
        IF @NUMERO_CONSECUTIVO IS NULL THROW 50100, 'El numero consecutivo es nulo', 1;
        IF @SUBTOTAL IS NULL THROW 50100, 'El subtotal no puede ser nulo', 1;
        IF @TOTAL_DESCUENTO IS NULL THROW 50100, 'El total descuento no puede ser nulo', 1;
        IF @TOTAL_IMPUESTOS IS NULL THROW 50100, 'El numero de impuestos no puede ser nulo', 1;
        IF @MONTO_TOTAL IS NULL THROW 50100, 'El monto total no puede ser nulo', 1;
        IF @CODIGO_MONEDA IS NULL THROW 50100, 'El codigo de moneda no puede ser nulo', 1;
        IF @ID_ESTADO_FACTURA IS NULL THROW 50100, 'El estado de factura no puede ser nulo', 1;
        IF @ID_EMPRESA IS NULL THROW 50100, 'El id de empresa no puede ser nulo', 1;
        IF @ID_CLIENTE IS NULL THROW 50100, 'El id de cliente no puede ser nulo', 1;
        IF @CODIGO_DOCUMENTO IS NULL THROW 50100, 'El codigo de documento no puede ser nulo', 1;

        -- Insercion Factura
        INSERT INTO dbo.FACTURA (
            NUMERO_CONSECUTIVO,
            FECHA_CREACION,
            FECHA_MODIFICACION,
            FECHA_EMISION,
            SUBTOTAL,
            TOTAL_DESCUENTO,
            TOTAL_IMPUESTO,
            MONTO_TOTAL,
            OBSERVACIONES_ADICIONALES,
            CODIGO_MONEDA,
            ID_ESTADO_FACTURA,
            ID_EMPRESA,
            ID_CLIENTE,
            CODIGO_IDENTIFICADOR_DOCUMENTO
        )
        VALUES (
            @NUMERO_CONSECUTIVO,
            ISNULL(@FECHA_CREACION, CAST(GETDATE() AS DATE)),
            ISNULL(@FECHA_MODIFICACION, CAST(GETDATE() AS DATE)),
            ISNULL(@FECHA_EMISION, CAST(GETDATE() AS DATE)),
            @SUBTOTAL,
            @TOTAL_DESCUENTO,
            @TOTAL_IMPUESTOS,
            @MONTO_TOTAL,
            ISNULL(@OBSERVACIONES, 'N/A'),
            @CODIGO_MONEDA,
            @ID_ESTADO_FACTURA,
            @ID_EMPRESA,
            @ID_CLIENTE,
            @CODIGO_DOCUMENTO
        );

        -- Id Factura
        SET @IdFactura = SCOPE_IDENTITY();

        -- Insercion detalles
        SET @LineasTotales = ((@NUMERO_CONSECUTIVO % 3) + 3);

        WHILE @Linea <= @LineasTotales
        BEGIN
            SET @IdProd = (((@NUMERO_CONSECUTIVO * 5 + @Linea) - 1) % 1000) + 1;
            SET @Cant = ((@NUMERO_CONSECUTIVO + @Linea) % 5) + 1;

            SELECT @PrecioUnit = PRECIO_UNITARIO, @ImpPct = PORCENTAJE_IMPUESTO
            FROM dbo.PRODUCTO
            WHERE ID = @IdProd;

            SET @DescLinea = ROUND((@TOTAL_DESCUENTO / @LineasTotales), 2);
            SET @SubtotalLinea = ISNULL(@PrecioUnit, 1000.00) * @Cant;
            SET @ImpuestoLinea = @SubtotalLinea * (ISNULL(@ImpPct, 13.00) / 100.0);

            INSERT INTO dbo.DETALLE_FACTURA (
                ID_FACTURA,
                NUMERO_LINEA,
                ID_PRODUCTO,
                CANTIDAD,
                PRECIO_UNITARIO_VENTA,
                MONTO_DESCUENTO,
                MONTO_SUBTOTAL,
                MONTO_IMPUESTO,
                DESCRIPCION
            )
            VALUES (
                @IdFactura,
                @Linea,
                @IdProd,
                @Cant,
                ISNULL(@PrecioUnit, 1000.00),
                @DescLinea,
                @SubtotalLinea,
                @ImpuestoLinea,
                'Detalle generado automaticamente'
            );

            SET @Linea += 1;
        END;

    END TRY
    BEGIN CATCH
        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH;
END;
GO