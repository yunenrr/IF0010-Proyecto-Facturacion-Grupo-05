USE FACTURACION_SA;
GO

-- INICIO
IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'pr_InsertarTipoProducto'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_INSERTARTIPOPRODUCTO;
    END;
GO

CREATE PROCEDURE DBO.PR_INSERTARTIPOPRODUCTO (
    @NOMBRE VARCHAR(20),
    @DESCRIPCION VARCHAR(100),
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

        -- Validar parametros nulos
        IF
            @NOMBRE IS NULL
            OR @DESCRIPCION IS NULL
            BEGIN
                THROW 50100,
                'Los parametros obligatorios no pueden ser nulos',
                1;
            END;

        -- Validacion para evitar registros duplicados
        IF
            EXISTS (
                SELECT 1
                FROM DBO.TIPO_PRODUCTO
                WHERE
                    NOMBRE = @NOMBRE
            )
            BEGIN
                THROW 50101,
                'El tipo de producto ya se encuentra registrado',
                1;
            END;

        INSERT INTO DBO.TIPO_PRODUCTO (
            NOMBRE,
            DESCRIPCION
        )
        VALUES (
            @NOMBRE,
            @DESCRIPCION
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
