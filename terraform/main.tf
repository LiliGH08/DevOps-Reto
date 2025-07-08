resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "reto-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "reto-public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "reto-public-subnet-2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "reto-internet-gw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "reto-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "ssh_web" {
  name        = "ssh_web_access"
  description = "Allow SSH, HTTP, PostgreSQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "reto-sg-ssh-web"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-allow-access"
  description = "Allow PostgreSQL access from EC2 and local machine"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Access from EC2 Security Group"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ssh_web.id]
  }

  ingress {
    description = "Access from your local IP"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  ingress {
  description = "All VPC internal"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"]
}

ingress {
    description = "Access from Docker bridge network"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["172.17.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-allow-access"
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh_web.id]
  key_name      = aws_key_pair.deployer.key_name 
  associate_public_ip_address = true

  depends_on = [aws_key_pair.deployer]

  user_data = <<-EOF
            #!/bin/bash
            apt update
            apt install -y docker.io
            systemctl start docker
            systemctl enable docker
            usermod -aG docker ubuntu
            apt install -y postgresql-client-common
            apt install -y postgresql-client-14
            sleep 15
            #docker run -d --name reto-container --dns=8.8.8.8 --network host -p 80:80 lilianar/reto-devops:latest
            docker run -d --name reto-container --dns=8.8.8.8 -p 80:80 lilianar/reto-devops:latest
  EOF

  tags = {
    Name = "reto-ec2"
  }
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "reto-db-subnet-group"
  subnet_ids = [aws_subnet.public.id, aws_subnet.public_2.id]
  description = "Subnets en diferentes AZs"
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  db_name              = "reto_db"
  username             = var.db_username
  password             = "Password123!"
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
}
