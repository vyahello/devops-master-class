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

Terraform is used to create multiple virtual servers in cloud e.g AWS with specific resources (load balancers, storage, ingress/egress networks, subnets, http servers, VPC).

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

https://www.terraform.io/language/state

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

Terraform state is known state - terraform.tfstate. Desired state - declared in .tf files, actual state - resources present in a cloud (AWS).

https://www.terraform.io/language/state

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

```bash
variable "iam_user_name_prefix" {
  default =  "my_iam_user"
}
```

```bash
terraform apply -refresh=false
terraform console
> var.iam_user_name_prefix
"my_iam_user"
```

```bash
export TF_VAR_iam_user_name_prefix=FROM_ENV_VARIABLE_IAM_PREFIX
terraform plan -refresh=false
```

Or create `terraform.tfvars`

```terraform
iam_user_name_prefix="VALUE_FROM_TERRAFORM_TFVARS"
```

Or via command line

```bash
# plan is just planning changes
terraform plan -refresh=false -var="iam_user_name_prefix=VALUE_FROM_COMMAND_LINE"
```

Or 

```bash
# apply is used to make changes
terraform apply -var-file="some-name.tfvars"
```

## Lists and Sets

```terraform
variable "names" {
  default = ["tom", "sam", "jane"]
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # VERSION IS NOT NEEDED HERE
}

# create iam users
resource "aws_iam_user" "my_iam_user" {
  count = length(var.names)
  name  = var.names[count.index]
}
```

https://www.terraform.io/language/functions/list

```bash
terraform init
terraform apply
terraform console
> var.names
[
  "tom",
  "sam",
  "jane",
]
> var.names[0]
"tom"
> length(var.names)
3
> reverse(var.names)
[
  "jane",
  "sam",
  "tom",
]
> concat(var.names, ["new"])
[
  "tom",
  "sam",
  "jane",
  "new",
]
> contains(var.names, "ravi")
false
> sort(var.names)
tolist([
  "jane",
  "sam",
  "tom",
])
> range(3)
tolist([
  0,
  1,
  2,
])
```

Delete users 

```bash
terraform destroy -refresh=false
```


```terraform
resource "aws_iam_user" "my_iam_user" {
#  count = length(var.names)
#  name  = var.names[count.index]
  for_each = toset(var.names)
  name = each.value
}
```

Add "tom" user
```bash
terraform apply
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
# check terraform.tfstate file
```

Remove "tom" user
```bash
terraform apply
apply complete! Resources: 0 added, 0 changed, 1 destroyed.
# check terraform.tfstate file
```

## Maps

```terraform
variable "names" {
  default = {
    tom: "NL" ,
    sam: "US",
    jane: "UK"
  }
}
```

```terraform
terraform console
> var.names
{
  "jane" = "UK"
  "sam" = "US"
  "tom" = "NL"
}
> var.names["jane"]
"UK"
> keys(var.names)
[
  "jane",
  "sam",
  "tom",
]
> values(var.names)
[
  "UK",
  "US",
  "NL",
]
> lookup(var.names, "sam")
"US"
> lookup(var.names, "sa", "default")
"default"
```

```terraform
# create iam users
resource "aws_iam_user" "my_iam_user" {
  for_each = var.names
  name = each.key
  tags = {
    country: each.value
  }
}
```

```bash
terraform apply
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

```terraform
variable "names" {
  default = {
    tom: {country: "NL"},
    sam: {country: "US"},
    jane: {country: "UK"}
  }
}

resource "aws_iam_user" "my_iam_user" {
  for_each = var.names
  name = each.key
  tags = {
#    country: each.value
    country: each.value.country
  }
}
```

```bash
terraform apply -refresh=false
```

```terraform
variable "names" {
  default = {
    tom: {country: "NL", dep: "ABC"},
  }
}

# create iam users
resource "aws_iam_user" "my_iam_user" {
  for_each = var.names
  name = each.key
  tags = {
#    country: each.value
    country: each.value.country
    dep: each.value.dep
  }
}
```

```bash
terraform apply -refresh=false
terraform fmt
terraform destroy
Destroy complete! Resources: 3 destroyed.
```

## EC2

EC2 - virtual servers in the cloud. VE server - servers in the cloud. In AWS VE servers called EC2 (elastic compute cloud).

EC2 can have VPC, security_groups, load balancers, ingress/egress network, launched http server.

Terraform is used to create multiple virtual servers in cloud e.g AWS.

### Create EC2 instance

Create EC2 via UI:
  - Step 1: Choose an Amazon Machine Image (AMI) - ami-0c02fb55956c7d316
  - Step 2: Choose an Instance Type (cpu, ram, hardware) - t2.micro
  - Step 3: Configure Instance Details
    - VPC (virtual private cloud) - private network in AWS cloud, you can create subnets here. If you dont want share access with resource - put it into private zone, otherwise use public zone.
    - Network - vpc-06cf03e95b6877090 (default)
  - Next -> Next
  - Step 6: Configure Security Group - launch-wizard-1. Control traffic to your EC2 instance. Allow SSH, HTTP/HTTPS

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

Create EC2 via CMD:
  - check `05-ec2-instances/main.tf` file
  - ```bash
    terraform fmt
    terraform validate
    terraform apply
    ```

Check https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#securityGroups

### EC2 key pair 

https://us-east-1.console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:

```bash
chmod 400 default-ec2.cer
mkdir -p ~/aws/aws_keys
mv default-ec2.cer ~/aws/aws_keys
ls ~/aws/aws_keys
```

### Add EC2 config to terraform 

Check `05-ec2-instances/main.tf` file (resource section)

```bash
terraform fmt
terraform apply -refresh=false
```

### Install http server on EC2 instance

Check `05-ec2-instances/main.tf` file (resource section)

If you already created instance you can't change it. You need to unprovision (destroy) it and provision new instance.
```terraform
resource "aws_instance" "http_server" {
  ami                    = "ami-0c02fb55956c7d316"
  key_name               = "default-ec2"
  instance_type          = "t2.micro"
  // taken from terraform.tfstate file
  vpc_security_group_ids = [aws_security_group.http_server_sg.id]
  # https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#subnets:
  subnet_id              = "subnet-039846e7279c1418e"

  // connect to http server (ec2 instance)
  connection {
    type        = "ssh"
    // current resource
    host        = self.public_ip
    // "ec2-user" is default user name
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }

  provisioner "remote-exec" {
    // type commands inline and list commands here
    inline = [
      "sudo yum install httpd -y", // install httpd
      "sudo service httpd start", // start server
      "echo message | sudo tee /var/www/html/index.html" // copy a file
    ]
  }
}
```

```bash
terraform fmt
terraform validate
terraform apply
terraform console
> aws_instance.http_server.public_dns
(known after apply)
```

```bash
terraform destroy 
terraform apply
```

## Immutable servers 

When you use IAAC, you need to use immutable servers.

### Add default VPC 

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc

```terraform
resource "aws_default_vpc" "default" {}
```

```bash
terraform apply -target=aws_default_vpc.default
```

```terraform
resource "aws_security_group" "http_server_sg" {
  name   = "http_server_sg"
  #  vpc_id = "vpc-02d3805b90db6e3f0"
  vpc_id = aws_default_vpc.default.id
}
```

```bash
terraform console 
> aws_default_vpc.default
vpc-02d3805b90db6e3f0
# show all objects which are in state
terraform show
terraform apply -refresh=false
```

### Add subnet

```terraform
data "aws_subnet_ids" "default_subnets" {
  vpc_id = aws_default_vpc.default.id
}
```

Apply to only subnet changes
```bash
terraform apply -target=data.aws_subnet_ids.default_subnets
terraform console
> data.aws_subnet_ids.default_subnets
{
  "id" = "vpc-02d3805b90db6e3f0"
  "ids" = [
    "subnet-132323",
    "subnet-abcdd2",
  ]
}
> data.aws_subnet_ids.default_subnets.ids
> tolist(data.aws_subnet_ids.default_subnets.ids)[0]
```

```terraform
resource "aws_instance" "http_server" {
  ami                    = "ami-00ee4df451840fa9d"
  key_name               = "default-ec2"
  instance_type          = "t2.micro"
  // taken from terraform.tfstate file
  vpc_security_group_ids = [aws_security_group.http_server_sg.id]
  # https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#subnets:
  # subnet_id = "subnet-039846e7279c1418e"
  subnet_id              = tolist(data.aws_subnet_ids.default_subnets.ids)[0]
}
```

```bash
terraform apply -refresh=false
```


### Add AMI with data providers 

```terraform
data "aws_ami" "aws_linux_2_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

data "aws_ami_ids" "aws_linux_2_latest_ids" {
  owners = ["amazon"]
}
```

Apply changes
```bash
terraform apply -target=data.aws_ami.aws_linux_2_latest
terraform apply -target=data.aws_ami_ids.aws_linux_2_latest_ids
```

```bash
terraform console 
> data.aws_ami_ids.aws_linux_2_latest_ids
...
> data.aws_ami.aws_linux_2_latest 
```

### Terraform graph 

Shows graph of resources present in our configuration

Search for graphviz online and debug - https://dreampuf.github.io/GraphvizOnline.

```terraform
digraph {
  compound = "true"
  newrank = "true"
  subgraph "root" {
  }
}
```

```bash
terraform destroy
```

### Create multiple EC2 instances with load balancer

Refer to `06-ec2-with-elb` folder.

Create one instance for each of subnets
```terraform
resource "aws_instance" "http_server" {
  ami                    = data.aws_ami.aws_linux_2_latest.id
  key_name               = "default-ec2"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http_server_sg.id]
  # logic is disabled here
  for_each               = data.aws_subnet_ids.default_subnets.ids
  subnet_id              = each.value
  tags                   = {
    name : "http_servers_${each.value}"
  }
}
```

```bash
terraform init
terraform apply -target=data.aws_subnet_ids.default_subnets
terraform apply
```

Check https://us-east-1.console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances - should be multiple ec2 instances.

Check for public DNSs in terraform.tfstate file e.g - http://ec2-3-238-118-87.compute-1.amazonaws.com

### Create SG and LB 

```terraform
resource "aws_security_group" "elb_sg" {
  name = "elb_sg"
  #  vpc_id = "vpc-02d3805b90db6e3f0"
  vpc_id = aws_default_vpc.default.id
  // what can you inside this http server
  ingress {
    // allow traffic on 80 port from anywhere
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    // allow traffic on 22 port from anywhere
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // allow traffic from anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1 // all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "elb" {
  name = "elb"
  subnets = data.aws_subnet_ids.default_subnets.ids
  security_groups = [aws_security_group.elb_sg.id]
  # list of instances ids
  instances = values(aws_instance.http_servers).*.id
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
}
```

```bash
terraform console
> aws_instance.http_servers
> value(aws_instance.http_servers)  # values in set format
> values(aws_instance.http_servers).*.id
[
  "i-01260f8218dd246b7",
  "i-0d7469edf5b7144f4",
  "i-0a27c0b58514f81a6",
  "i-0a135ea3ed7026d93",
  "i-0b6366cd51a12d8d1",
  "i-09cdf75ecaf1fc198",
]
```

```bash
terraform apply
...
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.
```

Check http://elb-655865882.us-east-1.elb.amazonaws.com in terraform.tfstate file and see that load is slit between instances.

Destroy LB 

```bash
terraform destroy
```


### Store remote state into S3 

Refer to `07-backend-state` folder.

```bash
terraform init
terraform apply

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:
my_iam_user_complete_details = {
  "arn" = "arn:aws:iam::708363104337:user/my_iam_user_abc"
  "force_destroy" = false
  "id" = "my_iam_user_abc"
  "name" = "my_iam_user_abc"
  "path" = "/"
  "permissions_boundary" = tostring(null)
  "tags" = tomap(null) /* of string */
  "tags_all" = tomap({})
  "unique_id" = "AIDA2J3N3GBIVIJHPZM4D"
}
```

Actual state is set in `outputs.tf` file. 

Create S3 bucket and DynamoDB for locking access to `.tfstate` file.

```terraform
provider "aws" {
  region = "us-east-1"
}


// S3 bucket, store state in S3 bucket
resource "aws_s3_bucket" "enterprise_backend_state" {
  bucket = "dev-app-backend-state-3345"

  // prevent deletion of bucker
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
```

```bash
terraform init 
terraform apply

aws_s3_bucket.enterprise_backend_state: Creating...
aws_dynamodb_table.enterprise_backend_lock: Creating...
aws_s3_bucket.enterprise_backend_state: Still creating... [10s elapsed]
aws_dynamodb_table.enterprise_backend_lock: Still creating... [10s elapsed]
aws_s3_bucket.enterprise_backend_state: Creation complete after 10s [id=dev-app-backend-state-3345]
aws_dynamodb_table.enterprise_backend_lock: Creation complete after 13s [id=dev_app_locks]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Check bucket via https://s3.console.aws.amazon.com/s3/buckets?region=us-east-1

### Update user project to use S3 remote backend 

```terraform
variable app {
  default = "07-backend-state"
}

variable project {
  default = "users"
}

variable env {
  default = "dev"
}

terraform {
  backend "s3" {
    bucket = "dev-app-backend-state-3345"
    key = "${var.app}-${var.project}-${var.env}"
    region = "us-east-1"
    dynamodb_table = "dev_app_locks"
    encrypt = true
  }
}
```

```bash
terraform init
terraform apply
```

Check for tfstate file in S3 bucket via https://s3.console.aws.amazon.com/s3/buckets/dev-app-backend-state-3345?region=us-east-1&tab=objects

### Create multiple envs using terraform workspaces 

```bash
terraform workspace show
default 
# create new workspace
terraform workspace new prod-env
terraform workspace show
terraform init
```

```terraform
resource "aws_iam_user" "my_iam_user" {
  name = "${terraform.workspace}_my_iam_user_abc"
}
```

```bash
terraform plan 
...
+ name                 = "prod-env_my_iam_user_abc"
```

```bash
# switch workspace
terraform workspace select default
terraform plan
```

```bash
terraform plan 
...
~ name          = "my_iam_user_abc" -> "default_my_iam_user_abc"
```

```bash
terraform workspace list
* default
  prod-env
 
terraform workspace select prod-env
Switched to workspace "prod-env".

terraform workspace show
prod-env
```

### Create multiple envs using terraform modules 

Refer to `08-modules`

Modules used for .tf files flexibility.

```terraform
# terraform-modules/users/main.tf

variable "environment" {
  default = "default"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  version = "~> 2.46"
}

resource "aws_iam_user" "my_iam_user" {
  name = "my_iam_user_abc_${var.environment}"
}
```

```terraform
# dev/users/main.tf

module "user_module" {
  source = "../../terraform-modules/users"
  environment = "dev"
}
```

```bash
cd dev/users
terraform init
terraform plan
 + name          = "my_iam_user_abc_dev"
```


```terraform
# qa/users/main.tf

module "user_module" {
  source = "../../terraform-modules/users"
  environment = "qa"
}
```

```bash
cd qa/users
terraform init
terraform plan
 + name          = "my_iam_user_abc_qa"
```


Local variables 
```terraform
resource "aws_iam_user" "my_iam_user" {
  name = "${local.iam_user_extension}_${var.environment}"
}

# local variables, no one can override this variable
locals {
  iam_user_extension = "my_iam_user_abc"
}
```