USE FACTURACION_SA;
GO

SET NOCOUNT ON;

DECLARE @PASO INT = 1;
DECLARE @CEDULA VARCHAR(30);
DECLARE @TELEFONO VARCHAR(20);
DECLARE @NOMBRE VARCHAR(70);
DECLARE @PRIMER_APELLIDO VARCHAR(70);
DECLARE @SEGUNDO_APELLIDO VARCHAR(70);
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

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.CLIENTE
                WHERE CEDULA = @CEDULA
            )
            BEGIN
                SET @PREFIJO = CHOOSE(
                    (ABS(CHECKSUM(NEWID())) % 3) + 1,
                    '8',
                    '7',
                    '6'
                );

                SET @TELEFONO = CONCAT(
                    @PREFIJO,
                    RIGHT('0000000' + CAST(@PASO AS VARCHAR(10)), 7)
                );

                SET @NOMBRE = CONCAT('Cliente', @PASO);
                SET @PRIMER_APELLIDO = CONCAT('ApellidoUno', @PASO);
                SET @SEGUNDO_APELLIDO = CONCAT('ApellidoDos', @PASO);

                SET @DOMINIO = CHOOSE(
                    (ABS(CHECKSUM(NEWID())) % 4) + 1,
                    'gmail.com',
                    'hotmail.com',
                    'outlook.com',
                    'yahoo.com'
                );

                SET @CORREO = CONCAT(
                    'cliente',
                    @PASO,
                    '@',
                    @DOMINIO
                );

                SET @FECHA = DATEADD(
                    DAY,
                    -(ABS(CHECKSUM(NEWID())) % 3000),
                    CAST(GETDATE() AS DATE)
                );

                SET @IDDIRECCION = (ABS(CHECKSUM(NEWID())) % 50) + 1;

                EXEC DBO.PR_INSERTARCLIENTE
                    @CEDULA = @CEDULA,
                    @TELEFONO = @TELEFONO,
                    @NOMBRE = @NOMBRE,
                    @PRIMER_APELLIDO = @PRIMER_APELLIDO,
                    @SEGUNDO_APELLIDO = @SEGUNDO_APELLIDO,
                    @CORREO_ELECTRONICO = @CORREO,
                    @FECHA_CREACION = @FECHA,
                    @FECHA_ULTIMA_ACTUALIZACION = @FECHA,
                    @ID_DIRECCION = @IDDIRECCION,
                    @CODIGO_ERROR = @ERROR OUTPUT,
                    @MENSAJE_ERROR = @MENSAJE OUTPUT;
            END;

        IF @PASO % 1000 = 0
            BEGIN
                COMMIT TRANSACTION;
                BEGIN TRANSACTION;
            END;

        SET @PASO += 1;
    END;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;
GO
