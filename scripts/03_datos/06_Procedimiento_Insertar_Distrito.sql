USE FACTURACION_SA;
GO

-- INICIO
DECLARE @Err INT;
DECLARE @Msg VARCHAR(100);

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'Carmen',
    @DETALLE_DISTRITO = 'Distrito historico y gubernamental',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'Merced',
    @DETALLE_DISTRITO = 'Distrito comercial del centro historico',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'Hospital',
    @DETALLE_DISTRITO = 'Alberga centros medicos importantes',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'Catedral',
    @DETALLE_DISTRITO = 'Centro neuralgico cultural del canton',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'Zapote',
    @DETALLE_DISTRITO = 'Conocido por sus festejos populares anuales',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'San Francisco',
    @DETALLE_DISTRITO = 'Area mixta residencial e industrial',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'Uruca',
    @DETALLE_DISTRITO = 'Principal corredor logistico e industrial',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'Mata Redonda',
    @DETALLE_DISTRITO = 'Alberga el parque metropolitano principal',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'Pavas',
    @DETALLE_DISTRITO = 'Zona residencial y sede de aeropuerto local',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'Hatillo',
    @DETALLE_DISTRITO = 'Corredor habitacional denso al sur',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'San Sebastian',
    @DETALLE_DISTRITO = 'Distrito con alta circulacion vehicular',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'San Antonio',
    @DETALLE_DISTRITO = 'Distrito tradicional del canton de Escazu',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'San Rafael',
    @DETALLE_DISTRITO = 'Zona de desarrollo comercial reciente',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'San Juan de Dios',
    @DETALLE_DISTRITO = 'Territorio de relieve escarpado y rural',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;

EXEC dbo.pr_InsertarDistrito
    @NOMBRE = 'Patarra',
    @DETALLE_DISTRITO = 'Zona de reservas forestales y calizas',
    @CODIGO_ERROR = @Err OUTPUT,
    @MENSAJE_ERROR = @Msg OUTPUT;
GO
-- FIN
