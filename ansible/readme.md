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

## Setup Ansible project 

Any change with ansible is something called `play` and all of them are stored in `playbook`

All ansible scripts are stored in `playbook` folder.

Ansible configuration stored in `ansible.cfg`.

Ansible EC2 AWS instance config (ip, etc.) stored in `ansible_hosts` file.

```bash
ansible --version 
config file = /Users/fox/files/myprojects/devops-master-class/ansible/ansible.cfg

# able to ping all servers
chmod 400 ~/aws/aws_keys/default-ec2.cer
ansible -m ping all
...
3.93.240.150 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

## Ansible commands 

```bash
# run command on all servers
ansible all -a 'whoami'
# ssh to ec2 host
ssh -vvv -i ~/aws/aws_keys/default-ec2.cer ec2-user@3.80.29.192
```
