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

https://us-east-1.console.aws.amazon.com/ec2

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

## Ansible host file and host groups 

````text 
# add host name to ansible_hosts

dev1 ansible_host=3.80.29.192
dev2 ansible_host=3.93.240.150
qa1 ansible_host=18.208.145.16
````

```bash
# on all devices
ansible all -a 'python --version'
# on dev devices only
ansible dev -a 'python --version'
# run on a group 
ansible first -a 'python --version'
ansible groupofgroups -a 'python --version'
ansible devsubset -a 'python --version'
ansible --list-host all
ansible --list-host \!first
```

## Add ping playbook 

```yaml
# first play
- hosts: all
  tasks:
    # first task
    - name: Ping All Servers
      action: ping
    # second task
    - debug: msg="First"
# second play
# run only on dev hosts
- hosts: dev
  tasks:
    - debug: msg="First"
```

```bash
# run playbook
ansible-playbook playbooks/01-ping.yaml
```

This is a play that can have multiple tasks.

## Understand control node, managed nodes and Inven 

Scripts -> Ansible -> Server1/2/3 

- Control node - machine where ansible is running, where you control all hosts.
- Other servers are management nodes.
- Inven what we have in ansible_host file. 

```yaml
# first play
- hosts: qa
  tasks:
    # first task
    - name: Execute shell commands
      shell: uname
      register: uname_result
    # second task
    # {{ var }}
    - debug: msg="{{ uname_result }}"
```

```bash 
ansible-playbook playbooks/02-shell.yaml
```

```bash
PLAY [qa] ********************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************

TASK [Execute shell commands] ************************************************************************************
changed: [qa1]

TASK [debug] *****************************************************************************************************
    "msg": {
        "changed": true,
        "cmd": "uname",
        "delta": "0:00:00.038775",
        "end": "2022-04-10 18:49:09.096328",
        "failed": false,
        "msg": "",
        "rc": 0,
        "start": "2022-04-10 18:49:09.057553",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "Linux",
        "stdout_lines": [
            "Linux"
        ]
    }
}

PLAY RECAP *******************************************************************************************************
qa1                        : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

## Ansible variables 

Variables are read via `{{ var }}` syntax.

```yaml
# first play
- hosts: dev
  vars_files:
    - variables.yaml
  tasks:
    # first task
    - name: Var Value
      debug: msg="Value is {{ var1 }}"
```

Use from var command line
```bash
ansible-playbook playbooks/03-vars.yaml -e var1=CMDVal
```

Read vars from file
```yaml
# variables.yaml

var1: "Yaml Value"
```

## Ansible Facts

Facts are general info about ansible controller and managed hosts collected in setup. 

```yaml
- hosts: qa
  tasks:
    - name: Kernel
      debug: msg="{{ ansible_kernel }}"
    - name: Hostname
      debug: msg="{{ ansible_hostname }}"
    - name: Distrib
      debug: msg="{{ ansible_distribution }}"
    - debug: var=ansible_architecture
```

```bash
ansible-playbook playbooks/04-facts.yaml

PLAY [qa] ********************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************
ok: [qa1]

TASK [Kernel] ****************************************************************************************************
    "msg": "5.10.102-99.473.amzn2.x86_64"
}

TASK [Kernel] ****************************************************************************************************
ok: [qa1] => {
    "msg": "ip-172-31-84-123"
}

TASK [Kernel] ****************************************************************************************************
ok: [qa1] => {
    "msg": "Amazon"
}
ok: [qa1] => {
    "ansible_architecture": "x86_64"
}

PLAY RECAP *******************************************************************************************************
qa1                        : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```


```bash
# list of servers ansible managing right now
# you can get vars from there like 'ansible_kernel' and 'ansible_hostname'
ansible qa -m setup
```

## Install http server on hosts 

Install Apache on all dev servers. 
```yaml
- hosts: dev
  become: true
  tasks:
    - yum:
        # install httpd on ec2 instances
        name:
          - httpd
        state: present
    # we are starting httpd server
    - service: name=httpd state=started enabled=yes
    # copy msg to index.html file
    - raw: 'echo Welcome | sudo tee /var/www/html/index.html'
```

```bash
ansible-playbook playbooks/05-install-apache.yaml
```

Check `http://3.80.29.192` via web, http server should run.


## Reuse ansible playbooks 

```yaml
- import_playbook: 01-ping.yaml
- import_playbook: 02-shell.yaml
- import_playbook: 03-vars.yaml
```

```bash
# check all tasks
ansible-playbook playbooks/06-playbooks.yaml --list-tasks
# run only on qa env 
ansible-playbook -l qa playbooks/01-ping.yaml
```

## Conditional and loops

```yaml
- hosts: qa
  vars:
    system: "Cisco"
    color: "Red"
  tasks:
    - debug: var=ansible_system
    - debug: var=color
      # run when system is Linux
      when: system == 'Linux'
    # execute loop with multiple items, each item with name and country
    - debug: var=item
      with_items:
      - name: Sam
        country: US
      - name: Luke
        country: GB
```


```bash
ansible-playbook playbooks/07-conditionals-loops.yaml

ok: [qa1] => (item={'name': 'Sam', 'country': 'US'}) => {
    "ansible_loop_var": "item",
    "item": {
        "country": "US",
        "name": "Sam"
    },
    "item.name": "Sam"
}
ok: [qa1] => (item={'name': 'Luke', 'country': 'GB'}) => {
    "ansible_loop_var": "item",
    "item": {
        "country": "GB",
        "name": "Luke"
    },
    "item.name": "Luke"
}
```

## EC2 dynamic inventory

Multiple EC2 servers we created via terraform.

```bash
pip install boto3
```

Create `01-aws_ec2.yaml` dynamic inventory file.

```yaml
plugin: aws_ec2
region:
  - us-east-1
# add groups
keyed_groups:
  - prefix: arch # will group based on architecture
    key: 'architecture'
  - prefix: tag
    key: 'tags' # will group based on tag
  - key: tags.Env
    separator: ''
  - key: instance_type
    prefix: instance_type
```

```bash
# list of servers info
ansible-inventory --list
# group instances
ansible-inventory --graph
ansible-playbook playbooks/08-dynamic.yaml
```

## Create EC2 with ansible

https://us-east-1.console.aws.amazon.com/ec2

You can use ansible for provision servers. 

```yaml
- hosts: localhost
  tasks:
    # create ec2 instances
    - ec2:
        # taken from Key Pairs
        key_name: default-ec2
        instance_type: t2.micro
        # AMI - simple template for all the software.
        image: ami-0c02fb55956c7d316
        region: us-east-1
        # how many instances
        count: 1
        # took from launch instance -> Configure Instance -> subnet id
        vpc_subnet_id: subnet-03e9bbe7f48e853a7
        assign_public_ip: yes
        # security group
        group: ["http_server_sg"]
        instance_tags: {type: http, Environment: QA}
        wait: yes
      register: ec2_output
    - debug: var=ec2_output
```

```bash
ansible-playbook playbooks/09-create-ec2.yaml
```

## Declarative configuration for ansible

```yaml
...
  exact_count: 2
  count_tag: {type: http}  # create instances wih tag 'http'
...
```

## Delete EC2 instances 

```bash
cd 09-multiple-ec2-instances
terraform destroy
```

