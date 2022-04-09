# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

// provides a resource to manage default AWS VPC in the current region
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc
resource "aws_default_vpc" "default" {

}

// HTTP Server -> Security Group
// Security Group -> 80 TCP, 22 TCP, CIDR ["0.0.0.0/0"]
resource "aws_security_group" "http_server_sg" {
  name = "http_server_sg"
  #  vpc_id = "vpc-02d3805b90db6e3f0"
  vpc_id = aws_default_vpc.default.id
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

resource "aws_instance" "http_server" {
  // provision 2 instances
  count = 2
  ami           = "ami-0c02fb55956c7d316"
  key_name      = "default-ec2"
  instance_type = "t2.micro"
  // taken from terraform.tfstate file
  vpc_security_group_ids = [aws_security_group.http_server_sg.id]
  # https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#subnets:
  # subnet_id = "subnet-039846e7279c1418e"
  subnet_id = tolist(data.aws_subnet_ids.default_subnets.ids)[0]
}
