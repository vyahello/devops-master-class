variable "names" {
  default = ["rav", "tom", "sam", "jane"]
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # VERSION IS NOT NEEDED HERE
}

# create iam users
resource "aws_iam_user" "my_iam_user" {
#  count = length(var.names)
#  name  = var.names[count.index]
  for_each = toset(var.names)
  name = each.value
}
