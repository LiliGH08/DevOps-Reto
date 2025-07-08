variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "allowed_ip" {
  description = "IP address allowed for SSH and PostgreSQL access"
  type        = string
}

variable "key_name" {
  description = "key name for EC2 instance"
  type        = string
}

variable "db_username" {
  description = "Nombre de usuario para la base de datos"
  type        = string
  default     = "reto_user"
}