USE FACTURACION_SA;
GO

-- INICIO
DECLARE @Paso INT = 1;
DECLARE @Cedula VARCHAR(30);
DECLARE @RazonSocial VARCHAR(50);
DECLARE @Nombre VARCHAR(50);
DECLARE @Correo VARCHAR(70);
DECLARE @Telefono VARCHAR(20);
DECLARE @Fecha DATE;
DECLARE @EstadoActivo BIT = 1;
DECLARE @IdDireccion INT;
DECLARE @Error INT;
DECLARE @Mensaje VARCHAR(100);

WHILE @Paso <= 100
BEGIN
    SET @Cedula = CONCAT('3-101-', RIGHT('000000' + CAST(@Paso AS VARCHAR(10)), 6));
    SET @RazonSocial = CONCAT('Empresa Sociedad Anonima ', @Paso);
    SET @Nombre = CONCAT('EmpresaSA', @Paso);
    SET @Correo = CONCAT('empresa', @Paso, '@gmail.com');
    SET @Telefono = CONCAT('8', RIGHT('0000000' + CAST(@Paso AS VARCHAR(10)), 7));
    SET @Fecha = DATEADD(DAY, -@Paso, CAST(GETDATE() AS DATE));

    -- Se usa el 50 porque los datos de direcciones cuentan hasta ese ID
    SET @IdDireccion = ((@Paso - 1) % 50) + 1;

    EXEC dbo.pr_InsertarEmpresa
        @CEDULA_JURIDICA = @Cedula,
        @RAZON_SOCIAL = @RazonSocial,
        @NOMBRE = @Nombre,
        @CORREO_ELECTRONICO = @Correo,
        @TELEFONO = @Telefono,
        @FECHA_CREACION = @Fecha,
        @PERMISO_OPERAR = @EstadoActivo,
        @ID_DIRECCION = @IdDireccion,
        @CODIGO_ERROR = @Error OUTPUT,
        @MENSAJE_ERROR = @Mensaje OUTPUT;

    SET @Paso += 1;
END;
GO
-- FIN