USE FACTURACION_SA;
GO

-- INICIO
IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_ACTUALIZAREXISTENCIASPRODUCTO'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_ACTUALIZAREXISTENCIASPRODUCTO;
    END;
GO

CREATE PROCEDURE DBO.PR_ACTUALIZAREXISTENCIASPRODUCTO (
    @ID_PRODUCTO INT,
    @CANTIDAD_AJUSTE INT,
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

        -- Validar que los parametros obligatorios no sean nulos
        IF
            @ID_PRODUCTO IS NULL
            OR @CANTIDAD_AJUSTE IS NULL
            BEGIN
                THROW 50010,
                'Los parametros obligatorios no pueden ser nulos',
                1;
            END;

        IF @CANTIDAD_AJUSTE = 0
            BEGIN
                THROW 50012, 'La cantidad de ajuste no puede ser cero', 1;
            END;

        -- Validar que el producto exista en el catalogo
        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.PRODUCTO
                WHERE ID = @ID_PRODUCTO
            )
            BEGIN
                THROW 50004, 'El producto no se encuentra registrado', 1;
            END;

        DECLARE @EXISTENCIAS_ACTUALES INT;

        -- Bloqueo de fila
        SELECT @EXISTENCIAS_ACTUALES = EXISTENCIAS
        FROM DBO.PRODUCTO WITH (UPDLOCK)
        WHERE ID = @ID_PRODUCTO;

        -- Validar que el ajuste no deje el inventario en negativo
        IF (@EXISTENCIAS_ACTUALES + @CANTIDAD_AJUSTE) < 0
            BEGIN
                THROW 50011, 'Las existencias no pueden quedar en negativo', 1;
            END;

        -- Actualizar el inventario sumando o restando
        UPDATE DBO.PRODUCTO
        SET
            EXISTENCIAS = EXISTENCIAS + @CANTIDAD_AJUSTE
        WHERE ID = @ID_PRODUCTO;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;

        -- Mensaje de error
        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH;
END;
GO
-- FIN
