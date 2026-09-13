USE Facturación_SA;

GO--Inicio

CREATE TABLE Estado_Factura(
estado_factura VARCHAR (25) NOT NULL,
descripcion VARCHAR (70) NOT NULL,
CONSTRAINT PK_Descripcion_Estado_Factura 
PRIMARY KEY (estado_factura)
);
GO--Fin