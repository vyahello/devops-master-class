provider "azurerm" {
  //version = "~>2.0.0"
  features {}
}

// creation of resource group
resource "azurerm_resource_group" "resource_group" {
  // located in variables.tf, if you want same account with different environments
  name     = "${var.resource_group}_${var.environment}"
  location = var.location
}

// creation of cluster
// AKS - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
resource "azurerm_kubernetes_cluster" "terraform-k8s" {
  // cluster name
  name                = "${var.cluster_name}_${var.environment}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_prefix          = var.dns_prefix

  linux_profile {
    // create admit username
    admin_username = "ubuntu"

    // public ssh key to associate with the cluster
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  // config node pool
  default_node_pool {
    // node pool name
    name            = "default"
    node_count      = 1
    vm_size         = "standard_d2ads_v5"  // 1 CPU, 2 GB Mem
  }

  // to be able to talk to azure
  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  tags = {
    Environment = var.environment
  }
}


// config for azure backend
terraform {
  backend "azurerm" {
    # storage_account_name="<<storage_account_name>>" #OVERRIDE in TERRAFORM init
    # access_key="<<storage_account_key>>" #OVERRIDE in TERRAFORM init
    # key="<<env_name.k8s.tfstate>>" #OVERRIDE in TERRAFORM init
    # container_name="<<storage_account_container_name>>" #OVERRIDE in TERRAFORM init
  }
}
