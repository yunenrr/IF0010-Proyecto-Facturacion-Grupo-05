-- Indice de muestra ya que el proyecto no permite archivos vacios
CREATE NONCLUSTERED INDEX IX_Muestra_Cliente_Cedula 
ON Cliente (cedula);
