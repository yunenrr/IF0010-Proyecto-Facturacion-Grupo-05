USE FACTURACION_SA;
GO--Inicio

EXEC dbo.sp_InsertarTipoOperacion @NombreOperacion = 'INSERT';
EXEC dbo.sp_InsertarTipoOperacion @NombreOperacion = 'UPDATE';
EXEC dbo.sp_InsertarTipoOperacion @NombreOperacion = 'DELETE';
GO--fin
