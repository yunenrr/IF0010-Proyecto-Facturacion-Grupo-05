USE FACTURACION_SA;
GO

-- INICIO
-- Permite consultar productos segun
-- su fecha de vencimiento.
CREATE NONCLUSTERED INDEX IX_PRODUCTO_FECHAVENCIMIENTO
    ON DBO.PRODUCTO (
        FECHA_VENCIMIENTO
    );
GO
-- FIN
