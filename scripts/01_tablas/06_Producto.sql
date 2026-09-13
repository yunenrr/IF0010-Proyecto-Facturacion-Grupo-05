USE Facturación_SA;

GO--Inicio

CREATE TABLE Producto (

id INTEGER IDENTITY (1,1) NOT NULL,
codigo VARCHAR(30) UNIQUE NOT NULL,
descripcion VARCHAR(70) NOT NULL,
precio_unitario DECIMAL(18,2) NOT NULL,
porcentaje_impuesto DECIMAL(5,2) NOT NULL,
estado_activo BIT NOT NULL,
fecha_creacion DATE NOT NULL,
fecha_vencimiento DATE,
CONSTRAINT PK_Id_Producto PRIMARY KEY (id)

);

GO--Fin