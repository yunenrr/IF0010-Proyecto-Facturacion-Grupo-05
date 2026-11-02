USE FACTURACION_SA;
GO

DECLARE @IdMantenimiento INT, @IdConsultoria INT, @IdSoporte INT, @IdInstalacion INT;
DECLARE @IdGenerado INT;

SELECT @IdMantenimiento = ID FROM dbo.TIPO_SERVICIO WHERE NOMBRE = 'Mantenimiento';
SELECT @IdConsultoria   = ID FROM dbo.TIPO_SERVICIO WHERE NOMBRE = 'Consultoria';
SELECT @IdSoporte       = ID FROM dbo.TIPO_SERVICIO WHERE NOMBRE = 'Soporte Tecnico';
SELECT @IdInstalacion   = ID FROM dbo.TIPO_SERVICIO WHERE NOMBRE = 'Instalacion';

EXEC dbo.sp_InsertarServicio
    @Codigo = 'SERV-001',
    @Descripcion = 'Mantenimiento preventivo de servidores y centro de datos',
    @PrecioUnitario = 45000.00,
    @PorcentajeImpuesto = 13.00,
    @IdTipoServicio = @IdMantenimiento,
    @IdServicioGenerado = @IdGenerado OUTPUT;

EXEC dbo.sp_InsertarServicio
    @Codigo = 'SERV-002',
    @Descripcion = 'Consultoria en diseño y optimizacion de bases de datos',
    @PrecioUnitario = 75000.00,
    @PorcentajeImpuesto = 13.00,
    @IdTipoServicio = @IdConsultoria,
    @IdServicioGenerado = @IdGenerado OUTPUT;


EXEC dbo.sp_InsertarServicio
    @Codigo = 'SERV-003',
    @Descripcion = 'Soporte tecnico remoto 24/7 mensual',
    @PrecioUnitario = 30000.00,
    @PorcentajeImpuesto = 13.00,
    @IdTipoServicio = @IdSoporte,
    @IdServicioGenerado = @IdGenerado OUTPUT;

EXEC dbo.sp_InsertarServicio
    @Codigo = 'SERV-004',
    @Descripcion = 'Instalacion de switches, routers y segmentacion VLAN',
    @PrecioUnitario = 60000.00,
    @PorcentajeImpuesto = 13.00,
    @IdTipoServicio = @IdInstalacion,
    @IdServicioGenerado = @IdGenerado OUTPUT;
