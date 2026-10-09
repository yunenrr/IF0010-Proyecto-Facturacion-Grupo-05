USE FACTURACION_SA;
GO

-- INICIO
IF EXISTS (
    SELECT 1
    FROM SYS.OBJECTS
    WHERE NAME = 'pr_InsertarProducto'
        AND TYPE = 'P'
)
BEGIN
    DROP PROCEDURE DBO.PR_INSERTARPRODUCTO;
END;
GO

CREATE PROCEDURE DBO.PR_INSERTARPRODUCTO (
    @CODIGO VARCHAR(30),
    @DESCRIPCION VARCHAR(70),
    @PRECIO_UNITARIO DECIMAL(18, 2),
    @PORCENTAJE_IMPUESTO DECIMAL(5, 2),
    @ESTADO_ACTIVO BIT,
    @FECHA_CREACION DATE,
    @FECHA_VENCIMIENTO DATE,
    @EXISTENCIAS INT,
    @TIPO_PRODUCTO VARCHAR(10),
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

        -- Validar parametros obligatorios
        IF @CODIGO IS NULL
            OR @DESCRIPCION IS NULL
            OR @PRECIO_UNITARIO IS NULL
            OR @PORCENTAJE_IMPUESTO IS NULL
            OR @ESTADO_ACTIVO IS NULL
            OR @FECHA_CREACION IS NULL
            OR @EXISTENCIAS IS NULL
            OR @TIPO_PRODUCTO IS NULL
        BEGIN;
            THROW 50100, 'Parametros obligatorios no pueden ser nulos', 1;
        END;

        -- Validaciones de negocio (reemplazan los CHECK constraints de la tabla)
        IF @EXISTENCIAS < 0
        BEGIN;
            THROW 50101, 'Las existencias no pueden ser menores a cero', 1;
        END;

        IF @TIPO_PRODUCTO NOT IN ('DIGITAL', 'FISICO')
        BEGIN;
            THROW 50102, 'Tipo de producto debe ser DIGITAL o FISICO', 1;
        END;

        -- Validacion para evitar registros duplicados
        IF EXISTS (
            SELECT 1
            FROM DBO.PRODUCTO
            WHERE CODIGO = @CODIGO
        )
        BEGIN;
            THROW 50103, 'El producto ya se encuentra registrado', 1;
        END;

        INSERT INTO DBO.PRODUCTO (
            CODIGO,
            DESCRIPCION,
            PRECIO_UNITARIO,
            PORCENTAJE_IMPUESTO,
            ESTADO_ACTIVO,
            FECHA_CREACION,
            FECHA_VENCIMIENTO,
            EXISTENCIAS,
            TIPO_PRODUCTO
        )
        VALUES (
            @CODIGO,
            @DESCRIPCION,
            @PRECIO_UNITARIO,
            @PORCENTAJE_IMPUESTO,
            @ESTADO_ACTIVO,
            @FECHA_CREACION,
            @FECHA_VENCIMIENTO,
            @EXISTENCIAS,
            @TIPO_PRODUCTO
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH
END;
GO
-- FIN
