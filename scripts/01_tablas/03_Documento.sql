USE Facturación_SA;

GO-- Inicio

CREATE TABLE Documento (
codigo_identificador INTEGER IDENTITY(1,1) NOT NULL,
descripcion VARCHAR (70) NOT NULL,
CONSTRAINT PK_Codigo_Documento PRIMARY KEY (codigo_identificador)
);

GO-- FIN
