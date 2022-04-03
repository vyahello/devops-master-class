# show output after "terraform apply" cmd
output "s3_bucket_versioning" {
  value = aws_s3_bucket.s3_bucket.versioning[0].enabled
}
output "s3_bucket_complete_details" {
  value = aws_s3_bucket.s3_bucket
}
output "iam_user_complete_details" {
  value = aws_iam_user.my_iam_user
}
