USE FACTURACION_SA;
GO

-- INICIO
DECLARE @PASO INT = 1;
DECLARE @CEDULA VARCHAR(30);
DECLARE @RAZONSOCIAL VARCHAR(50);
DECLARE @NOMBRE VARCHAR(50);
DECLARE @CORREO VARCHAR(70);
DECLARE @TELEFONO VARCHAR(20);
DECLARE @FECHA DATE;
DECLARE @ESTADOACTIVO BIT;
DECLARE @IDDIRECCION INT;
DECLARE @ERROR INT;
DECLARE @MENSAJE VARCHAR(100);
DECLARE @DOMINIO VARCHAR(20);

WHILE @PASO <= 100
BEGIN
    SET @CEDULA = CONCAT(
        '3-101-',
        RIGHT('000000' + CAST(@PASO AS VARCHAR(10)), 6)
    );

    -- Validar existencia previa para evitar registros duplicados
    IF NOT EXISTS (
        SELECT 1
        FROM DBO.EMPRESA
        WHERE CEDULA_JURIDICA = @CEDULA
    )
    BEGIN
        SET @RAZONSOCIAL = CONCAT('Empresa Sociedad Anonima ', @PASO);
        SET @NOMBRE = CONCAT('EmpresaSA', @PASO);

        -- Aleatorizar dominios de correo
        SET @DOMINIO = CHOOSE(
            (ABS(CHECKSUM(NEWID())) % 4) + 1,
            'gmail.com',
            'hotmail.com',
            'outlook.com',
            'corporacion.cr'
        );
        SET @CORREO = CONCAT('empresa', @PASO, '@', @DOMINIO);

        -- Aleatorizar el primer digito del telefono (2, 4 o 8)
        SET @TELEFONO = CONCAT(
            CHOOSE((ABS(CHECKSUM(NEWID())) % 3) + 1, '8', '2', '4'),
            RIGHT('0000000' + CAST(@PASO AS VARCHAR(10)), 7)
        );

        SET @FECHA = DATEADD(DAY, -@PASO, CAST(GETDATE() AS DATE));

        -- Aleatorizar la direccion entre las 50 disponibles
        SET @IDDIRECCION = (ABS(CHECKSUM(NEWID())) % 50) + 1;

        -- Aleatorizar permiso de operar (aprox 90% con permiso)
        SET @ESTADOACTIVO = CASE
            WHEN (ABS(CHECKSUM(NEWID())) % 10) < 9 THEN 1
            ELSE 0
        END;

        EXEC DBO.PR_INSERTAREMPRESA
            @CEDULA_JURIDICA = @CEDULA,
            @RAZON_SOCIAL = @RAZONSOCIAL,
            @NOMBRE = @NOMBRE,
            @CORREO_ELECTRONICO = @CORREO,
            @TELEFONO = @TELEFONO,
            @FECHA_CREACION = @FECHA,
            @PERMISO_OPERAR = @ESTADOACTIVO,
            @ID_DIRECCION = @IDDIRECCION,
            @CODIGO_ERROR = @ERROR OUTPUT,
            @MENSAJE_ERROR = @MENSAJE OUTPUT;
    END;

    SET @PASO += 1;
END;
GO
-- FIN
