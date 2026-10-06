USE FACTURACION_SA;
GO

-- INICIO
IF EXISTS (
    SELECT 1
    FROM sys.objects
    WHERE name = 'pr_EmitirFactura'
        AND type = 'P'
)
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

    DECLARE @IDFACTURA INT;
    DECLARE @LINEASTOTALES INT = ((@NUMERO_CONSECUTIVO % 3) + 3);

    BEGIN TRY
        
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
            0.00,
            @TOTAL_DESCUENTO,
            0.00,
            0.00,
            ISNULL(@OBSERVACIONES, 'N/A'),
            @CODIGO_MONEDA,
            @ID_ESTADO_FACTURA,
            @ID_EMPRESA,
            @ID_CLIENTE,
            @CODIGO_DOCUMENTO
        );

        -- Obtener el ID 
        SET @IDFACTURA = SCOPE_IDENTITY();

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
        SELECT 
            @IDFACTURA,
            NUMEROLINEA.LINEA,
            CALCULOLINEA.IDPROD,
            CALCULOLINEA.CANT,
            ISNULL(P.PRECIO_UNITARIO, 1000.00),
            ROUND((@TOTAL_DESCUENTO / @LINEASTOTALES), 2),
            (ISNULL(P.PRECIO_UNITARIO, 1000.00) * CALCULOLINEA.CANT),
            ((ISNULL(P.PRECIO_UNITARIO, 1000.00) * CALCULOLINEA.CANT) 
                * (ISNULL(P.PORCENTAJE_IMPUESTO, 13.00) / 100.0)),
            'Detalle generado automaticamente'
        FROM (
            SELECT 1 AS LINEA 
            UNION ALL 
            SELECT 2 
            UNION ALL 
            SELECT 3
            UNION ALL 
            SELECT 4 
            WHERE @LINEASTOTALES >= 4
            UNION ALL 
            SELECT 5 
            WHERE @LINEASTOTALES >= 5
        ) AS NUMEROLINEA
        CROSS APPLY (
            SELECT 
                (
                    ((@NUMERO_CONSECUTIVO * 5 + NUMEROLINEA.LINEA) - 1) 
                    % 1000
                ) + 1 AS IDPROD,
                ((@NUMERO_CONSECUTIVO + NUMEROLINEA.LINEA) % 5) + 1 AS CANT
        ) AS CALCULOLINEA
        LEFT JOIN dbo.PRODUCTO AS P 
            ON P.ID = CALCULOLINEA.IDPROD;

        -- Actualizacion de totales
        UPDATE FACTURA
        SET 
            SUBTOTAL = TOTALDETALLES.SUBTOTALSUM,
            TOTAL_IMPUESTO = TOTALDETALLES.IMPUESTOSUM,
            MONTO_TOTAL = TOTALDETALLES.SUBTOTALSUM 
                - FACTURA.TOTAL_DESCUENTO 
                + TOTALDETALLES.IMPUESTOSUM
        FROM dbo.FACTURA AS FACTURA
        INNER JOIN (
            SELECT 
                ID_FACTURA,
                SUM(MONTO_SUBTOTAL) AS SUBTOTALSUM,
                SUM(MONTO_IMPUESTO) AS IMPUESTOSUM
            FROM dbo.DETALLE_FACTURA
            WHERE ID_FACTURA = @IDFACTURA
            GROUP BY ID_FACTURA
        ) AS TOTALDETALLES 
            ON FACTURA.ID = TOTALDETALLES.ID_FACTURA;

    END TRY
    BEGIN CATCH
        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH;
END;
GO
-- FIN
