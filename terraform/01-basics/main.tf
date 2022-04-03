terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # VERSION IS NOT NEEDED HERE
}

# object you want to manage in a cloud
# second name is internal s3 name
# plan
resource "aws_s3_bucket" "s3_bucket" {
    bucket = "s3-bucket-28min"  # bucket name
}
