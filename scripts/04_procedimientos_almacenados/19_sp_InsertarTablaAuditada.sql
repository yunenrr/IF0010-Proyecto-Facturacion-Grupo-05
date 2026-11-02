USE FACTURACION_SA;
GO--Inicio

CREATE OR ALTER PROCEDURE dbo.sp_InsertarTablaAuditada
    @NombreTabla VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SET @NombreTabla = UPPER(TRIM(@NombreTabla));

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.TABLA_AUDITADA WHERE NOMBRE_TABLA = @NombreTabla)
        BEGIN
            INSERT INTO dbo.TABLA_AUDITADA (NOMBRE_TABLA)
            VALUES (@NombreTabla);
        END
        ELSE
        BEGIN
            RAISERROR('La tabla %s ya existe en el catálogo de auditoría.', 16, 1, @NombreTabla);
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
