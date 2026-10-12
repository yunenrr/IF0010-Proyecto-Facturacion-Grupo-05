USE FACTURACION_SA;
GO

DROP PROCEDURE IF EXISTS DBO.PR_EMITIRFACTURA;
GO
CREATE PROCEDURE DBO.PR_EMITIRFACTURA (
    @IDENTIFICADOR_FACTURA VARCHAR(30),
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
    DECLARE @BASEPROD INT = @NUMERO_CONSECUTIVO * 5;
    BEGIN TRY
        -- Validar identificador de factura
        IF
            @IDENTIFICADOR_FACTURA IS NULL
            BEGIN
                THROW 50100,
                'El Identificador de la Factura no puede ser nulo',
                1;
        END;

        INSERT INTO DBO.FACTURA (
            IDENTIFICADOR_FACTURA,
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
            @IDENTIFICADOR_FACTURA,
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
        SET @IDFACTURA = SCOPE_IDENTITY();
        INSERT INTO DBO.DETALLE_FACTURA (
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
            @IDFACTURA AS ID_FACTURA,
            LP.NUMERO_LINEA,
            LP.IDPROD AS ID_PRODUCTO,
            LP.CANT AS CANTIDAD,
            LP.PRECIO AS PRECIO_UNITARIO_VENTA,
            ROUND((@TOTAL_DESCUENTO / @LINEASTOTALES), 2) AS MONTO_DESCUENTO,
            LP.PRECIO * LP.CANT AS MONTO_SUBTOTAL,
            LP.PRECIO * LP.CANT * (LP.PORCENTAJE / 100.0) AS MONTO_IMPUESTO,
            'Detalle generado automaticamente' AS DESCRIPCION
        FROM (
            SELECT
                CD.NUMERO_LINEA,
                CD.IDPROD,
                CD.CANT,
                ISNULL(P.PRECIO_UNITARIO, 1000.00) AS PRECIO,
                ISNULL(P.PORCENTAJE_IMPUESTO, 13.00) AS PORCENTAJE
            FROM (
                SELECT
                    V.LINEA AS NUMERO_LINEA,
                    ((@BASEPROD + V.LINEA - 1) % 1000) + 1 AS IDPROD,
                    ((@NUMERO_CONSECUTIVO + V.LINEA) % 5) + 1 AS CANT
                FROM (VALUES (1), (2), (3), (4), (5)) AS V(LINEA)
                WHERE V.LINEA <= @LINEASTOTALES
            ) AS CD
            LEFT JOIN DBO.PRODUCTO AS P
                ON CD.IDPROD = P.ID
        ) AS LP;
        UPDATE F
        SET
            SUBTOTAL = TD.SUBTOTALSUM,
            TOTAL_IMPUESTO = TD.IMPUESTOSUM,
            MONTO_TOTAL = TD.SUBTOTALSUM - F.TOTAL_DESCUENTO + TD.IMPUESTOSUM
        FROM DBO.FACTURA AS F
        INNER JOIN (
            SELECT
                DF.ID_FACTURA,
                SUM(DF.MONTO_SUBTOTAL) AS SUBTOTALSUM,
                SUM(DF.MONTO_IMPUESTO) AS IMPUESTOSUM
            FROM DBO.DETALLE_FACTURA AS DF
            WHERE
                DF.ID_FACTURA = @IDFACTURA
            GROUP BY
                DF.ID_FACTURA
        ) AS TD
            ON F.ID = TD.ID_FACTURA;
    END TRY
    BEGIN CATCH
        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH;
END;
GO
