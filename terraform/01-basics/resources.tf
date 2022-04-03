# object you want to manage in a cloud
# second name is internal s3 name
# plan
resource "aws_s3_bucket" "s3_bucket" {
    bucket = "s3-bucket-28min-01"  # bucket name
  versioning {
    enabled = true
  }
}

# create iam user
resource "aws_iam_user" "my_iam_user" {
    name = "my_iam_user_updated"
}