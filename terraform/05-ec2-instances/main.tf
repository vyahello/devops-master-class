# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

// HTTP Server -> Security Group
// Security Group -> 80 TCP, 22 TCP, CIDR ["0.0.0.0/0"]
resource "aws_security_group" "http_server_sg" {
  name   = "http_server_sg"
  vpc_id = "vpc-06cf03e95b6877090"
  // what can you inside this http server
  ingress {
    // allow traffic on 80 port from anywhere
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    // allow traffic on 22 port from anywhere
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // allow traffic from anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1 // all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  // tag of security group
  tags = {
    name = "http_server_sg"
  }
}
