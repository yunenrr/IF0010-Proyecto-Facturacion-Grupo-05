USE FACTURACION_SA;
GO

-- INICIO
IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'CONSULTA_TOTALES_CLIENTE_ANIO_VIGENTE'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.CONSULTA_TOTALES_CLIENTE_ANIO_VIGENTE;
    END;
GO

CREATE PROCEDURE DBO.CONSULTA_TOTALES_CLIENTE_ANIO_VIGENTE (
    @CEDULA VARCHAR(30),
    -- Si es NULL, consulta el acumulado histórico de todos los años
    @ANIO INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @CEDULA = TRIM(@CEDULA);

    BEGIN TRY
        DECLARE @FECHA_INICIO DATETIME2 = NULL;
        DECLARE @FECHA_FIN DATETIME2 = NULL;

        -- Si se especifica un año, definimos el rango de ese año
        IF @ANIO IS NOT NULL
            BEGIN
                SET @FECHA_INICIO = DATEFROMPARTS(@ANIO, 1, 1);
                SET @FECHA_FIN = DATEFROMPARTS(@ANIO + 1, 1, 1);
            END;

        SELECT
            @CEDULA AS CEDULA_CONSULTADA,
            ISNULL(@ANIO, 'Todos') AS ANIO_CONSULTADO,
            ISNULL(SUM(F.TOTAL_DESCUENTO), 0) AS TOTAL_DESCUENTOS,
            ISNULL(SUM(F.TOTAL_IMPUESTO), 0) AS TOTAL_IMPUESTOS,
            ISNULL(SUM(F.MONTO_TOTAL), 0) AS MONTO_TOTAL_FACTURADO
        FROM DBO.FACTURA AS F WITH (NOLOCK)
        LEFT JOIN DBO.CLIENTE AS C WITH (NOLOCK)
            ON F.ID_CLIENTE = C.ID
        LEFT JOIN DBO.EMPRESA AS E WITH (NOLOCK)
            ON F.ID_EMPRESA = E.ID
        WHERE
            (C.CEDULA = @CEDULA OR E.CEDULA_JURIDICA = @CEDULA)
            AND (
                @ANIO IS NULL
                OR (
                    F.FECHA_EMISION >= @FECHA_INICIO
                    AND F.FECHA_EMISION < @FECHA_FIN
                )
            );
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMSG VARCHAR(250) = ERROR_MESSAGE();
        
        RAISERROR (
            'Error al consultar totales del cliente por año: %s',
            16,
            1,
            @ERRORMSG
        );
    END CATCH;
END;
GO
-- FIN
