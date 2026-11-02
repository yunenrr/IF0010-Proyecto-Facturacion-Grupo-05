USE FACTURACION_SA;
GO

-- INICIO
-- Permite recuperar los eventos de una factura
-- ordenados cronologicamente.
CREATE NONCLUSTERED INDEX IX_HISTORIAL_IDFACTURA_FECHAHORA
    ON DBO.HISTORIAL (
        ID_FACTURA,
        FECHA_HORA
    );
GO
-- FIN
