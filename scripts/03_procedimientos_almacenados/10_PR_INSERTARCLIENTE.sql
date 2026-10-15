USE FACTURACION_SA;
GO

-- INICIO
IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'PR_INSERTARCLIENTE'
            AND TYPE = 'P'
    )
    BEGIN
        DROP PROCEDURE DBO.PR_INSERTARCLIENTE;
    END;
GO

CREATE PROCEDURE DBO.PR_INSERTARCLIENTE (
    @CEDULA VARCHAR(30),
    @TELEFONO VARCHAR(20),
    @NOMBRE VARCHAR(70),
    @CORREO_ELECTRONICO VARCHAR(100),
    @FECHA_ULTIMA_ACTUALIZACION DATE,
    @FECHA_CREACION DATE,
    @ID_DIRECCION INT,
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

        -- Validaciones de parametros nulos
        IF
            @CEDULA IS NULL
            OR @TELEFONO IS NULL
            OR @NOMBRE IS NULL
            OR @CORREO_ELECTRONICO IS NULL
            OR @FECHA_CREACION IS NULL
            OR @ID_DIRECCION IS NULL
            BEGIN
                THROW 50100,
                'Los parametros obligatorios no pueden ser nulos',
                1;
            END;

        -- Validacion para evitar registros duplicados
        IF
            EXISTS (
                SELECT 1
                FROM DBO.CLIENTE
                WHERE CEDULA = @CEDULA
            )
            BEGIN
                THROW 50101, 'El cliente ya se encuentra registrado', 1;
            END;

        INSERT INTO DBO.CLIENTE (
            CEDULA,
            TELEFONO,
            NOMBRE,
            CORREO_ELECTRONICO,
            FECHA_ULTIMA_ACTUALIZACION,
            FECHA_CREACION,
            ID_DIRECCION
        )
        VALUES (
            @CEDULA,
            @TELEFONO,
            @NOMBRE,
            @CORREO_ELECTRONICO,
            ISNULL(@FECHA_ULTIMA_ACTUALIZACION, CAST(GETDATE() AS DATE)),
            @FECHA_CREACION,
            @ID_DIRECCION
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
