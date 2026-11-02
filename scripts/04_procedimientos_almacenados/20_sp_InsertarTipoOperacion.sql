USE FACTURACION_SA;
GO

CREATE OR ALTER PROCEDURE DBO.SP_INSERTARTIPOOPERACION -- noqa: TQ01
    @NombreOperacion VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SET @NombreOperacion = UPPER(TRIM(@NombreOperacion));

    BEGIN TRY
        IF
            NOT EXISTS (
                SELECT 1
                FROM DBO.TIPO_OPERACION
                WHERE NOMBRE_OPERACION = @NombreOperacion
            )
            BEGIN
                INSERT INTO DBO.TIPO_OPERACION (NOMBRE_OPERACION)
                VALUES (@NombreOperacion);
            END
        ELSE
            BEGIN
                RAISERROR (
                    'El tipo %s de operación ya existe en el catálogo.',
                    16,
                    1,
                    @NombreOperacion
                );
            END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
