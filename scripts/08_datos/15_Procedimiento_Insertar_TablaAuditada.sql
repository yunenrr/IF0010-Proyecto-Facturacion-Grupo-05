USE FACTURACION_SA;
GO--Inicio

EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'CANTON';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'CLIENTE';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'DETALLE_FACTURA';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'DIRECCION';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'DISTRITO';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'DOCUMENTO';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'EMPRESA';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'ESTADO_FACTURA';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'FACTURA';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'HISTORIAL';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'MONEDA';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'PRODUCTO';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'PROVINCIA';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'TIPO_PRODUCTO';
EXEC dbo.sp_InsertarTablaAuditada @NombreTabla = 'SERVICIO';

GO--fin
