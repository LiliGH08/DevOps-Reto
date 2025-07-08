# DevOps Reto - IaC Terraform  y Docker

Este proyecto construye una infraestructura como código en AWS usando Terraform. Crea un servcio de base de datos RDS, con su respectiva VPC, subredes, tablas de ruta, y politicas de seguridad para el acceso y crea un servicio de computo con una imagen Docker funcional que además se puede encontrar en DockerHub, con las siguientes especificaciones:

- Git
- VS Code (no CLI disponible, para Linux, no se realiza instalación)
- Maven
- PostgreSQL
- Java JRE
- .NET SDK
- Apache con página de "Hola Mundo"

## Tabla de Contenido DevOps-reto

1. [terraform](#terraform)
  -[main.tf](#--main.tf)

2. [docker](#docker)
    -[Dockerfile](#--Dockerfile)

3. [.gitignore](#.gitignore)

4. [Readme](#Readme)
```
devops-reto/
├── terraform/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── outputs.tf
│   ├── terraform-key.pem
├── docker/
│   ├── Dockerfile
│   ├── verify.sh
├── .gitignore
└── README.md
```
# terraform
### main.tf
# docker
### Dockerfile

## Ejecución

### Terraform (simulado)
```bash
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
```

**Nota:** No se ejecuta `apply` para evitar cargos, pero el plan es 100% aplicable.

### Docker (funcional)
```bash
docker build -t reto-devops:v2 docker/
docker run -d -p 8080:80 -p 5432:5432 reto-devops:v2
docker exec -it <container_id> /verify.sh
```

## 💡 Conexión entre Docker y la base de datos en AWS

Aunque en este entorno local no se despliegan recursos reales en AWS (como RDS), la imagen Docker está configurada con:

- PostgreSQL instalado y el puerto `5432` expuesto.
- El binario `psql` está disponible para conectar a cualquier host remoto.
- Esto permitiría, por ejemplo, conectar a un RDS de AWS con:

```bash
psql -h <endpoint-RDS> -U admin -d reto_db

## Justificaciones

- **EC2:** se usa por simplicidad, control y soporte con `user_data` para correr Docker automáticamente.
- **RDS PostgreSQL:** fácil conexión desde contenedores, uso común en backend.
- **Seguridad:** acceso SSH y PostgreSQL limitado por IP.

## Gestión del state file

- Por defecto `terraform.tfstate` se guarda local. En producción debe usarse backend remoto (ej. S3 + DynamoDB).

## Gestión del archivo .lock

- `terraform.lock.hcl` asegura versiones exactas de proveedores. No se debe versionar si se actualizan continuamente, pero sí en entornos controlados.

## .gitignore
```
*.tfstate
*.tfstate.backup
.terraform/
terraform.tfvars
terraform.lock.hcl
```
