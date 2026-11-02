USE FACTURACION_SA;
GO

-- INICIO
-- Permite realizar consultas de facturas
-- por estado y fecha de emision.
CREATE NONCLUSTERED INDEX IX_FACTURA_IDESTADOFACTURA_FECHAEMISION
    ON DBO.FACTURA (
        ID_ESTADO_FACTURA,
        FECHA_EMISION
    );
GO
-- FIN
