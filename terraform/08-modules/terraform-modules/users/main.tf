# global variables
variable "environment" {
  default = "default"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  version = "~> 2.46"
}

resource "aws_iam_user" "my_iam_user" {
  name = "${local.iam_user_extension}_${var.environment}"
}

# local variables, no one can override this variable
locals {
  iam_user_extension = "my_iam_user_abc"
}