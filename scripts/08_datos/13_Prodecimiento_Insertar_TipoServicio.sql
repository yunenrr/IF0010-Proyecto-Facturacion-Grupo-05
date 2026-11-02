USE FACTURACION_SA;
GO

DECLARE @IdCat1 INT, @IdCat2 INT, @IdCat3 INT, @IdCat4 INT;

EXEC dbo.sp_InsertarTipoServicio 
    @Nombre = 'Mantenimiento', 
    @Descripcion = 'Servicios de mantenimiento preventivo y correctivo', 
    @IdTipoServicioGenerado = @IdCat1 OUTPUT;

EXEC dbo.sp_InsertarTipoServicio 
    @Nombre = 'Consultoria', 
    @Descripcion = 'Asesoría técnica, legal y especializada', 
    @IdTipoServicioGenerado = @IdCat2 OUTPUT;

EXEC dbo.sp_InsertarTipoServicio 
    @Nombre = 'Soporte Tecnico', 
    @Descripcion = 'Atención a incidencias y asistencia técnica', 
    @IdTipoServicioGenerado = @IdCat3 OUTPUT;

EXEC dbo.sp_InsertarTipoServicio 
    @Nombre = 'Instalacion', 
    @Descripcion = 'Servicios de instalación y configuración en sitio', 
    @IdTipoServicioGenerado = @IdCat4 OUTPUT;
