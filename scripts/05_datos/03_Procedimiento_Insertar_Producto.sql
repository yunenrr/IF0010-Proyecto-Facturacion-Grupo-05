USE FACTURACION_SA;
GO

-- INICIO
DECLARE @Paso INT = 1;
DECLARE @Codigo VARCHAR(30);
DECLARE @Descripcion VARCHAR(70);
DECLARE @Precio DECIMAL(18, 2);
DECLARE @Impuesto DECIMAL(5, 2);
DECLARE @Existencias INT;
DECLARE @Tipo VARCHAR(10);
DECLARE @Fecha_vencimiento DATE;

-- Variables adicionales del SP
DECLARE @Fecha_creacion DATE = CAST(GETDATE() AS DATE);
DECLARE @Err INT;
DECLARE @Msg VARCHAR(100);

WHILE @Paso <= 1000
BEGIN
    -- Codigo todos finalizan en 0
    SET @Codigo = CONCAT('Prod-', @Paso, '0');

    -- Descripcion
    IF (@Paso % 5 = 0)
    BEGIN
        SET @Descripcion = CONCAT('Producto Lacteo ', @Paso);
        SET @Precio = 500 + (@Paso * 1.50);
        SET @Impuesto = 10.0;
        SET @Existencias = 5;
        SET @Tipo = 'FISICO';
        SET @Fecha_vencimiento = DATEADD(DAY, 30 + (@Paso % 150), GETDATE());
    END
    ELSE IF (@Paso % 5 = 1)
    BEGIN
        SET @Descripcion = CONCAT('Servicios telefonia movil ', @Paso);
        SET @Precio = 800 + (@Paso * 2.50);
        SET @Impuesto = 12.0;
        SET @Existencias = 3;
        SET @Tipo = 'DIGITAL';
        SET @Fecha_vencimiento = DATEADD(DAY, 30 + (@Paso % 250), GETDATE());
    END
    ELSE IF (@Paso % 5 = 2)
    BEGIN
        SET @Descripcion = CONCAT('Canasta Basica ', @Paso);
        SET @Precio = 650 + (@Paso * 2.00);
        SET @Impuesto = 4.0;
        SET @Existencias = 12;
        SET @Tipo = 'FISICO';
        SET @Fecha_vencimiento = DATEADD(DAY, 30 + (@Paso % 200), GETDATE());
    END
    ELSE IF (@Paso % 5 = 3)
    BEGIN
        SET @Descripcion = CONCAT('Pelicula ', @Paso);
        SET @Precio = 300 + (@Paso * 3.00);
        SET @Impuesto = 8.0;
        SET @Existencias = 7;
        SET @Tipo = 'DIGITAL';
        SET @Fecha_vencimiento = DATEADD(DAY, 30 + (@Paso % 300), GETDATE());
    END
    ELSE IF (@Paso % 5 = 4)
    BEGIN
        SET @Descripcion = CONCAT('Bebidas ', @Paso);
        SET @Precio = 100 + (@Paso * 5.00);
        SET @Impuesto = 2.0;
        SET @Existencias = 8;
        SET @Tipo = 'FISICO';
        SET @Fecha_vencimiento = DATEADD(DAY, 30 + (@Paso % 500), GETDATE());
    END;

    EXEC dbo.pr_InsertarProducto
        @CODIGO = @Codigo,
        @DESCRIPCION = @Descripcion,
        @PRECIO_UNITARIO = @Precio,
        @PORCENTAJE_IMPUESTO = @Impuesto,
        @ESTADO_ACTIVO = 1,
        @FECHA_CREACION = @Fecha_creacion,
        @FECHA_VENCIMIENTO = @Fecha_vencimiento,
        @EXISTENCIAS = @Existencias,
        @TIPO_PRODUCTO = @Tipo,
        @CODIGO_ERROR = @Err OUTPUT,
        @MENSAJE_ERROR = @Msg OUTPUT;

    SET @Paso += 1;
END;
GO
-- FIN