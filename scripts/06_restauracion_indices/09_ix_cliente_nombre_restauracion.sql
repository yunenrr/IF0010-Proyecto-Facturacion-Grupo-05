USE FACTURACION_SA;
GO

-- INICIO
-- Permite localizar clientes por nombre.
CREATE NONCLUSTERED INDEX IX_CLIENTE_NOMBRE
    ON DBO.CLIENTE (
        NOMBRE
    );
GO
-- FIN
