USE FACTURACION_SA;
GO

-- INICIO
-- Permite localizar las facturas en las que
-- se vendio un producto determinado.
CREATE NONCLUSTERED INDEX IX_DETALLEFACTURA_IDPRODUCTO_IDFACTURA
    ON DBO.DETALLE_FACTURA (
        ID_PRODUCTO,
        ID_FACTURA
    );
GO
-- FIN
