USE Facturación_SA;

GO--Inicio

CREATE TABLE Moneda (

codigo VARCHAR(6) NOT NULL,
descripcion VARCHAR(100) NOT NULL,
simbolo VARCHAR(6) NOT NULL,
CONSTRAINT PK_Codigo_Moneda PRIMARY KEY(codigo)

);

GO--Fin
