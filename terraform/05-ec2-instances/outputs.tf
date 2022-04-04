# show output after "terraform apply" cmd
output "aws_security_group_http_server_details" {
  value = aws_security_group.http_server_sg
}
