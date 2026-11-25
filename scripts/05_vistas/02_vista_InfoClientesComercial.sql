USE FACTURACION_SA;
GO

IF
    EXISTS (
        SELECT 1
        FROM SYS.OBJECTS
        WHERE
            NAME = 'VW_INFO_CLIENTES_COMERCIAL'
            AND TYPE = 'V'
    )
    BEGIN
        DROP VIEW DBO.VW_INFO_CLIENTES_COMERCIAL;
    END;
GO
CREATE VIEW DBO.VW_INFO_CLIENTES_COMERCIAL
AS
SELECT
    CU.[Cedula],
    CU.[NombreORazonSocial],
    COUNT(F.ID) AS [CantidadFacturas],
    CASE
        WHEN
            SUM(
                CASE
                    WHEN F.FECHA_EMISION >= DATEADD(MONTH, -6, GETDATE())
                        THEN 1
                    ELSE 0
                END
            ) > 5
            THEN 'Sí'
        ELSE 'No'
    END AS [ClienteFrecuente]
FROM (
    -- Clientes Físicos
    SELECT
        ID AS ID_ORIGEN,
        'FISICO' AS TIPO_CLIENTE,
        CEDULA AS [Cedula],
        NOMBRE AS [NombreORazonSocial]
    FROM DBO.CLIENTE

    UNION ALL

    -- Clientes Jurídicos (Empresas)
    SELECT
        ID AS ID_ORIGEN,
        'JURIDICO' AS TIPO_CLIENTE,
        CEDULA_JURIDICA AS [Cedula],
        RAZON_SOCIAL AS [NombreORazonSocial]
    FROM DBO.EMPRESA
) AS CU
LEFT JOIN DBO.FACTURA AS F
    ON
        (CU.TIPO_CLIENTE = 'FISICO' AND CU.ID_ORIGEN = F.ID_CLIENTE)
        OR (CU.TIPO_CLIENTE = 'JURIDICO' AND CU.ID_ORIGEN = F.ID_EMPRESA)
GROUP BY
    CU.[Cedula],
    CU.[NombreORazonSocial];
GO
--Fin
