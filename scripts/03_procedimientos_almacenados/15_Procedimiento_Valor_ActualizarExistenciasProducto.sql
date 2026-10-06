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

        -- Validar que los parametros no sean nulos
        IF @ID_PRODUCTO IS NULL
            BEGIN
                THROW 50010, 'El id de producto no puede ser nulo', 1;
            END;

        IF @CANTIDAD_AJUSTE IS NULL
            BEGIN
                THROW 50010, 'La cantidad de ajuste no puede ser nula', 1;
            END;

        -- Validar que el producto exista en el catalogo
        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.PRODUCTO AS P
                WHERE @ID_PRODUCTO = P.ID
            )
            BEGIN
                THROW 50004, 'El producto no se encuentra registrado', 1;
            END;

        -- Extraer el stock actual para aplicar la regla de negocio
        DECLARE @EXISTENCIAS_ACTUALES INT;

        SELECT @EXISTENCIAS_ACTUALES = EXISTENCIAS
        FROM DBO.PRODUCTO
        WHERE ID = @ID_PRODUCTO;

        -- Validar que el ajuste no deje el inventario en negativo
        IF (@EXISTENCIAS_ACTUALES + @CANTIDAD_AJUSTE) < 0
            BEGIN
                THROW 50011, 'Las existencias no pueden quedar en negativo', 1;
            END;

        -- Actualizar el inventario sumando o restando
        UPDATE DBO.PRODUCTO
        SET EXISTENCIAS = EXISTENCIAS + @CANTIDAD_AJUSTE
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
