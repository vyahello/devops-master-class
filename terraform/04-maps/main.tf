variable "names" {
  default = {
    tom : { country : "NL", dep : "ABC" },
    sam : { country : "US", dep : "DEF" },
    jane : { country : "UK", dep : "XYZ" }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # VERSION IS NOT NEEDED HERE
}

# create iam users
resource "aws_iam_user" "my_iam_user" {
  for_each = var.names
  name     = each.key
  tags = {
    #    country: each.value
    country : each.value.country
    dep : each.value.dep
  }
}
