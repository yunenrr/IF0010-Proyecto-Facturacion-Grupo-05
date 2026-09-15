USE FACTURACIÓN_SA;

-- Lista todas las facturas donde se vendio un producto determinado

GO -- INICIO

CREATE NONCLUSTERED INDEX IX_FACTURA_CEDULACLIENTE
    ON FACTURA (CEDULA_CLIENTE);

GO -- FIN
