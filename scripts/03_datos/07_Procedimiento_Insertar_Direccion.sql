USE FACTURACION_SA;
GO

-- INICIO
DECLARE @Paso INT = 1;
DECLARE @Id_Provincia INT;
DECLARE @Id_Canton INT;
DECLARE @Id_Distrito INT;
DECLARE @Detalle VARCHAR(100);
DECLARE @Error INT;
DECLARE @Mensaje VARCHAR(100);
DECLARE @Distancia VARCHAR(10);
DECLARE @PuntoReferencia VARCHAR(50);
DECLARE @Orientacion VARCHAR(20);
DECLARE @Estructura VARCHAR(50);

WHILE @Paso <= 50
BEGIN
    -- Para datos aleatorios
    SET @Id_Provincia = (@Paso % 7) + 1;
    SET @Id_Canton = (@Paso % 10) + 1;
    SET @Id_Distrito = (@Paso % 15) + 1;
    SET @Distancia = CAST(((@Paso % 8) + 1) * 25 AS VARCHAR(10));

    SET @PuntoReferencia = CHOOSE(
        (@Paso % 7) + 1,
        'la Iglesia Catolica',
        'la Escuela Publica',
        'la Municipalidad',
        'la Plaza de Deportes',
        'el Banco Nacional',
        'la Cruz Roja',
        'la Pulperia del barrio'
    );

    SET @Orientacion = CHOOSE(
        (@Paso % 4) + 1,
        'Norte',
        'Sur',
        'Este',
        'Oeste'
    );

    SET @Estructura = CHOOSE(
        (@Paso % 6) + 1,
        'casa color blanca',
        'casa color azul',
        'edificio de dos plantas',
        'porton negro',
        'tapias verdes',
        'condominio esquinero'
    );

    SET @Detalle = CONCAT(
        @Distancia,
        ' metros al ',
        @Orientacion,
        ' de ',
        @PuntoReferencia,
        ', ',
        @Estructura,
        ', Codigo interno: ',
        @Paso
    );

    EXEC dbo.pr_InsertarDireccion
        @ID_PROVINCIA = @Id_Provincia,
        @ID_CANTON = @Id_Canton,
        @ID_DISTRITO = @Id_Distrito,
        @DETALLE_DIRECCION = @Detalle,
        @CODIGO_ERROR = @Error OUTPUT,
        @MENSAJE_ERROR = @Mensaje OUTPUT;

    SET @Paso += 1;
END;
GO
-- FIN