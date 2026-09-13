USE Facturación_SA;

GO--Inicio

CREATE Table Factura (
id INTEGER IDENTITY(1,1) NOT NULL,
numero_consecutivo INTEGER NOT NULL,
fecha_creacion DATE NOT NULL,
fecha_modificacion DATE NOT NULL,
fecha_emision DATE NOT NULL,
subtotal DECIMAL (18,2) NOT NULL,
total_descuento DECIMAL (10,2) CHECK (total_descuento >= 0) NOT NULL,
total_Impuesto DECIMAL (18,2) CHECK (total_impuesto >= 0 ) NOT NULL,
monto_total DECIMAL (19,2) CHECK (monto_total >=0 ) NOT NULL,
observaciones_adicionales VARCHAR (100),
codigo_moneda VARCHAR(6) NOT NULL,
estado_factura VARCHAR(25) NOT NULL,
cedula_juridica VARCHAR(30) NOT NULL,
cedula_cliente VARCHAR(30) NOT NULL,
codigo_identificador_documento INTEGER NOT NULL,
CONSTRAINT PK_Id_Factura PRIMARY KEY (id),
CONSTRAINT FK_Codigo_Moneda FOREIGN KEY (codigo_moneda) REFERENCES Moneda (codigo),
CONSTRAINT FK_Estado_Factura FOREIGN KEY (estado_factura) REFERENCES Estado_Factura (estado_factura),
CONSTRAINT FK_Cedula_Empresa FOREIGN KEY (cedula_juridica) REFERENCES Empresa (cedula_juridica),
CONSTRAINT FK_Cedula_Cliente FOREIGN KEY (cedula_cliente) REFERENCES Cliente (cedula),
CONSTRAINT FK_Codigo_Documento FOREIGN KEY (codigo_identificador_documento) REFERENCES Documento (codigo_identificador)

);


GO--Fin