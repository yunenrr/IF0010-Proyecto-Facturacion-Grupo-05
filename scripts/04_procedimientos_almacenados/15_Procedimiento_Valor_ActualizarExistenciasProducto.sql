USE FACTURACION_SA;

GO --INICIO

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'pr_ActualizarExistenciasProducto' AND type = 'P')
BEGIN
    DROP PROCEDURE dbo.pr_ActualizarExistenciasProducto;
END

GO

CREATE PROCEDURE dbo.pr_ActualizarExistenciasProducto (
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

        -- Validar que los parámetros no sean nulos
        IF @ID_PRODUCTO IS NULL
            THROW 5010, 'El id de producto no puede ser nulo', 1;

        IF @CANTIDAD_AJUSTE IS NULL
            THROW 5010, 'La cantidad de ajuste no puede ser nula', 1;

        -- Validar que el producto exista en el catálogo
        IF NOT EXISTS (SELECT 1 FROM dbo.PRODUCTO AS P WHERE @ID_PRODUCTO = P.ID)
            THROW 5004, 'El producto no se encuentra registrado', 1;

        -- Extraer el stock actual para aplicar la regla de negocio
        DECLARE @EXISTENCIAS_ACTUALES INT;
        SELECT @EXISTENCIAS_ACTUALES = EXISTENCIAS FROM dbo.PRODUCTO WHERE ID = @ID_PRODUCTO;

        -- Validar que el ajuste no deje el inventario en negativo
        IF (@EXISTENCIAS_ACTUALES + @CANTIDAD_AJUSTE) < 0
            THROW 5011, 'Operación inválida: Las existencias resultantes no pueden ser menores a cero', 1;

        -- Actualizar el inventario sumando o restando 
        UPDATE dbo.PRODUCTO 
        SET EXISTENCIAS = EXISTENCIAS + @CANTIDAD_AJUSTE
        WHERE ID = @ID_PRODUCTO;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        -- mensajes de error
        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();

    END CATCH
END

GO --FIN
