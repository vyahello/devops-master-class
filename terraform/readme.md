## IAAC 

Manual provisioning app: provision server, install java, install tomcat, configure tomcat, deploy app. Difficult to maintain.

Microservices: service1 (java), service2 (python), service3, service4, service5.

IAAC: create template, provision server, install software, configure software, deploy app.

IAAC advantage: if you have multiple envs for each micro-services or each instances, you can be sure that this servers are consistent. 

Important step for IAAC is provision a server and configure software on server.

Most popular tool for provision a server tool is terraform. You can create vms, load balancers, dbs, net config from terraform config. 

Once you provisioned a server you want to configure a software via config management tools: ansible, chef, puppet.

You use `terraform` to provision 1k servers on a cloud and `ansible` to configure all the software on servers.

## Terraform

Terraform - IAAC tool. Terraform is used to provision resources on the cloud (load balancers, storage, db, server provision).

Install terraform via https://learn.hashicorp.com/tutorials/terraform/install-cli.

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew update
brew upgrade hashicorp/tap/terraform
```
