USE FACTURACION_SA;
GO

-- INICIO
DECLARE @ERR INT;
DECLARE @MSG VARCHAR(100);

-- Evitar duplicados validando la existencia de la provincia
IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.PROVINCIA
        WHERE NOMBRE = 'San Jose'
    )
    BEGIN
        EXEC DBO.PR_INSERTARPROVINCIA
            @NOMBRE = 'San Jose',
            @DETALLE_PROVINCIA = 'Provincia 1 - Region Central',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.PROVINCIA
        WHERE NOMBRE = 'Alajuela'
    )
    BEGIN
        EXEC DBO.PR_INSERTARPROVINCIA
            @NOMBRE = 'Alajuela',
            @DETALLE_PROVINCIA = 'Provincia 2 - Region Huetar Norte y Central',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.PROVINCIA
        WHERE NOMBRE = 'Cartago'
    )
    BEGIN
        EXEC DBO.PR_INSERTARPROVINCIA
            @NOMBRE = 'Cartago',
            @DETALLE_PROVINCIA = 'Provincia 3 - Region Central',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.PROVINCIA
        WHERE NOMBRE = 'Heredia'
    )
    BEGIN
        EXEC DBO.PR_INSERTARPROVINCIA
            @NOMBRE = 'Heredia',
            @DETALLE_PROVINCIA = 'Provincia 4 - Region Central',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.PROVINCIA
        WHERE NOMBRE = 'Guanacaste'
    )
    BEGIN
        EXEC DBO.PR_INSERTARPROVINCIA
            @NOMBRE = 'Guanacaste',
            @DETALLE_PROVINCIA = 'Provincia 5 - Region Chorotega',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.PROVINCIA
        WHERE NOMBRE = 'Puntarenas'
    )
    BEGIN
        EXEC DBO.PR_INSERTARPROVINCIA
            @NOMBRE = 'Puntarenas',
            @DETALLE_PROVINCIA = 'Provincia 6 - Region Pacifico Central y Sur',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;

IF
    NOT EXISTS (
        SELECT 1
        FROM DBO.PROVINCIA
        WHERE NOMBRE = 'Limon'
    )
    BEGIN
        EXEC DBO.PR_INSERTARPROVINCIA
            @NOMBRE = 'Limon',
            @DETALLE_PROVINCIA = 'Provincia 7 - Region Huetar Caribe',
            @CODIGO_ERROR = @ERR OUTPUT,
            @MENSAJE_ERROR = @MSG OUTPUT;
    END;
GO
-- FIN
