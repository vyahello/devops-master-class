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

- Desired state: I want s3 bucket with 5 virtual servers, I want this state in cloud. What I want to be created in cloud based on `main.tf` file`.
- Known: result of previous execution (stores in .tfstate file). What is present is in .tfstate file (result of previous execution).
- Actual: whatever this state in bucket. What is actually present in AWS. 

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

## Outputs 

Print outputs after "terraform apply" execution.

```bash
# main.tf
output "s3_bucket_versioning" {
  value = aws_s3_bucket.s3_bucket.versioning[0].enabled
}

terraform apply -refresh=false
```