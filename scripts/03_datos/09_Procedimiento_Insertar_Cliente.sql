USE FACTURACION_SA;
GO

-- INICIO
DECLARE @Paso INT = 1;
DECLARE @Cedula VARCHAR(30);
DECLARE @Telefono VARCHAR(20);
DECLARE @Nombre VARCHAR(70);
DECLARE @Correo VARCHAR(100);
DECLARE @Fecha DATE;
DECLARE @IdDireccion INT;
DECLARE @Error INT;
DECLARE @Mensaje VARCHAR(100);

BEGIN TRANSACTION;

WHILE @Paso <= 50000
BEGIN
    SET @Cedula = CONCAT('1', RIGHT('00000000' + CAST(@Paso AS VARCHAR(10)), 8));
    SET @Telefono = CONCAT('8', RIGHT('0000000' + CAST(@Paso AS VARCHAR(10)), 7));
    SET @Nombre = CONCAT('Cliente', @Paso);
    SET @Correo = CONCAT('cliente', @Paso, '@gmail.com');
    SET @Fecha = DATEADD(DAY, -(@Paso % 3000), CAST(GETDATE() AS DATE));
    SET @IdDireccion = ((@Paso - 1) % 50) + 1;

    EXEC dbo.pr_InsertarCliente
        @CEDULA = @Cedula,
        @TELEFONO = @Telefono,
        @NOMBRE = @Nombre,
        @CORREO_ELECTRONICO = @Correo,
        @FECHA_CREACION = @Fecha,
        @FECHA_ULTIMA_ACTUALIZACION = @Fecha,
        @ID_DIRECCION = @IdDireccion,
        @CODIGO_ERROR = @Error OUTPUT,
        @MENSAJE_ERROR = @Mensaje OUTPUT;

    SET @Paso += 1;
END;

COMMIT TRANSACTION;
GO
-- FIN