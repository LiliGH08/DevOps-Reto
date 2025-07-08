FROM registry.access.redhat.com/ubi9/ubi

USER root

RUN dnf update -y && dnf install -y \
    git \
    maven \
    postgresql \
    java-17-openjdk \
    dotnet-sdk-6.0 \
    httpd \
    procps-ng \
    && dnf clean all

# Servidor Apache con Hola mundo
RUN echo "<h1>Hola Mundo desde Docker en RHEL</h1>" > /var/www/html/index.html

# Script de validación de requisitos
COPY verify.sh /verify.sh
RUN chmod +x /verify.sh

EXPOSE 80 5432

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]