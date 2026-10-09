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
    SET XACT_ABORT ON;

    SET @CODIGO_ERROR = 0;
    SET @MENSAJE_ERROR = 'Exitoso';

    DECLARE @IDFACTURA INT;

    DECLARE @LINEASTOTALES INT = (ABS(CHECKSUM(NEWID())) % 3) + 3;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validaciones de parametros obligatorios
        IF
            @NUMERO_CONSECUTIVO IS NULL
            OR @CODIGO_MONEDA IS NULL
            OR @ID_ESTADO_FACTURA IS NULL
            OR @ID_EMPRESA IS NULL
            OR @ID_CLIENTE IS NULL
            OR @CODIGO_DOCUMENTO IS NULL
            BEGIN
                THROW 50100,
                'Los parametros obligatorios no pueden ser nulos',
                1;
            END;

        -- Validacion Evitar facturas duplicadas
        IF
            EXISTS (
                SELECT 1
                FROM DBO.FACTURA
                WHERE NUMERO_CONSECUTIVO = @NUMERO_CONSECUTIVO
            )
            BEGIN
                THROW 50101,
                'La factura ya se encuentra registrada con ese consecutivo',
                1;
            END;

        INSERT INTO DBO.FACTURA (
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
            ISNULL(@TOTAL_DESCUENTO, 0.00),
            0.00,
            0.00,
            ISNULL(@OBSERVACIONES, 'N/A'),
            @CODIGO_MONEDA,
            @ID_ESTADO_FACTURA,
            @ID_EMPRESA,
            @ID_CLIENTE,
            @CODIGO_DOCUMENTO
        );

        -- Obtener ID
        SET @IDFACTURA = SCOPE_IDENTITY();

        WITH NUMEROLINEA AS (
            SELECT 1 AS LINEA
            UNION ALL
            SELECT 2 AS LINEA
            UNION ALL
            SELECT 3 AS LINEA
            UNION ALL
            SELECT 4 AS LINEA
            WHERE @LINEASTOTALES >= 4
            UNION ALL
            SELECT 5 AS LINEA
            WHERE @LINEASTOTALES >= 5
        ),

        CALCULOLINEABASE AS (
            SELECT
                NUMEROLINEA.LINEA,
                -- Seleccion aleatoria
                (ABS(CHECKSUM(NEWID())) % 1000) + 1 AS IDPROD,
                -- Cantidad aleatoria entre 1 y 5
                (ABS(CHECKSUM(NEWID())) % 5) + 1 AS CANT
            FROM NUMEROLINEA
        )

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
            CALCULOLINEABASE.LINEA,
            CALCULOLINEABASE.IDPROD,
            CALCULOLINEABASE.CANT,
            ISNULL(P.PRECIO_UNITARIO, 1000.00) AS PRECIO_UNITARIO_VENTA,
            ROUND(
                (ISNULL(@TOTAL_DESCUENTO, 0) / @LINEASTOTALES),
                2
            ) AS MONTO_DESCUENTO,
            (
                ISNULL(P.PRECIO_UNITARIO, 1000.00) * CALCULOLINEABASE.CANT
            ) AS MONTO_SUBTOTAL,
            (
                (ISNULL(P.PRECIO_UNITARIO, 1000.00) * CALCULOLINEABASE.CANT)
                * (ISNULL(P.PORCENTAJE_IMPUESTO, 13.00) / 100.0)
            ) AS MONTO_IMPUESTO,
            'Detalle generado automaticamente' AS DESCRIPCION
        FROM CALCULOLINEABASE
        LEFT JOIN DBO.PRODUCTO AS P
            ON CALCULOLINEABASE.IDPROD = P.ID;

        -- Actualizacion de totales
        WITH TOTALDETALLES AS (
            SELECT
                ID_FACTURA,
                SUM(MONTO_SUBTOTAL) AS SUBTOTALSUM,
                SUM(MONTO_IMPUESTO) AS IMPUESTOSUM
            FROM DBO.DETALLE_FACTURA
            WHERE ID_FACTURA = @IDFACTURA
            GROUP BY ID_FACTURA
        )

        UPDATE FACTURA
        SET
            SUBTOTAL = TOTALDETALLES.SUBTOTALSUM,
            TOTAL_IMPUESTO = TOTALDETALLES.IMPUESTOSUM,
            MONTO_TOTAL = (
                TOTALDETALLES.SUBTOTALSUM
                - ISNULL(FACTURA.TOTAL_DESCUENTO, 0)
                + TOTALDETALLES.IMPUESTOSUM
            )
        FROM DBO.FACTURA AS FACTURA
        INNER JOIN TOTALDETALLES
            ON FACTURA.ID = TOTALDETALLES.ID_FACTURA;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;

        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH;
END;
GO
-- FIN
