# Ansible

IAAC - provision servers and configure servers with right software.

Create Template -> Provision Server -> Install Software -> Configure Software -> Deploy App

Ansible is IAAC tool used for configuration management (install and configure software).

## Install ansible 

https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

```bash
pip install ansible
ansible --version
```

## Create EC2 instance for ansible 

Ansible talks to servers via ssh keys to manage software.

Go to AWS and create EC2 instance. 

check `09-multiple-ec2-instances` folder.

```bash
export AWS_SECRET_ACCESS_KEY=XXXX 
export AWS_ACCESS_KEY_ID=XXXX
terraform init
terraform apply
...

http_server_public_dns = [
  "ec2-54-158-89-105.compute-1.amazonaws.com",
  "ec2-18-234-187-237.compute-1.amazonaws.com",
]
```
