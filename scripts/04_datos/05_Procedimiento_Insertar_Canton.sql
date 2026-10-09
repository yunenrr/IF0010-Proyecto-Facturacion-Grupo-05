USE FACTURACION_SA;
GO

-- INICIO
DECLARE @ERR INT;
DECLARE @MSG VARCHAR(100);

-- Evitar duplicados validando la existencia del canton
IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.CANTON
        WHERE NOMBRE = 'San Jose'
    )
    BEGIN
        EXEC DBO.PR_INSERTARCANTON
            @NOMBRE = 'San Jose',
            @DETALLE_CANTON = 'Canton Central de la provincia',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.CANTON
        WHERE NOMBRE = 'Escazu'
    )
    BEGIN
        EXEC DBO.PR_INSERTARCANTON
            @NOMBRE = 'Escazu',
            @DETALLE_CANTON = 'Conocido por su desarrollo urbano y comercial',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.CANTON
        WHERE NOMBRE = 'Desamparados'
    )
    BEGIN
        EXEC DBO.PR_INSERTARCANTON
            @NOMBRE = 'Desamparados',
            @DETALLE_CANTON = 'Canton de alta densidad poblacional',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.CANTON
        WHERE NOMBRE = 'Puriscal'
    )
    BEGIN
        EXEC DBO.PR_INSERTARCANTON
            @NOMBRE = 'Puriscal',
            @DETALLE_CANTON = 'Territorio de topografia irregular y agricola',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.CANTON
        WHERE NOMBRE = 'Tarrazu'
    )
    BEGIN
        EXEC DBO.PR_INSERTARCANTON
            @NOMBRE = 'Tarrazu',
            @DETALLE_CANTON = 'Region montanosa famosa por la calidad de su cafe', -- noqa: LT05
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.CANTON
        WHERE NOMBRE = 'Aserri'
    )
    BEGIN
        EXEC DBO.PR_INSERTARCANTON
            @NOMBRE = 'Aserri',
            @DETALLE_CANTON = 'Canton con tradicion de piedra artesanal',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.CANTON
        WHERE NOMBRE = 'Mora'
    )
    BEGIN
        EXEC DBO.PR_INSERTARCANTON
            @NOMBRE = 'Mora',
            @DETALLE_CANTON = 'Sede de multiples eventos culturales rurales',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.CANTON
        WHERE NOMBRE = 'Goicoechea'
    )
    BEGIN
        EXEC DBO.PR_INSERTARCANTON
            @NOMBRE = 'Goicoechea',
            @DETALLE_CANTON = 'Concentracion de comercio e industrias',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.CANTON
        WHERE NOMBRE = 'Santa Ana'
    )
    BEGIN
        EXEC DBO.PR_INSERTARCANTON
            @NOMBRE = 'Santa Ana',
            @DETALLE_CANTON = 'Polo de atraccion de empresas transnacionales',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.CANTON
        WHERE NOMBRE = 'Alajuelita'
    )
    BEGIN
        EXEC DBO.PR_INSERTARCANTON
            @NOMBRE = 'Alajuelita',
            @DETALLE_CANTON = 'Fuerte tradicion religiosa y cultural',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;
GO
-- FIN
