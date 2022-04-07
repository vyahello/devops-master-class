# aws --version
# aws eks --region us-east-1 update-kubeconfig --name in28minutes-cluster
# Uses default VPC and Subnet. Create Your Own VPC and Private Subnets for Prod Usage.
# terraform-backend-state-vyah
# AKIA2J3N3GBI3O5GA7UC

// configuring backend of S3, to store local state to remote backend,
// we want to use S3 as a backend
terraform {
  # https://github.com/hashicorp/terraform-provider-aws
  required_providers {
    aws = {
      # install terraform package from hashicorp/aws
      source  = "hashicorp/aws"
      # terraform package version
      # version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "mybucket" # Will be overridden from build
    key    = "path/to/my/key" # Will be overridden from build
    region = "us-east-1"
  }
}

resource "aws_default_vpc" "default" {

}

data "aws_subnet_ids" "subnets" {
  vpc_id = aws_default_vpc.default.id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

// terraform module called eks - https://github.com/terraform-aws-modules/terraform-aws-eks
module "in28minutes-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.10.0"
  cluster_name    = "in28minutes-cluster"
  cluster_version = "1.21"
  subnets         = ["subnet-03e9bbe7f48e853a7", "subnet-0122aa9b49ab1ffe3"] #CHANGE
  #subnets = data.aws_subnet_ids.subnets.ids
  vpc_id          = aws_default_vpc.default.id

  #vpc_id         = "vpc-1234556abcdef"

  // size of nodes
  node_groups = [
    {
      instance_type = "t2.micro"
      asg_max_size  = 3
#      desired_capacity = 3
#      min_capacity  = 3
    }
  ]
}

// data provider, get details of cluster
data "aws_eks_cluster" "cluster" {
  name = module.in28minutes-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.in28minutes-cluster.cluster_id
}


# We will use ServiceAccount to connect to K8S Cluster in CI/CD mode
# ServiceAccount needs permissions to create deployments
# and services in default namespace
resource "kubernetes_cluster_role_binding" "example" {
  metadata {
    name = "fabric8-rbac"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "default"
  }
}

# Needed to set the default region
provider "aws" {
  region  = "us-east-1"
}