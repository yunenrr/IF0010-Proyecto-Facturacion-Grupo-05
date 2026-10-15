USE FACTURACION_SA;
GO

-- INICIO
-- Permite recuperar los eventos del historial
-- por rango de fecha y hora.
CREATE NONCLUSTERED INDEX IX_HISTORIAL_FECHAHORA
    ON DBO.HISTORIAL (
        FECHA_HORA
    );
GO
-- FIN
