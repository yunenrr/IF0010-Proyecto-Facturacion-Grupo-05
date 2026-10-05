USE [FACTURACION_SA];
GO

-- INICIO
DECLARE @PASO INT = 1;
DECLARE @ID_PROVINCIA INT;
DECLARE @ID_CANTON INT;
DECLARE @ID_DISTRITO INT;
DECLARE @DETALLE VARCHAR(100);
DECLARE @ERROR INT;
DECLARE @MENSAJE VARCHAR(100);
DECLARE @DISTANCIA VARCHAR(10);
DECLARE @PUNTOREFERENCIA VARCHAR(50);
DECLARE @ORIENTACION VARCHAR(20);
DECLARE @ESTRUCTURA VARCHAR(50);

WHILE @PASO <= 50
BEGIN
    -- Para datos aleatorios
    SET @ID_PROVINCIA = (@PASO % 7) + 1;
    SET @ID_CANTON = (@PASO % 10) + 1;
    SET @ID_DISTRITO = (@PASO % 15) + 1;
    SET @DISTANCIA = CAST(((@PASO % 8) + 1) * 25 AS VARCHAR(10));

    SET @PUNTOREFERENCIA = CHOOSE(
        (@PASO % 7) + 1,
        'la Iglesia Catolica',
        'la Escuela Publica',
        'la Municipalidad',
        'la Plaza de Deportes',
        'el Banco Nacional',
        'la Cruz Roja',
        'la Pulperia del barrio'
    );

    SET @ORIENTACION = CHOOSE(
        (@PASO % 4) + 1,
        'Norte',
        'Sur',
        'Este',
        'Oeste'
    );

    SET @ESTRUCTURA = CHOOSE(
        (@PASO % 6) + 1,
        'casa color blanca',
        'casa color azul',
        'edificio de dos plantas',
        'porton negro',
        'tapias verdes',
        'condominio esquinero'
    );

    SET @DETALLE = CONCAT(
        @DISTANCIA,
        ' metros al ',
        @ORIENTACION,
        ' de ',
        @PUNTOREFERENCIA,
        ', ',
        @ESTRUCTURA,
        ', Codigo interno: ',
        @PASO
    );

    EXEC [dbo].[pr_InsertarDireccion]
        @ID_PROVINCIA = @ID_PROVINCIA,
        @ID_CANTON = @ID_CANTON,
        @ID_DISTRITO = @ID_DISTRITO,
        @DETALLE_DIRECCION = @DETALLE,
        @CODIGO_ERROR = @ERROR OUTPUT,
        @MENSAJE_ERROR = @MENSAJE OUTPUT;

    SET @PASO += 1;
END;
GO
-- FIN
