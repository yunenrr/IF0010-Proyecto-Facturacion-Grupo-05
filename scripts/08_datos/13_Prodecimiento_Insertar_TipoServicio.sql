USE FACTURACION_SA;
GO

DECLARE @IDCAT1 INT, @IDCAT2 INT, @IDCAT3 INT, @IDCAT4 INT;

EXEC DBO.SP_INSERTARTIPOSERVICIO
    @NOMBRE = 'Mantenimiento',
    @DESCRIPCION = 'Servicios de mantenimiento preventivo y correctivo',
    @IDTIPOSERVICIOGENERADO = @IDCAT1 OUTPUT;

EXEC DBO.SP_INSERTARTIPOSERVICIO
    @NOMBRE = 'Consultoria',
    @DESCRIPCION = 'Asesoría técnica, legal y especializada',
    @IDTIPOSERVICIOGENERADO = @IDCAT2 OUTPUT;

EXEC DBO.SP_INSERTARTIPOSERVICIO
    @NOMBRE = 'Soporte Tecnico',
    @DESCRIPCION = 'Atención a incidencias y asistencia técnica',
    @IDTIPOSERVICIOGENERADO = @IDCAT3 OUTPUT;

EXEC DBO.SP_INSERTARTIPOSERVICIO
    @NOMBRE = 'Instalacion',
    @DESCRIPCION = 'Servicios de instalación y configuración en sitio',
    @IDTIPOSERVICIOGENERADO = @IDCAT4 OUTPUT;
