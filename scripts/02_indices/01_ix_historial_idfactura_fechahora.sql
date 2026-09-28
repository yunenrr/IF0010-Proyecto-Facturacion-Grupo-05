USE FACTURACION_SA;

GO -- INICIO

-- Permite recuperar los eventos de una factura
-- ordenados cronológicamente.

CREATE NONCLUSTERED INDEX IX_HISTORIAL_IDFACTURA_FECHAHORA
    ON HISTORIAL (ID_FACTURA, FECHA_HORA);

GO -- FIN
