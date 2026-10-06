USE FACTURACION_SA;
GO

-- INICIO
IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_EMITIRFACTURACONDETALLE'
            AND TYPE = 'P'
    )
BEGIN
    DROP PROCEDURE DBO.PR_EMITIRFACTURACONDETALLE;
END;
GO

CREATE PROCEDURE DBO.PR_EMITIRFACTURACONDETALLE (
    -- Parametros de la Factura
    @NUMERO_CONSECUTIVO INT,
    @CODIGO_MONEDA CHAR(3),
    @ID_ESTADO_FACTURA INT,
    @ID_EMPRESA INT,
    @ID_CLIENTE INT,
    @CODIGO_DOCUMENTO INT,
    @OBSERVACIONES VARCHAR(100),
    @PORCENTAJE_DESCUENTO DECIMAL(10, 2),

    -- Parametros del Detalle
    @ID_PRODUCTO INT,
    @CANTIDAD INT,

    -- Parametro Auditoria
    @USUARIO_RESPONSABLE VARCHAR(100),

    -- Parametros de Salida
    @CODIGO_ERROR INT OUTPUT,
    @MENSAJE_ERROR VARCHAR(100) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @CODIGO_ERROR = 0;
    SET @MENSAJE_ERROR = 'Exitoso';

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validacion de nulos
        IF
            @NUMERO_CONSECUTIVO IS NULL
            OR @CODIGO_MONEDA IS NULL
            OR @ID_ESTADO_FACTURA IS NULL
            OR @ID_EMPRESA IS NULL
            OR @ID_CLIENTE IS NULL
            OR @CODIGO_DOCUMENTO IS NULL
            OR @ID_PRODUCTO IS NULL
            OR @CANTIDAD IS NULL
            OR @PORCENTAJE_DESCUENTO IS NULL
            OR @USUARIO_RESPONSABLE IS NULL
        BEGIN
            THROW 50010, 'Los parametros obligatorios no pueden ser nulos', 1;
        END

        IF
            @CANTIDAD <= 0
        BEGIN
            THROW 50011, 'La cantidad del producto debe ser mayor a cero', 1;
        END

        -- Validaciones de Integridad Referencial
        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.MONEDA
                WHERE CODIGO = @CODIGO_MONEDA
            )
        BEGIN
            THROW 50001, 'El codigo de la moneda no es valido', 1;
        END

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.ESTADO_FACTURA
                WHERE ID = @ID_ESTADO_FACTURA
            )
        BEGIN
            THROW 50002, 'El estado de factura no es valido', 1;
        END

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.CLIENTE
                WHERE ID = @ID_CLIENTE
            )
        BEGIN
            THROW 50004, 'El cliente no se encuentra registrado', 1;
        END

        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.PRODUCTO
                WHERE ID = @ID_PRODUCTO
            )
        BEGIN
            THROW 50007, 'El producto no se encuentra registrado', 1;
        END

        -- Extraccion de datos del producto
        DECLARE @PRECIO_UNITARIO DECIMAL(18, 2);
        DECLARE @PORCENTAJE_IMPUESTO DECIMAL(5, 2);
        DECLARE @EXISTENCIAS_ACTUALES INT;

        SELECT
            @PRECIO_UNITARIO = PRECIO_UNITARIO,
            @PORCENTAJE_IMPUESTO = PORCENTAJE_IMPUESTO,
            @EXISTENCIAS_ACTUALES = EXISTENCIAS
        FROM DBO.PRODUCTO
        WHERE ID = @ID_PRODUCTO;

        IF
            @CANTIDAD > @EXISTENCIAS_ACTUALES
        BEGIN
            THROW 50012, 'Existencias insuficientes para emitir factura', 1;
        END

        -- Calculos de importes separando asignaciones para respetar 80 chars
        DECLARE @MONTO_SUBTOTAL DECIMAL(18, 2);
        SET @MONTO_SUBTOTAL = @PRECIO_UNITARIO * @CANTIDAD;

        DECLARE @MONTO_DESCUENTO_CALCULADO DECIMAL(18, 2);
        SET @MONTO_DESCUENTO_CALCULADO = @MONTO_SUBTOTAL
            * (@PORCENTAJE_DESCUENTO / 100.0);

        DECLARE @BASE_IMPONIBLE DECIMAL(18, 2);
        SET @BASE_IMPONIBLE = @MONTO_SUBTOTAL
            - @MONTO_DESCUENTO_CALCULADO;

        DECLARE @MONTO_IMPUESTO_CALCULADO DECIMAL(18, 2);
        SET @MONTO_IMPUESTO_CALCULADO = @BASE_IMPONIBLE
            * (@PORCENTAJE_IMPUESTO / 100.0);

        DECLARE @MONTO_TOTAL_FACTURA DECIMAL(19, 2);
        SET @MONTO_TOTAL_FACTURA = @BASE_IMPONIBLE
            + @MONTO_IMPUESTO_CALCULADO;

        -- Insercion de Factura
        INSERT INTO DBO.FACTURA (
            NUMERO_CONSECUTIVO,
            FECHA_CREACION,
            FECHA_MODIFICACION,
            FECHA_EMISION,
            SUBTOTAL,
            TOTAL_DESCUENTO,
            TOTAL_IMPUESTO,
            MONTO_TOTAL,
            OBSERVACIONES_ADICIONALES,
            CODIGO_MONEDA,
            ID_ESTADO_FACTURA,
            ID_EMPRESA,
            ID_CLIENTE,
            CODIGO_IDENTIFICADOR_DOCUMENTO
        )
        VALUES (
            @NUMERO_CONSECUTIVO,
            CAST(GETDATE() AS DATE),
            CAST(GETDATE() AS DATE),
            CAST(GETDATE() AS DATE),
            @MONTO_SUBTOTAL,
            @PORCENTAJE_DESCUENTO,
            @MONTO_IMPUESTO_CALCULADO,
            @MONTO_TOTAL_FACTURA,
            ISNULL(@OBSERVACIONES, 'N/A'),
            @CODIGO_MONEDA,
            @ID_ESTADO_FACTURA,
            @ID_EMPRESA,
            @ID_CLIENTE,
            @CODIGO_DOCUMENTO
        );

        -- Capturar el ID de la factura que se acaba de crear
        DECLARE @ID_NUEVA_FACTURA INT = SCOPE_IDENTITY();

        -- Insercion de Detalle de Factura
        INSERT INTO DBO.DETALLE_FACTURA (
            ID_FACTURA,
            NUMERO_LINEA,
            ID_PRODUCTO,
            CANTIDAD,
            PRECIO_UNITARIO_VENTA,
            MONTO_DESCUENTO,
            MONTO_SUBTOTAL,
            MONTO_IMPUESTO,
            DESCRIPCION
        )
        VALUES (
            @ID_NUEVA_FACTURA,
            1,
            @ID_PRODUCTO,
            @CANTIDAD,
            @PRECIO_UNITARIO,
            @MONTO_DESCUENTO_CALCULADO,
            @MONTO_SUBTOTAL,
            @MONTO_IMPUESTO_CALCULADO,
            'Linea generada por sistema'
        );

        -- Actualizacion del inventario
        UPDATE DBO.PRODUCTO
        SET
            EXISTENCIAS = EXISTENCIAS - @CANTIDAD
        WHERE ID = @ID_PRODUCTO;

        -- Registro de Auditoria en la tabla Historial
        DECLARE @NOMBRE_ESTADO VARCHAR(25);

        SELECT @NOMBRE_ESTADO = ESTADO_FACTURA
        FROM DBO.ESTADO_FACTURA
        WHERE ID = @ID_ESTADO_FACTURA;

        INSERT INTO DBO.HISTORIAL (
            ID_FACTURA,
            ID_REGISTRO_AFECTADO,
            OPERACION_REALIZADA,
            ESTADO_PREVIO,
            ESTADO_NUEVO,
            FECHA_HORA,
            TABLA_AFECTADA,
            DESCRIPCION,
            USUARIO_RESPONSABLE
        )
        VALUES (
            @ID_NUEVA_FACTURA,
            @ID_NUEVA_FACTURA,
            'EMISION',
            NULL,
            @NOMBRE_ESTADO,
            GETDATE(),
            'FACTURA Y DETALLE',
            'Emision de factura con rebajo de inventario',
            @USUARIO_RESPONSABLE
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Setear mensaje de error
        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH
END;
GO
-- FIN
