USE Facturación_SA;

GO -- Inicio

CREATE TABLE Direccion (

id_direccion INTEGER IDENTITY (1,1),
provincia VARCHAR (20) NOT NULL,
canton VARCHAR (40) NOT NULL,
distrito_barrio VARCHAR (50) NOT NULL,
detalle_direccion VARCHAR (100) NOT NULL,
CONSTRAINT PK_id_Dirección PRIMARY KEY(id_direccion)

);

GO-- FIN