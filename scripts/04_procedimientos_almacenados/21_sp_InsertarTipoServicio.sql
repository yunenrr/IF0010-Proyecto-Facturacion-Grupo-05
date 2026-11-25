USE FACTURACION_SA;
GO

CREATE OR ALTER PROCEDURE DBO.SP_INSERTARTIPOSERVICIO -- noqa: TQ01
    @Nombre VARCHAR(20),
    @Descripcion VARCHAR(100),
    @IdTipoServicioGenerado INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF @Nombre IS NULL OR TRIM(@Nombre) = ''
            BEGIN
                RAISERROR (
                    'El nombre del tipo de servicio no puede estar vacío.',
                    16,
                    1
                );
                RETURN;
            END

        INSERT INTO DBO.TIPO_SERVICIO (NOMBRE, DESCRIPCION)
        VALUES (TRIM(@Nombre), ISNULL(TRIM(@Descripcion), 'N/A'));
        SET @IdTipoServicioGenerado = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
