USE [FACTURACION_SA];
GO

-- INICIO
DECLARE @ERR INT;
DECLARE @MSG VARCHAR(100);

EXEC [dbo].[pr_InsertarCanton]
    @NOMBRE = 'San Jose',
    @DETALLE_CANTON = 'Canton Central de la provincia',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC [dbo].[pr_InsertarCanton]
    @NOMBRE = 'Escazu',
    @DETALLE_CANTON = 'Conocido por su desarrollo urbano y comercial',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC [dbo].[pr_InsertarCanton]
    @NOMBRE = 'Desamparados',
    @DETALLE_CANTON = 'Canton de alta densidad poblacional',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC [dbo].[pr_InsertarCanton]
    @NOMBRE = 'Puriscal',
    @DETALLE_CANTON = 'Territorio de topografia irregular y agricola',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC [dbo].[pr_InsertarCanton]
    @NOMBRE = 'Tarrazu',
    @DETALLE_CANTON = 'Region montañosa famosa por la calidad de su cafe',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC [dbo].[pr_InsertarCanton]
    @NOMBRE = 'Aserri',
    @DETALLE_CANTON = 'Canton con tradicion de piedra artesanal',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC [dbo].[pr_InsertarCanton]
    @NOMBRE = 'Mora',
    @DETALLE_CANTON = 'Sede de multiples eventos culturales rurales',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC [dbo].[pr_InsertarCanton]
    @NOMBRE = 'Goicoechea',
    @DETALLE_CANTON = 'Concentracion de comercio e industrias',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC [dbo].[pr_InsertarCanton]
    @NOMBRE = 'Santa Ana',
    @DETALLE_CANTON = 'Polo de atraccion de empresas transnacionales',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;

EXEC [dbo].[pr_InsertarCanton]
    @NOMBRE = 'Alajuelita',
    @DETALLE_CANTON = 'Fuerte tradicion religiosa y cultural',
    @CODIGO_ERROR = @ERR OUTPUT,
    @MENSAJE_ERROR = @MSG OUTPUT;
GO
-- FIN
