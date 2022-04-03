# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # VERSION IS NOT NEEDED HERE
}

# create iam users
resource "aws_iam_user" "my_iam_user" {
  count = 3
  name  = "my_iam_user__${count.index}"
}

