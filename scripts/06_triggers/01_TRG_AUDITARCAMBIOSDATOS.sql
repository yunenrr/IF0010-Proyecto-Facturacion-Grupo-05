USE FACTURACION_SA;
GO

IF EXISTS (
    SELECT 1
    FROM SYS.OBJECTS
    WHERE
        NAME = 'TRG_AUDITARCAMBIOSDATOS'
        AND TYPE = 'TR'
)
BEGIN
    DROP TRIGGER DBO.TRG_AUDITARCAMBIOSDATOS;
END;
GO

CREATE TRIGGER DBO.TRG_AUDITARCAMBIOSDATOS
ON DBO.CLIENTE
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    BEGIN TRY
        -- Actualizar la fecha de la última actualización
        UPDATE C
        SET C.FECHA_ULTIMA_ACTUALIZACION = GETDATE()
        FROM DBO.CLIENTE AS C
        INNER JOIN INSERTED AS I
            ON C.ID = I.ID;

        -- Registrar el cambio en la tabla de historial
        DECLARE @IDREGISTRO INT;
        DECLARE @DESCRIPCION VARCHAR(250);

        DECLARE CURCLIENTE CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            I.ID,
            LEFT(
                'Ced: ' + ISNULL(D.CEDULA, '') + ' -> ' + ISNULL(I.CEDULA, '') +
                ' | Nom: ' + ISNULL(D.NOMBRE, '') + ' -> ' + ISNULL(I.NOMBRE, '') +
                ' | Ap1: ' + ISNULL(D.PRIMER_APELLIDO, '') + ' -> ' + ISNULL(I.PRIMER_APELLIDO, '') +
                ' | Ap2: ' + ISNULL(D.SEGUNDO_APELLIDO, '') + ' -> ' + ISNULL(I.SEGUNDO_APELLIDO, '') +
                ' | Tel: ' + ISNULL(D.TELEFONO, '') + ' -> ' + ISNULL(I.TELEFONO, '') +
                ' | Correo: ' + ISNULL(D.CORREO_ELECTRONICO, '') + ' -> ' + ISNULL(I.CORREO_ELECTRONICO, ''),
                250
            )
        FROM DELETED AS D
        INNER JOIN INSERTED AS I
            ON D.ID = I.ID;

        OPEN CURCLIENTE;
        FETCH NEXT FROM CURCLIENTE INTO @IDREGISTRO, @DESCRIPCION;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC DBO.SP_INSERTARHISTORIALDATOS
                @NOMBRETABLA = 'CLIENTE',
                @NOMBREOPERACION = 'UPDATE',
                @IDREGISTRO = @IDREGISTRO,
                @DESCRIPCION = @DESCRIPCION;

            FETCH NEXT FROM CURCLIENTE INTO @IDREGISTRO, @DESCRIPCION;
        END;

        CLOSE CURCLIENTE;
        DEALLOCATE CURCLIENTE;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ERRORMSG1 VARCHAR(250) = ERROR_MESSAGE();
        RAISERROR('Error en TRG_AUDITARCAMBIOSDATOS: %s', 16, 1, @ERRORMSG1);
    END CATCH;
END;
GO
