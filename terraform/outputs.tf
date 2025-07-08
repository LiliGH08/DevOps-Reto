output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "key_name" {
  value = aws_key_pair.deployer.key_name
}

output "private_key_path" {
  value = local_file.private_key.filename
}
