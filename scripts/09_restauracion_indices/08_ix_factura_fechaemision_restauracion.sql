USE FACTURACION_SA;
GO

-- INICIO
-- Permite realizar consultas de facturas
-- por rango de fecha de emision.
CREATE NONCLUSTERED INDEX IX_FACTURA_FECHAEMISION
    ON DBO.FACTURA (
        FECHA_EMISION
    );
GO
-- FIN
