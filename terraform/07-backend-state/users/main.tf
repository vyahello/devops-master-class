variable app {
  default = "07-backend-state"
}

variable project {
  default = "users"
}

variable environment {
  default = "dev"
}

terraform {
  backend "s3" {
    bucket = "dev-app-backend-state-3345"
    key = "07-backend-state-users-dev"
    region = "us-east-1"
    dynamodb_table = "dev_app_locks"
    encrypt = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  version = "~> 2.46"
}

resource "aws_iam_user" "my_iam_user" {
  name = "my_iam_user_abc"
}
