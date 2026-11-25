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
    @PRIMER_APELLIDO VARCHAR(70),
    @SEGUNDO_APELLIDO VARCHAR(70),
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

    SET @CODIGO_ERROR = 0;
    SET @MENSAJE_ERROR = 'Exitoso';

    DECLARE @TRAN_COUNT INT = @@TRANCOUNT;

    BEGIN TRY
        IF @TRAN_COUNT = 0
            BEGIN TRANSACTION;
        ELSE
            SAVE TRANSACTION SP_INSERTARCLIENTE;

        -- Validaciones de parametros nulos
        IF
            @CEDULA IS NULL
            OR @TELEFONO IS NULL
            OR @NOMBRE IS NULL
            OR @PRIMER_APELLIDO IS NULL
            OR @SEGUNDO_APELLIDO IS NULL
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
            PRIMER_APELLIDO,
            SEGUNDO_APELLIDO,
            CORREO_ELECTRONICO,
            FECHA_ULTIMA_ACTUALIZACION,
            FECHA_CREACION,
            ID_DIRECCION
        )
        VALUES (
            @CEDULA,
            @TELEFONO,
            @NOMBRE,
            @PRIMER_APELLIDO,
            @SEGUNDO_APELLIDO,
            @CORREO_ELECTRONICO,
            ISNULL(@FECHA_ULTIMA_ACTUALIZACION, CAST(GETDATE() AS DATE)),
            @FECHA_CREACION,
            @ID_DIRECCION
        );

        IF @TRAN_COUNT = 0
            COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF @TRAN_COUNT > 0
            ROLLBACK TRANSACTION SP_INSERTARCLIENTE;
        ELSE IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SET @CODIGO_ERROR = ERROR_NUMBER();
        SET @MENSAJE_ERROR = ERROR_MESSAGE();
    END CATCH;
END;
GO
-- FIN
