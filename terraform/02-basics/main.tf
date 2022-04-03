variable "environment" {
  default = "dev"
}

variable "iam_user_name_prefix" {
  type    = string #any, tuple, list, bool, number, map, set
  default = "my_iam_user"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # VERSION IS NOT NEEDED HERE
}

# create iam users
resource "aws_iam_user" "my_iam_user" {
  count = 3
  name  = "${var.iam_user_name_prefix}__${count.index}"
}
