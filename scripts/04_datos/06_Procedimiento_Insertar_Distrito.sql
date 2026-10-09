USE FACTURACION_SA;
GO

-- INICIO
DECLARE @ERR INT;
DECLARE @MSG VARCHAR(100);

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'Carmen',
    @DETALLE_DISTRITO = 'Distrito historico y gubernamental',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'Merced',
    @DETALLE_DISTRITO = 'Distrito comercial del centro historico',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'Hospital',
    @DETALLE_DISTRITO = 'Alberga centros medicos importantes',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'Catedral',
    @DETALLE_DISTRITO = 'Centro neuralgico cultural del canton',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'Zapote',
    @DETALLE_DISTRITO = 'Conocido por sus festejos populares anuales',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'San Francisco',
    @DETALLE_DISTRITO = 'Area mixta residencial e industrial',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'Uruca',
    @DETALLE_DISTRITO = 'Principal corredor logistico e industrial',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'Mata Redonda',
    @DETALLE_DISTRITO = 'Alberga el parque metropolitano principal',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'Pavas',
    @DETALLE_DISTRITO = 'Zona residencial y sede de aeropuerto local',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'Hatillo',
    @DETALLE_DISTRITO = 'Corredor habitacional denso al sur',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'San Sebastian',
    @DETALLE_DISTRITO = 'Distrito con alta circulacion vehicular',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'San Antonio',
    @DETALLE_DISTRITO = 'Distrito tradicional del canton de Escazu',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'San Rafael',
    @DETALLE_DISTRITO = 'Zona de desarrollo comercial reciente',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'San Juan de Dios',
    @DETALLE_DISTRITO = 'Territorio de relieve escarpado y rural',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC DBO.PR_INSERTARDISTRITO
    @NOMBRE = 'Patarra',
    @DETALLE_DISTRITO = 'Zona de reservas forestales y calizas',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;
GO
-- FIN
