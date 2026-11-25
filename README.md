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

## Notas importantes o consideraciones especiales

# Justificación Técnica: Modelo de Entidades de Forma Independiente EMPRESA y CLIENTE

Justificamos la decisión arquitectónica de mantener Empresa y Cliente como entidades separadas y no aplicar un esquema de especialización o herencia como una tabla base Cliente o Persona con clases hijas ClienteFisico y ClienteJuridico, basándonos en los siguientes fundamentos técnicos y de lógica de negocio:

* Roles de Dominio Mutuamente Excluyentes siendo uno Emisor y otro Receptor:
A nivel transaccional, el modelo no trata a ambas figuras simplemente como actores comerciales, en el ecosistema de facturación definido para la entidad empresa actúa estricta y exclusivamente como el emisor, mientras que cliente actua únicamente como el receptor o comprador, diseñar una única tabla base habría entrelazado estas responsabilidades operativas, requiriendo lógica adicional como restricciones CHECK para evitar que por error un cliente común actuara como emisor de un comprobante.   

* Integridad Referencial en el Motor de Base de Datos:
Al mantener las tablas separadas, la tabla FACTURA puede declarar dos llaves foráneas explícitas e independientes siendo estas ID_EMPRESA e ID_CLIENTE. Esto delega al motor de SQL Server la validación absoluta de que cada documento tenga un emisor válido y un receptor válido, garantizando la integridad de los datos sin depender de lógica en la capa de aplicación o en triggers.   

* Semántica de Atributos:
Aunque ambas entidades comparten campos genéricos como cédula, correo, teléfono y fecha de creación, la especialización de sus atributos cambia significativamente en función de su rol:

EMPRESA requiere controles de cumplimiento operativo, como se ve en el atributo PERMISO_OPERAR, el cual no aplica para un comprador.

CLIENTE almacena el desglose de identidad física con atributos como PRIMER_APELLIDO, SEGUNDO_APELLIDO y metadatos de mantenimiento transaccional como FECHA_ULTIMA_ACTUALIZACION, los cuales no tienen sentido para la razón social emisora.
