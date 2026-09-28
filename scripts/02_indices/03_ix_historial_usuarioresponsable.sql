USE FACTURACION_SA;

GO -- INICIO

-- Permite consultar las operaciones realizadas
-- por un usuario responsable.

CREATE NONCLUSTERED INDEX IX_HISTORIAL_USUARIORESPONSABLE
    ON HISTORIAL (USUARIO_RESPONSABLE);

GO -- FIN
