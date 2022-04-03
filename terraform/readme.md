# IAAC 

Manual provisioning app: provision server, install java, install tomcat, configure tomcat, deploy app. Difficult to maintain.

Microservices: service1 (java), service2 (python), service3, service4, service5.

IAAC: create template, provision server, install software, configure software, deploy app.

IAAC advantage: if you have multiple envs for each micro-services or each instances, you can be sure that this servers are consistent. 

Important step for IAAC is provision a server and configure software on server.

Most popular tool for provision a server tool is terraform. You can create vms, load balancers, dbs, net config from terraform config. 

Once you provisioned a server you want to configure a software via config management tools: ansible, chef, puppet.

You use `terraform` to provision 1k servers on a cloud and `ansible` to configure all the software on servers.

# Terraform

https://www.terraform.io/language

Terraform - IAAC tool. Terraform is used to provision resources on the cloud (load balancers, storage, db, server provision).

Provision resources in the cloud from declarative code.

Install terraform via https://learn.hashicorp.com/tutorials/terraform/install-cli.

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew update
brew upgrade hashicorp/tap/terraform
```

## Create terraform project 

Create `main.tf` file with `provider` option:
```terraform
provider "aws" {
    region = "us-east-1"
    version = "~>2.46"
}
```

Execute:
```bash
terraform init
```

## Create AWS IAC user access 

Create user via https://us-east-1.console.aws.amazon.com and give admin access.

## Create terraform env vars 

```bash
export AWS_ACCESS_KEY_ID=XXXX
export AWS_SECRET_ACCESS_KEY=XXXX
```

## Create S3 bucket

S3 (Simple storage service) bucket could be created via WEB https://s3.console.aws.amazon.com/s3

S3 bucket could be also created via CLI.

- Create `resource` in main.tf file
- Create s3 bucket via terraform:
  ```bash
  terraform plan 

  terraform apply  # execute, create s3 bucket
  aws_s3_bucket.s3_bucket: Creating...
  aws_s3_bucket.s3_bucket: Still creating... [10s elapsed]
  aws_s3_bucket.s3_bucket: Creation complete after 12s [id=s3-bucket-28min]
  ```
- Go to S3 WEB and check the bucket list

## States

- Desired state: I want s3 bucket with 5 virtual servers, I want this state in cloud. What I want to be created in cloud based on `main.tf` config file`.
- Known: result of previous execution (stores in .tfstate files). What is present is in .tfstate files (result of previous execution).
- Actual: whatever this state in bucket (in the cloud). What is actually present in AWS. 

When we do terraform apply - it looks in tfstate and in AWS and check if we have changes, compares desired state to actual state.

Change S3 bucket name and execute `terraform apply`. It will delete old and create a new bucket name.

```bash
# add "versioning {enabled=true}" in terraform.tfstate file
terraform apply
```

## Console 

```bash
terraform console
> aws_s3_bucket.s3_bucket  # name of resource in main.tf file object_type.object_name
...

> aws_s3_bucket.s3_bucket.versioning
tolist([
  {
    "enabled" = true
    "mfa_delete" = false
  },
])
> aws_s3_bucket.s3_bucket.versioning[0]
{
  "enabled" = true
  "mfa_delete" = false
}
> aws_s3_bucket.s3_bucket.versioning[0].enabled
true
```

### Outputs 

Print outputs after "terraform apply" execution.

```terraform
# main.tf
output "s3_bucket_versioning" {
  value = aws_s3_bucket.s3_bucket.versioning[0].enabled
}
```

```bash
terraform apply -refresh=false
```

## Create IAM user with terraform

```terraform
resource "aws_iam_user" "my_iam_user" {
    name = "my_iam_user_abc"
}
```

```bash
terraform plan -out iam.tfplan
terraform apply "iam.tfplan"
```

```terraform
output "iam_user_complete_details" {
  value = aws_iam_user.my_iam_user
}
```

```bash
terraform apply -refresh=false
terraform console
> aws_iam_user.my_iam_user.arn
"arn:aws:iam::804278070838:user/my_iam_user_abc"
```

Update user name

```terraform
# create iam user
resource "aws_iam_user" "my_iam_user" {
    name = "my_iam_user_updated"
}
```

```bash
# update only this resource
terraform apply -target="aws_iam_user.my_iam_user"
```

## Tfstate file

Without this file terraform cannot identify known state and refresh actual values from the cloud.

You should not do changes in .tfstate file directly. Terraform state should not be shared, due to sensitive info.

Remote backend (s3) is the best option to store the state.

`terraform.tfstate.backup` acts as a backup if `terraform.tfstate` gets corrupted.

If you have multiple people in the project you need to share state with them.
Don't commit `terraform.tfstate` files due to sensitive info.

We can store terraform tfstate in s3 bucket.

If you delete tfstate files and execute `terraform apply`, terraform will create new resource again.

### Split tf file into separate files

You can have tons of .tf files with no specific name, they will be concatenated together.

Create `outputs.tf` file:

```bash
# outputs.tf
output "s3_bucket_versioning" {
  value = aws_s3_bucket.s3_bucket.versioning[0].enabled
}
output "s3_bucket_complete_details" {
  value = aws_s3_bucket.s3_bucket
}
output "iam_user_complete_details" {
  value = aws_iam_user.my_iam_user
}
```

Destroy all the resources (iam user and s3 bucket):
```bash
terraform destroy

aws_iam_user.my_iam_user: Destroying... [id=my_iam_user_updated]
aws_s3_bucket.s3_bucket: Destroying... [id=s3-bucket-28min-01]
aws_s3_bucket.s3_bucket: Destruction complete after 1s
aws_iam_user.my_iam_user: Destruction complete after 2s
```

## Create multiple users

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user

```terraform
resource "aws_iam_user" "my_iam_user" {
    count = 2
    name = "my_iam_user__${count.index}"
}
```

```bash
cd terraform/02-basics
terraform init
terraform apply
```

change `count = 3`
```bash
terraform apply
```

Go to https://us-east-1.console.aws.amazon.com/iamv2/home#/users to check users

## Terraform commands 

https://www.terraform.io/cli/commands/apply

```bash
terraform console
> aws_iam_user.my_iam_user[1]
...
```

```bash
# validate .tf files
terraform validate
# format file (with 2 spaces) such as 'black'
terraform fmt
# provides human-readable output of a current state
terraform show
```

## Variables in terraform
