USE FACTURACION_SA;
GO

CREATE OR ALTER PROCEDURE dbo.sp_InsertarServicio
    @Codigo VARCHAR(30),
    @Descripcion VARCHAR(70),
    @PrecioUnitario DECIMAL(18,2),
    @PorcentajeImpuesto DECIMAL(5,2),
    @IdTipoServicio INT,
    @IdServicioGenerado INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar existencia del tipo de servicio
        IF NOT EXISTS (SELECT 1 FROM dbo.TIPO_SERVICIO WHERE ID = @IdTipoServicio)
        BEGIN
            RAISERROR('El tipo de servicio especificado no existe.', 16, 1);
            RETURN;
        END

        INSERT INTO dbo.SERVICIO (
            CODIGO,
            DESCRIPCION,
            PRECIO_UNITARIO,
            PORCENTAJE_IMPUESTO,
            ESTADO_ACTIVO,
            FECHA_CREACION,
            ID_TIPO_SERVICIO
        )
        VALUES (
            TRIM(@Codigo),
            TRIM(@Descripcion),
            @PrecioUnitario,
            ISNULL(@PorcentajeImpuesto, 13.00),
            1,
            GETDATE(),
            @IdTipoServicio
        );

        SET @IdServicioGenerado = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

