USE FACTURACION_SA;
GO

CREATE OR ALTER PROCEDURE DBO.SP_INSERTARHISTORIALDATOS -- noqa: TQ01
    @NombreTabla VARCHAR(50),
    @NombreOperacion VARCHAR(20),
    @IdRegistro INT,
    @Descripcion VARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdTabla INT;
    DECLARE @IdOperacion INT;
    SET @NombreTabla = UPPER(TRIM(@NombreTabla));
    SET @NombreOperacion = UPPER(TRIM(@NombreOperacion));

    -- Obtener las llaves
    SELECT @IdTabla = ID
    FROM DBO.TABLA_AUDITADA
    WHERE NOMBRE_TABLA = @NombreTabla;

    SELECT @IdOperacion = ID
    FROM DBO.TIPO_OPERACION
    WHERE NOMBRE_OPERACION = @NombreOperacion;

    -- Validar existencia en los catálogos
    IF @IdTabla IS NULL
        BEGIN
            RAISERROR (
                'Error: La tabla %s no existe en el catálogo',
                16,
                1,
                @NombreTabla
            );
            RETURN;
        END

    IF @IdOperacion IS NULL
        BEGIN
            RAISERROR (
                'Error: La operación %s no existe en el catálogo',
                16,
                1,
                @NombreOperacion
            );
            RETURN;
        END

    INSERT INTO DBO.HISTORIAL_DATOS (
        ID_TABLA,
        ID_OPERACION,
        ID_REGISTRO,
        FECHA_HORA,
        DESCRIPCION,
        USUARIO_RESPONSABLE
    )
    VALUES (
        @IdTabla,
        @IdOperacion,
        @IdRegistro,
        SYSDATETIME(),
        @Descripcion,
        SUSER_SNAME()
    );
END;
GO
