USE FACTURACION_SA;
GO

-- INICIO
DECLARE @PASO INT = 1;
DECLARE @CEDULA VARCHAR(30);
DECLARE @TELEFONO VARCHAR(20);
DECLARE @NOMBRE VARCHAR(70);
DECLARE @CORREO VARCHAR(100);
DECLARE @FECHA DATE;
DECLARE @IDDIRECCION INT;
DECLARE @ERROR INT;
DECLARE @MENSAJE VARCHAR(100);
DECLARE @DOMINIO VARCHAR(20);
DECLARE @PREFIJO VARCHAR(1);

BEGIN TRANSACTION;

WHILE @PASO <= 50000
BEGIN
    SET @CEDULA = CONCAT(
        '1',
        RIGHT('00000000' + CAST(@PASO AS VARCHAR(10)), 8)
    );

    -- Validar existencia previa para evitar registros duplicados
    IF NOT EXISTS (
        SELECT 1
        FROM DBO.CLIENTE
        WHERE CEDULA = @CEDULA
    )
    BEGIN
        -- Aleatorizar el primer digito del telefono
        SET @PREFIJO = CHOOSE((ABS(CHECKSUM(NEWID())) % 3) + 1, '8', '7', '6');
        SET @TELEFONO = CONCAT(
            @PREFIJO,
            RIGHT('0000000' + CAST(@PASO AS VARCHAR(10)), 7)
        );

        SET @NOMBRE = CONCAT('Cliente', @PASO);

        -- Aleatorizar dominios de correo
        SET @DOMINIO = CHOOSE(
            (ABS(CHECKSUM(NEWID())) % 4) + 1,
            'gmail.com',
            'hotmail.com',
            'outlook.com',
            'yahoo.com'
        );
        SET @CORREO = CONCAT('cliente', @PASO, '@', @DOMINIO);

        -- Aleatorizar fecha de creacion
        SET @FECHA = DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 3000),
            CAST(GETDATE() AS DATE)
        );

        -- Aleatorizar la direccion
        SET @IDDIRECCION = (ABS(CHECKSUM(NEWID())) % 50) + 1;

        EXEC DBO.PR_INSERTARCLIENTE
            @CEDULA = @CEDULA,
            @TELEFONO = @TELEFONO,
            @NOMBRE = @NOMBRE,
            @CORREO_ELECTRONICO = @CORREO,
            @FECHA_CREACION = @FECHA,
            @FECHA_ULTIMA_ACTUALIZACION = @FECHA,
            @ID_DIRECCION = @IDDIRECCION,
            @CODIGO_ERROR = @ERROR OUTPUT,
            @MENSAJE_ERROR = @MENSAJE OUTPUT;
    END;

    SET @PASO += 1;
END;

COMMIT TRANSACTION;
GO
-- FIN

