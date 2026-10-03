USE FACTURACION_SA;

GO -- INICIO

-- Permite realizar consultas de facturas
-- por rango de fecha de emisión.

CREATE NONCLUSTERED INDEX IX_FACTURA_FECHAEMISION
    ON FACTURA (FECHA_EMISION);

GO -- FIN
