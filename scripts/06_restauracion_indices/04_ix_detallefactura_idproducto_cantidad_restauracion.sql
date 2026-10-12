USE FACTURACION_SA;
GO

-- INICIO
-- Permite consultar las facturas en las que
-- se vendió un producto determinado y obtener
-- la cantidad vendida.
CREATE NONCLUSTERED INDEX IX_DETALLEFACTURA_IDPRODUCTO_CANTIDAD
    ON DBO.DETALLE_FACTURA (
        ID_PRODUCTO
    )
    INCLUDE (
        CANTIDAD
    );
GO
-- FIN
