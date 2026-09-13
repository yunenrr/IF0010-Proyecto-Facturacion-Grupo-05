USE Facturación_SA;

GO--Inicio

CREATE TABLE Cliente (

cedula VARCHAR(30) NOT NULL,
Telefono VARCHAR(20) UNIQUE NOT NULL,
nombre VARCHAR(70) NOT NULL,
correo_electronico VARCHAR (100) UNIQUE NOT NULL,
fecha_ultima_actualizacion DATE NOT NULL,
fecha_creacion DATE NOT NULL,
id_direccion INTEGER NOT NULL,
CONSTRAINT PK_Cedula_Cliente PRIMARY KEY (cedula),
CONSTRAINT FK_Direccion_Cliente FOREIGN KEY
(id_direccion) REFERENCES Direccion (id_direccion)

);

GO--Fin
