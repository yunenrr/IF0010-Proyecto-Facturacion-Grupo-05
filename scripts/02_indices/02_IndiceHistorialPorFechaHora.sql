USE FACTURACIÓN_SA;

-- Permite recuperar los eventos por rango de tiempo

GO -- INICIO

CREATE NONCLUSTERED INDEX IX_HISTORIAL_FECHAHORA
    ON HISTORIAL (FECHA_HORA);

GO -- FIN
