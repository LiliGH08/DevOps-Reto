#!/bin/bash

echo "🛠 Verificando herramientas instaladas..."

echo "===== OS VERSION ====="
cat /etc/redhat-release

echo -n "Git: " && git --version
echo -n "Maven: " && mvn -v | head -n 1
echo -n "PostgreSQL: " && psql --version
echo -n "Java: " && java -version 2>&1 | head -n 1
echo -n ".NET: " && dotnet --version
echo -n "Apache: " && httpd -v | head -n 1

echo -e "\n===== Apache index.html ====="
cat /var/www/html/index.html


echo "Verificando conectividad a PostgreSQL en AWS (simulada)"
# Simulación de conexión: 
# docker exec -it <container_id> psql -h <AWS_ENDPOINT> -U admin -d reto_db

echo "Recuerda que para conectarse a la base de datos en AWS, este contenedor deberá iniciarse con el host de RDS permitido en el grupo de seguridad."
