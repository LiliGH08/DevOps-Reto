# DevOps Reto - IaC Terraform  y Docker

Este proyecto construye una infraestructura como código en AWS usando Terraform. Crea un servcio de base de datos RDS, con su respectiva VPC, subredes, tablas de ruta, y politicas de seguridad para el acceso y crea un servicio de computo con una imagen Docker funcional que además se puede encontrar en DockerHub, con las siguientes especificaciones:

- Git
- VS Code (no CLI disponible, para Linux, no se realiza instalación)
- Maven
- PostgreSQL
- Java JRE
- .NET SDK
- Apache con página de "Hola Mundo"

## Tabla de Contenido

1. [Estructura del repositorio](#1-Estructura-del-repositorio)  
2. [Contenido de cada archivo](#2-Contenido-de-cada-archivo)  
3. [Ejecución de Terraform](#3-Ejecución-de-terraform)  
4. [Conexión SSH con la instancia EC2](#4-Conexión-ssh-con-la-instancia-ec2)  
   - [Validación del despliegue del Apache](#Validación-del-despliegue-del-apache)  
    - [Conexión entre Docker y la base de datos en AWS](#Conexión-entre-docker-y-la-base-de-datos-en-aws) 
5. [Justificación de recursos usados](#5-Justificación-de-recursos-usados)  
6. [Gestión del state file](#6-Gestión-del-state-file)  
7. [Gestión del archivo lock](#7-Gestión-del-archivo-lock)  
8. [Consideraciones](#8-Consideraciones)  

# 1. Estructura del repositorio
- docker  
  - Dockerfile  
  - verify.sh  
- terraform  
  - key.tf  
  - main.tf  
  - outputs.tf  
  - provider.tf  
  - terraform.tfvars  
  - variables.tf  
- .gitignore  
- README.md

# 2. Contenido de cada archivo
- docker  
  - `Dockerfile`:Contiene la configuración necesaria para construir la imagen Docker basada en Red Hat 9. Incluye la instalación del servidor Apache y herramientas como psql para conectarse a la base de datos.
  - `verify.sh`: Script auxiliar para validar que el contenedor se ha levantado correctamente y que el servidor Apache está respondiendo.
- terraform  
  - `key.tf`: Define la creación y configuración del par de llaves SSH necesarias para acceder a la instancia EC2. 
  - `main.tf`: Archivo principal donde se declaran todos los recursos de AWS, como la VPC, subredes, gateway, instancia EC2, grupo de seguridad y la base de datos RDS.
  - `outputs.tf`: Define las salidas del proyecto, como la IP pública de la EC2, el endpoint del RDS, el nombre de la llave para acceder al EC2 y la ruta en la queda almacenada la llave, para facilitar su uso después de aplicar Terraform apply.
  - `provider.tf`: Configura el proveedor de AWS y la región a usar.
  - `terraform.tfvars`: Contiene los valores concretos para las variables definidas, como región elegida de AWS, IPs permitidas, el tipo de instancia, Nombre de la llave para la instancia EC2 o el nombre del usuario de la base de datos.
  - `variables.tf`: Define todas las variables necesarias para parametrizar el proyecto.
- `.gitignore`: Archivos y carpetas que deben ser ignorados por Git, como el state file de Terraform o archivos de configuración local. 
- `README.md`: Este archivo. Explica el propósito del proyecto, su estructura, pasos de despliegue y otros detalles relevantes.

# 3. Ejecución de Terraform
Se utilizan los siguientes comandos en la ubicación directorio terraform para ejecutar el proyecto:
```bash
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

# 4. Conexión SSH con la instancia EC2
Después de aplicar Terraform, el archivo `terraform-key.pem` debe tener permisos seguros: 

```bash
## Comandos para PowerShell
icacls terraform-key.pem /inheritance:r
icacls terraform-key.pem /grant:r "$($env:USERNAME):(R)"

## En bash
chmod 400 terraform-key.pem
```

Se puede proceder a conectarse a la instancia EC2 usando la clave generada.

 (La podemos guardar en una variable local primero para facilitar su uso):
```bash
$EC2_IP = terraform output -raw ec2_public_ip
ssh -i terraform-key.pem ubuntu@$EC2_IP
```
### Validación del despliegue del Apache
Una vez dentro de la instancia EC2, se puede validar que el apache está activo con el comando:
```bash
curl http://localhost
```
O accediendo desde el navegador a:
```bash
http://<ec2_public_ip>
```
Reemplazando la Ip pública en que se generó en el output de terraform.
### Conexión entre Docker y la base de datos en AWS
Para validar la conexión entre el docker y la base de datos AWS se puede hacer con el comando:
```bash
psql -h <rds_endpoint> -U reto_user -d reto_db
```
Reemplazando el endpoint que se generó en el output de terraform. 
Si la conexión funciona debe pedir la clava para acceder a la base de datos, en este caso está definida como Password123! en la configuración. (Idealmente se debe asignar una variable guardada en un archivo seguro o en un vault)
# 5. Justificación de recursos usados
- **EC2:** Se optó por utilizar EC2 en lugar de ECS o EKS por ser una solución más directa y controlable para un entorno pequeño. EC2 permite desplegar contenedores con suficiente flexibilidad, sin la necesidad de administrar clústeres o configurar algún orquestador, lo cual simplifica la estructura del proyecto y los costos asociados en AWS, también se eligió una instancia apropiada dentro del Free Tier del primer año gratis de AWS, (en mi caso generó costos mínimos por estar fuera del primer año).
- **RDS PostgreSQL:** Se eligió RDS con PostgreSQL por ser una base de datos relacional gestionada, lo que hace que sea fácil de usar. Frente a otras opciones como DynamoDB (NoSQL) o Aurora (más costosa y compleja). Para entornos pequeños como este resulta una opción econnómica y sencilla. Además de fácil de conectar con el EC2 encontrandose dentro de la misma VPC.
# 6. Gestión del state file
El `terraform.tfstate` es el archivo donde Terraform guarda el estado actual de la infraestructura. Este archivo no debe modificarse manualmente ni compartirse sin control. Para este proyecto se almacena de forma local, para proyectos colaborativos, se recomienda almacenar el state file en un backend remoto como S3.
# 7. Gestión del archivo lock
El archivo `.terraform.lock.hcl` asegura que se usen las mismas versiones de proveedores (como AWS) en cada ejecución de Terraform. Esto evita inconsistencias cuando se trabaja en diferentes entornos o equipos.
# 8. Consideraciones

- Se requiere acceso a internet desde la instancia EC2 para descargar Docker y conectarse a RDS.

- La clave privada debe mantenerse segura y con los permisos adecuados.

Se recomienda destruir la infraestructura al terminar si es un entorno temporal, con:

```bash
terraform destroy
```