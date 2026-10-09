USE FACTURACION_SA;
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
    -- Para datos aleatorios reales y no secuenciales
    SET @ID_PROVINCIA = (ABS(CHECKSUM(NEWID())) % 7) + 1;
    SET @ID_CANTON = (ABS(CHECKSUM(NEWID())) % 10) + 1;
    SET @ID_DISTRITO = (ABS(CHECKSUM(NEWID())) % 15) + 1;
    SET @DISTANCIA = CAST(((ABS(CHECKSUM(NEWID())) % 8) + 1) * 25 AS VARCHAR(10));

    SET @PUNTOREFERENCIA = CHOOSE(
        (ABS(CHECKSUM(NEWID())) % 7) + 1,
        'la Iglesia Catolica',
        'la Escuela Publica',
        'la Municipalidad',
        'la Plaza de Deportes',
        'el Banco Nacional',
        'la Cruz Roja',
        'la Pulperia del barrio'
    );

    SET @ORIENTACION = CHOOSE(
        (ABS(CHECKSUM(NEWID())) % 4) + 1,
        'Norte',
        'Sur',
        'Este',
        'Oeste'
    );

    SET @ESTRUCTURA = CHOOSE(
        (ABS(CHECKSUM(NEWID())) % 6) + 1,
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

    -- Evitar duplicados validando la existencia de la direccion
    IF NOT EXISTS (
        SELECT 1
        FROM DBO.DIRECCION
        WHERE DETALLE_DIRECCION = @DETALLE
    )
    BEGIN
        EXEC DBO.PR_INSERTARDIRECCION
            @ID_PROVINCIA = @ID_PROVINCIA,
            @ID_CANTON = @ID_CANTON,
            @ID_DISTRITO = @ID_DISTRITO,
            @DETALLE_DIRECCION = @DETALLE,
            @CODIGO_ERROR = @ERROR OUTPUT,
            @MENSAJE_ERROR = @MENSAJE OUTPUT;
    END;

    SET @PASO += 1;
END;
GO
-- FIN
