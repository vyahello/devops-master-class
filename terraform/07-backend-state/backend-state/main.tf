provider "aws" {
    region = "us-east-1"
    version = "~> 2.46"
}


// S3 bucket, store state in S3 bucket
resource "aws_s3_bucket" "enterprise_backend_state" {
  bucket = "dev-app-backend-state-3345"

  // prevent deletion of bucket
  lifecycle {
    prevent_destroy = true
  }
  // store multiple versions of the state
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        // which algo ewe want to use, AES - advanced encryption standard
        sse_algorithm = "AES256"
      }
    }
  }
}


// Locking - you don't want the state to be corrupted, lock it, use Dynamo DB to lock state
// DynamoDB table
resource "aws_dynamodb_table" "enterprise_backend_lock" {
  name = "dev_app_locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"  # string

  }
}


