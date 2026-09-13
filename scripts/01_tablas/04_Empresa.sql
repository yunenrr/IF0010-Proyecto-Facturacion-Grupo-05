USE Facturación_SA;

GO--Inicio

CREATE TABLE Empresa (
cedula_juridica VARCHAR(30) NOT NULL,
razon_social VARCHAR (50) NOT NULL,
nombre VARCHAR (50) UNIQUE NOT NULL,
correo_electronico VARCHAR (70) UNIQUE NOT NULL,
telefono VARCHAR (20) UNIQUE NOT NULL,
fecha_creacion DATE NOT NULL,
permiso_operar BIT NOT NULL,
id_direccion INTEGER NOT NULL,
CONSTRAINT PK_cedula_Empresa PRIMARY KEY(cedula_juridica),
CONSTRAINT FK_direccion_Empresa FOREIGN KEY (id_direccion)
REFERENCES Direccion (id_direccion)

);

GO--Fin