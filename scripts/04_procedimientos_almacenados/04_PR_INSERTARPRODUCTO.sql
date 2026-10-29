USE FACTURACION_SA;
GO

-- INICIO
IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_INSERTARPRODUCTO'
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
    @ID_TIPO_PRODUCTO INT,
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
        IF
            @CODIGO IS NULL
            OR @DESCRIPCION IS NULL
            OR @PRECIO_UNITARIO IS NULL
            OR @PORCENTAJE_IMPUESTO IS NULL
            OR @ESTADO_ACTIVO IS NULL
            OR @FECHA_CREACION IS NULL
            OR @FECHA_VENCIMIENTO IS NULL
            OR @EXISTENCIAS IS NULL
            OR @ID_TIPO_PRODUCTO IS NULL
            BEGIN
                THROW 50100, 'Parametros obligatorios no pueden ser nulos', 1;
            END;

        -- Validaciones de negocio
        IF
            @EXISTENCIAS < 0
            BEGIN
                THROW 50101, 'Las existencias no pueden ser menores a cero', 1;
            END;

        -- Validar que el tipo de producto exista
        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.TIPO_PRODUCTO
                WHERE
                    ID = @ID_TIPO_PRODUCTO
            )
            BEGIN
                THROW 50103, 'El tipo de producto indicado no existe', 1;
            END;
        -- Validar productos duplicados
        IF
            EXISTS (
                SELECT 1
                FROM DBO.PRODUCTO
                WHERE
                    CODIGO = @CODIGO
            )
            BEGIN
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
            ID_TIPO_PRODUCTO
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
            @ID_TIPO_PRODUCTO
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
    END CATCH;
END;
GO
-- FIN
