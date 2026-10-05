USE FACTURACION_SA;
GO

-- INICIO
DECLARE @ERR INT;
DECLARE @MSG VARCHAR(100);

EXEC dbo.pr_InsertarProvincia
    @NOMBRE = 'San Jose',
    @DETALLE_PROVINCIA = 'Provincia 1 - Region Central',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC dbo.pr_InsertarProvincia
    @NOMBRE = 'Alajuela',
    @DETALLE_PROVINCIA = 'Provincia 2 - Region Huetar Norte y Central',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC dbo.pr_InsertarProvincia
    @NOMBRE = 'Cartago',
    @DETALLE_PROVINCIA = 'Provincia 3 - Region Central',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC dbo.pr_InsertarProvincia
    @NOMBRE = 'Heredia',
    @DETALLE_PROVINCIA = 'Provincia 4 - Region Central',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC dbo.pr_InsertarProvincia
    @NOMBRE = 'Guanacaste',
    @DETALLE_PROVINCIA = 'Provincia 5 - Region Chorotega',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC dbo.pr_InsertarProvincia
    @NOMBRE = 'Puntarenas',
    @DETALLE_PROVINCIA = 'Provincia 6 - Region Pacifico Central y Sur',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC dbo.pr_InsertarProvincia
    @NOMBRE = 'Limon',
    @DETALLE_PROVINCIA = 'Provincia 7 - Region Huetar Caribe',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;
GO
-- FIN
