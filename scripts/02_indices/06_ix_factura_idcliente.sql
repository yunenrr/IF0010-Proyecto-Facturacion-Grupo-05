USE FACTURACION_SA;

GO -- INICIO

-- Permite consultar las facturas asociadas
-- a un cliente determinado.

CREATE NONCLUSTERED INDEX IX_FACTURA_IDCLIENTE
ON FACTURA (ID_CLIENTE);

GO -- FIN