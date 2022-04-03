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
    bucket = "s3-bucket-28min-01"  # bucket name
  versioning {
    enabled = true
  }
}

# show output after "terraform apply" cmd
output "s3_bucket_versioning" {
  value = aws_s3_bucket.s3_bucket.versioning[0].enabled
}
output "s3_bucket_complete_details" {
  value = aws_s3_bucket.s3_bucket
}
