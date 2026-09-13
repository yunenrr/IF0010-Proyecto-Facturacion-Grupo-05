USE FACTURACIÓN_SA;

-- Permite recuperar todos los eventos
-- Para auditoria ordenados cronologicamente.

GO -- INICIO

CREATE NONCLUSTERED INDEX IX_HISTORIAL_IDFACTURA_FECHAHORA
ON HISTORIAL (ID_FACTURA, FECHA_HORA);

GO -- FIN
