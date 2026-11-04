USE FACTURACION_SA;
GO

-- INICIO
IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_EMITIRFACTURA'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_EMITIRFACTURA;
    END;
GO

CREATE PROCEDURE DBO.PR_EMITIRFACTURA (
    @IDENTIFICADOR_FACTURA VARCHAR(50) = NULL,
    @NUMERO_CONSECUTIVO INT,
    @FECHA_CREACION DATE = NULL,
    @FECHA_MODIFICACION DATE = NULL,
    @FECHA_EMISION DATETIME2 = NULL,
    @SUBTOTAL DECIMAL(18, 2) = 0.00,
    @TOTAL_DESCUENTO DECIMAL(10, 2) = 0.00,
    @TOTAL_IMPUESTOS DECIMAL(19, 2) = 0.00,
    @MONTO_TOTAL DECIMAL(19, 2) = 0.00,
    @OBSERVACIONES VARCHAR(100) = NULL,
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
    DECLARE @TIPO_DOC_DESC VARCHAR(30);
    DECLARE @FECHA_EMISION_EFECTIVA DATETIME2;
    DECLARE @SUBTOTAL_CALCULADO DECIMAL(18, 2);
    DECLARE @IMPUESTO_CALCULADO DECIMAL(18, 2);
    DECLARE @TOTAL_CALCULADO DECIMAL(19, 2);

    SET @FECHA_EMISION_EFECTIVA = ISNULL(@FECHA_EMISION, GETDATE());

    BEGIN TRY
        -- Obtener la descripción del tipo de documento
        SELECT TOP 1 @TIPO_DOC_DESC = DESCRIPCION
        FROM DBO.DOCUMENTO
        WHERE CODIGO_IDENTIFICADOR = @CODIGO_DOCUMENTO;

        IF
            @IDENTIFICADOR_FACTURA IS NULL
            OR LTRIM(RTRIM(@IDENTIFICADOR_FACTURA)) = ''
            BEGIN
                SET @IDENTIFICADOR_FACTURA = DBO.FN_GENERAR_CLAVE_COMPROBANTE(
                    @FECHA_EMISION_EFECTIVA,
                    @TIPO_DOC_DESC
                );
            END;

        -- Validar la clave generada
        IF @IDENTIFICADOR_FACTURA IS NULL
            BEGIN
                THROW 50100, 'No se pudo generar la clave del Comprobante', 1;
            END;

        -- Calcular los totales antes de insertar (evita un UPDATE posterior)
        WITH LINEAS AS (
            SELECT
                ((@BASEPROD + V.LINEA - 1) % 1000) + 1 AS IDPROD,
                ((@NUMERO_CONSECUTIVO + V.LINEA) % 5) + 1 AS CANT
            FROM (
                VALUES
                (1),
                (2),
                (3),
                (4),
                (5)
            ) AS V(LINEA)
            WHERE
                V.LINEA <= @LINEASTOTALES
        ),

        PRECIOS AS (
            SELECT
                L.CANT,
                ISNULL(P.PRECIO_UNITARIO, 1000.00) AS PRECIO,
                ISNULL(P.PORCENTAJE_IMPUESTO, 13.00) AS PORC
            FROM LINEAS AS L
            LEFT JOIN DBO.PRODUCTO AS P
                ON L.IDPROD = P.ID
        )

        SELECT
            @SUBTOTAL_CALCULADO = SUM(
                CAST(PC.PRECIO * PC.CANT AS DECIMAL(18, 2))
            ),
            @IMPUESTO_CALCULADO = SUM(
                CAST(PC.PRECIO * PC.CANT * (PC.PORC / 100.0) AS DECIMAL(18, 2))
            )
        FROM PRECIOS AS PC;

        SET
            @TOTAL_CALCULADO
            = @SUBTOTAL_CALCULADO - @TOTAL_DESCUENTO + @IMPUESTO_CALCULADO;

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
            CAST(@FECHA_EMISION_EFECTIVA AS DATE),
            @SUBTOTAL_CALCULADO,
            @TOTAL_DESCUENTO,
            @IMPUESTO_CALCULADO,
            @TOTAL_CALCULADO,
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
                FROM (
                    VALUES
                    (1),
                    (2),
                    (3),
                    (4),
                    (5)
                ) AS V(LINEA)
                WHERE
                    V.LINEA <= @LINEASTOTALES
            ) AS CD
            LEFT JOIN DBO.PRODUCTO AS P
                ON CD.IDPROD = P.ID
        ) AS LP;

    END TRY
    BEGIN CATCH
        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH;
END;
GO
-- FIN
