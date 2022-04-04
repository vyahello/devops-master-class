variable "aws_key_pair" {
  default = " ~/aws/aws_keys/default-ec2.cer"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

// HTTP Server -> Security Group
// Security Group -> 80 TCP, 22 TCP, CIDR ["0.0.0.0/0"]
resource "aws_security_group" "http_server_sg" {
  name   = "http_server_sg"
  vpc_id = "vpc-02d3805b90db6e3f0"
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
  ami           = "ami-00ee4df451840fa9d"
  key_name      = "default-ec2"
  instance_type = "t2.micro"
  // taken from terraform.tfstate file
  vpc_security_group_ids = [aws_security_group.http_server_sg.id]
  # https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#subnets:
  subnet_id = "subnet-039846e7279c1418e"

  // connect to http server (ec2 instance)
  connection {
    type = "ssh"
    // current resource
    host = self.public_ip
    // "ec2-user" is default user name
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }

  provisioner "remote-exec" {
    // type commands inline and list commands here
    inline = [
      "sudo yum install httpd -y",                                                         // install httpd
      "sudo service httpd start",                                                          // start server
      "echo Virtrual Service is at ${self.public_dns} | sudo tee /var/www/html/index.html" // copy a file
    ]
  }
}
