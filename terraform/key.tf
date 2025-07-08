# Genera una clave privada (formato PEM)
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Registra la clave pública en AWS
resource "aws_key_pair" "deployer" {
  key_name   = "terraform-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Guarda la clave privada en un archivo local
resource "local_file" "private_key" {
  filename        = "${path.module}/terraform-key.pem"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0400"
}