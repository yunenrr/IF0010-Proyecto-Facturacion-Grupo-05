# IF0010-Proyecto-Facturacion-Grupo-05
# Sistema de facturación

## Descripción general
Este proyecto trata del diseño e implementación del módulo central de facturación comercial en una base de datos Microsoft SQL Server para la empresa "Soluciones Magníficas S.A.". Este sistema debe cumplir con requisitos técnicos, de negocio y de rendimiento.

## Integrantes del grupo
* Christofer Céspedes Solano - C4EO99
* Kendall Córdoba García - C4E456
* Emmanuel Picado Ovares - C4I420

## Requisitos
* SQL Server 2019 o superior
* SQL Server Management Studio (SSMS)
* Git (instalado localmente)
* GitHub (cuenta gratuita)
* Herramienta para diagrama ER (Miro)
* PowerPoint o Canva para presentación
* 7-Zip o WinRAR para comprimir el archivo final

## Instrucciones de ejecución
* **Orden de scripts:** Secuencial

## Catálogo de Objetos de Base de Datos

### Vistas (`VIEW`)

| Nombre | Descripción |
| :--- | :--- |
| `dbo.VW_INFO_CLIENTES_COMERCIAL` | Consolida clientes físicos y jurídicos con su total de facturas e indica si son clientes frecuentes (`Sí` cuando superan 5 facturas en los últimos 6 meses). |
| `dbo.VW_TOTALES_DIARIOS_FACTURADOS` | Resume por fecha de emisión, empresa y tipo de documento la cantidad de facturas y los acumulados de subtotal, descuentos, impuestos y monto total. |

### Funciones (`FUNCTION`)

| Nombre | Tipo | Descripción |
| :--- | :--- | :--- |
| `dbo.FN_CONSULTAR_CLIENTE_IDENTIFICACION` | Tabla en línea | Busca un cliente físico o empresa por cédula y enmascara teléfono y correo si el usuario no pertenece a `Administrativo` o `sysadmin`. |
| `dbo.FN_CONSULTAR_HISTORIAL` | Tabla en línea | Consulta la bitácora `HISTORIAL` restringiendo los resultados únicamente a los roles `Auditor`, `DBA` o `sysadmin`. |
| `dbo.FN_CALCULAR_MONTO_FINAL` | Escalar | Calcula el monto final de una factura (`SUBTOTAL - TOTAL_DESCUENTO + TOTAL_IMPUESTO`) a partir de su `ID`. |
| `dbo.FN_GENERAR_CLAVE_COMPROBANTE` | Escalar | Genera la clave del comprobante concatenando fecha/hora (`YYYYMMDDHHMMSS`) y el tipo de documento. |
| `dbo.FN_VALIDAR_ESTADO_BORRADOR` | Escalar | Retorna `1` si la factura (según su `IDENTIFICADOR_FACTURA`) está en estado `BORRADOR`, o `0` en caso contrario. |

### Procedimientos Almacenados (`STORED PROCEDURE`)

#### Consultas y Reportes

| Nombre | Descripción |
| :--- | :--- |
| `dbo.CONSULTA_TODAS_PROVINCIAS` | Lista todas las provincias ordenadas alfabéticamente por nombre. |
| `dbo.CONSULTA_CANTONES_POR_PROVINCIA` | Lista los cantones registrados ordenados por ID (acepta `@ID_PROVINCIA` opcional). |
| `dbo.CONSULTA_DISTRITOS_POR_CANTON` | Lista los distritos registrados ordenados por ID (acepta `@ID_CANTON` opcional). |
| `dbo.CONSULTA_TODOS_TIPOS_PRODUCTO` | Lista todos los tipos de producto ordenados por nombre. |
| `dbo.CONSULTA_CLIENTE_FISICO_NOMBRE_PRIMER_APELLIDO` | Busca clientes físicos filtrando por prefijo de nombre y primer apellido. |
| `dbo.CONSULTA_CLIENTE_FISICO_NOMBRE_SEGUNDO_APELLIDO` | Busca clientes físicos filtrando por prefijo de nombre y segundo apellido. |
| `dbo.CONSULTA_EMPRESA_POR_NOMBRE_COMERCIAL` | Busca empresas filtrando por prefijo de su nombre comercial. |
| `dbo.CONSULTA_EMPRESA_POR_RAZON_SOCIAL` | Busca empresas filtrando por prefijo de su razón social. |
| `dbo.CONSULTA_FACTURAS_CLIENTE_FISICO` | Devuelve las facturas y su estado asociadas a un cliente físico según su cédula. |
| `dbo.CONSULTA_FACTURAS_CLIENTE_JURIDICO` | Devuelve las facturas y su estado asociadas a una empresa según su cédula jurídica. |
| `dbo.CONSULTA_HISTORIAL_PRODUCTO_FECHAS` | Consulta las líneas facturadas de un producto (por código) dentro de un rango de fechas. |
| `dbo.CONSULTA_TOTALES_CLIENTE_ANIO_VIGENTE` | Suma descuentos, impuestos y monto facturado de un cliente físico o jurídico por año, o histórico completo si `@ANIO` es `NULL`. |

#### Facturación

| Nombre | Descripción |
| :--- | :--- |
| `dbo.PR_EMITIRFACTURA` | Emite una factura calculando totales e insertando automáticamente sus líneas de detalle de productos. |
| `dbo.PR_EMITIRFACTURACONDETALLE` | Emite transaccionalmente una factura con su detalle, valida integridad y stock, calcula montos, rebaja inventario en `PRODUCTO` y registra en `HISTORIAL`. |

#### Inserción de Entidades y Catálogos

| Nombre | Descripción |
| :--- | :--- |
| `dbo.PR_INSERTARPROVINCIA` | Inserta una provincia validando valores nulos y duplicados. |
| `dbo.PR_INSERTARCANTON` | Inserta un cantón validando valores nulos y duplicados. |
| `dbo.PR_INSERTARDISTRITO` | Inserta un distrito validando valores nulos y duplicados. |
| `dbo.PR_INSERTARDIRECCION` | Inserta una dirección completa validando valores nulos y duplicados. |
| `dbo.PR_INSERTARCLIENTE` | Registra un cliente físico validando campos obligatorios, cédula y correo únicos (con soporte de savepoint para transacciones anidadas). |
| `dbo.PR_INSERTAREMPRESA` | Registra una empresa emisora validando campos obligatorios y cédula jurídica única. |
| `dbo.PR_INSERTARMONEDA` | Registra una moneda en `MONEDA` evitando códigos duplicados. |
| `dbo.PR_INSERTARDOCUMENTO` | Registra un tipo de documento en `DOCUMENTO` evitando duplicados. |
| `dbo.PR_INSERTARESTADOFACTURA` | Registra un estado de factura en `ESTADO_FACTURA` evitando duplicados. |
| `dbo.PR_INSERTARTIPOPRODUCTO` | Registra una categoría en `TIPO_PRODUCTO` evitando nombres duplicados. |
| `dbo.PR_INSERTARPRODUCTO` | Registra un producto validando existencias no negativas, tipo de producto válido y código único. |
| `dbo.SP_INSERTARTIPOSERVICIO` | Registra un tipo de servicio en `TIPO_SERVICIO` y devuelve el ID generado (`OUTPUT`). |
| `dbo.SP_INSERTARSERVICIO` | Registra un servicio en `SERVICIO` validando el tipo de servicio y devuelve el ID generado (`OUTPUT`). |
| `dbo.PR_INSERTARHISTORIAL` | Inserta un registro en la bitácora `HISTORIAL` evitando entradas duplicadas exactas. |
| `dbo.SP_INSERTARTABLAAUDITADA` | Agrega una tabla al catálogo `TABLA_AUDITADA` evitando duplicados. |
| `dbo.SP_INSERTARTIPOOPERACION` | Agrega un tipo de operación al catálogo `TIPO_OPERACION` evitando duplicados. |
| `dbo.SP_INSERTARHISTORIALDATOS` | Registra un evento en `HISTORIAL_DATOS` validando la tabla y la operación contra sus catálogos de auditoría. |

#### Actualizaciones y Mantenimiento

| Nombre | Descripción |
| :--- | :--- |
| `dbo.PR_ACTUALIZARCORREOCLIENTE` | Actualiza el correo de un cliente validando dominios permitidos (`@ucr.ac.cr`, `@gmail.com`, `@hotmail.com`, `@outlook.com`) y unicidad. |
| `dbo.PR_ACTUALIZARDIRECCIONCLIENTE` | Cambia la dirección de un cliente validando que exista en catálogo y no sea la misma ya asignada. |
| `dbo.PR_ACTUALIZARTELEFONOCLIENTE` | Actualiza el teléfono de un cliente exigiendo exactamente 8 dígitos numéricos y evitando duplicados. |
| `dbo.PR_ACTUALIZAREXISTENCIASPRODUCTO` | Ajusta (suma o resta) existencias de un producto con bloqueo `UPDLOCK`, impidiendo que el inventario quede negativo. |

### Triggers (`TRIGGER`)

| Nombre | Tabla Asociada | Descripción |
| :--- | :--- | :--- |
| `dbo.TRG_AUDITARCAMBIOSFACTURA` | `FACTURA` | Actualiza `FECHA_MODIFICACION` en `UPDATE` y audita creación, cambios de estado y eliminación de facturas en `HISTORIAL`. |
| `dbo.TRG_AUDITARCAMBIOSDETALLEFACTURA` | `DETALLE_FACTURA` | Audita en `HISTORIAL` las inserciones (resumidas por factura), modificaciones y eliminaciones de líneas de detalle. |
| `dbo.TRG_AUDITARCAMBIOSDATOS` | `CLIENTE` | Actualiza `FECHA_ULTIMA_ACTUALIZACION` en `UPDATE` y registra altas, cambios y bajas de clientes en `HISTORIAL_DATOS`. |
| `dbo.TRG_AUDITARCAMBIOSDATOSEMPRESA` | `EMPRESA` | Registra inserciones, cambios y eliminaciones de empresas en `HISTORIAL_DATOS`. |
| `dbo.TRG_AUDITARCAMBIOSACTUALIZACIONUBICACION` | `DIRECCION` | Registra inserciones, cambios de ubicación y eliminaciones de direcciones en `HISTORIAL_DATOS`. |
| `dbo.TRG_AUDITARCAMBIOSPRODUCTO` | `PRODUCTO` | Registra altas, modificaciones (precio, impuesto, estado, vencimiento, existencias) y bajas de productos en `HISTORIAL_DATOS`. |
| `dbo.TRG_AUDITARCAMBIOSSERVICIO` | `SERVICIO` | Registra inserciones, cambios y eliminaciones de servicios en `HISTORIAL_DATOS`. |

## Notas importantes o consideraciones especiales

### Justificación Técnica: Modelo de Entidades de Forma Independiente EMPRESA y CLIENTE

Justificamos la decisión arquitectónica de mantener Empresa y Cliente como entidades separadas y no aplicar un esquema de especialización o herencia como una tabla base Cliente o Persona con clases hijas ClienteFisico y ClienteJuridico, basándonos en los siguientes fundamentos técnicos y de lógica de negocio:

* **Roles de Dominio Mutuamente Excluyentes siendo uno Emisor y otro Receptor:**
A nivel transaccional, el modelo no trata a ambas figuras simplemente como actores comerciales, en el ecosistema de facturación definido para la entidad empresa actúa estricta y exclusivamente como el emisor, mientras que cliente actua únicamente como el receptor o comprador, diseñar una única tabla base habría entrelazado estas responsabilidades operativas, requiriendo lógica adicional como restricciones CHECK para evitar que por error un cliente común actuara como emisor de un comprobante.

* **Integridad Referencial en el Motor de Base de Datos:**
Al mantener las tablas separadas, la tabla FACTURA puede declarar dos llaves foráneas explícitas e independientes siendo estas ID_EMPRESA e ID_CLIENTE. Esto delega al motor de SQL Server la validación absoluta de que cada documento tenga un emisor válido y un receptor válido, garantizando la integridad de los datos sin depender de lógica en la capa de aplicación o en triggers.

* **Semántica de Atributos:**
Aunque ambas entidades comparten campos genéricos como cédula, correo, teléfono y fecha de creación, la especialización de sus atributos cambia significativamente en función de su rol:
  * `EMPRESA` requiere controles de cumplimiento operativo, como se ve en el atributo `PERMISO_OPERAR`, el cual no aplica para un comprador.
  * `CLIENTE` almacena el desglose de identidad física con atributos como `PRIMER_APELLIDO`, `SEGUNDO_APELLIDO` y metadatos de mantenimiento transaccional como `FECHA_ULTIMA_ACTUALIZACION`, los cuales no tienen sentido para la razón social emisora.
