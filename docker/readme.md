# Intro
Agile Automation architecture.

Code commit -> unit tests -> code quality -> package -> integration tests.

After code commit -> run unit/code quality continuously -> this is CI.

## Devops
Devops - enhanced communication between business, development and operations,
make deployment easier, operations work visible. automate as much software activities as possible.

Devops automation focus on provision server, install software, configure software, deploy app

Continious Deployment - cont deploy new version of software. 
Code commit -> unit tests -> integration tests -> package -> deploy -> automated tests

Continious Delivery - cont deploy software to production. 
Code commit -> unit tests -> integration tests -> package -> deploy -> automated tests -> testing approvals -> deploy next

IAAC - create infra the same way you create your software code. Create infra - servers, load balancers, db using code and configuration.

## Docker

Reasons - application packaging (same for java, python, js), multi-platform (local machine, data center, cloud), 
light-weight compared to VM (only specific packages used), isolated containers.

VM - hardware, host os, hypervisor, software, app.

Docker - infra, host os, docker engine, container. Isolated from each other, set specific % of CPU.

Docker - simplify deployment, avoid error prone. 
Use case - microservices, os independent, services isolation. 
All containers run in bridge network.

### Commands

```bash
docker run -p 5001:5000 in28min/hello-world-python:0.0.1.RELEASE
docker run -p 5001:5000 in28min/hello-world-java:0.0.1.RELEASE
docker run -p 5001:5000 in28min/hello-world-nodejs:0.0.1.RELEASE

# hello-world-nodejs - repo
# 0.0.1.RELEASE - tag

docker run -d -p 5001:5000 in28min/hello-world-nodejs:0.0.1.RELEASE
docker logs cdf81ce4a3e2
docker images 
docker container ls  # same as 'docker ps'
docker container stop cdf81ce4a3e2
docker image ls  # same as 'docker images'
```

#### Docker images

```bash
docker pull mysql
docker search mysql
docker image history mysql  # see docker image layers
docker image inspect 2322859dbb57  # details 
docker image remove mysql  # remove docker image
docker container rm 6568695699a1  # remove docker container
docker container ls -a
docker container stop f339bce8485c
```

#### Docker containers

```bash
docker container run -d -p 5001:8080 in28min/hello-world-rest-api:0.0.1.RELEASE
docker container ls 
docker container unpause 407f66e52c0f
docker container stop 407f66e52c0f  # stops all services during shutting down 
docker container kill 407f66e52c0f  # kills all services, does not shut down gracefully, send signal kill 
docker container inspect eb946c3b7960  # inspect running container
docker container prune  # remove closed containers
```

#### Docker system

```bash
docker system df  # disk usage
docker system events  # track container events, will see stop/kill containers
docker system prune  # Remove unused data
docker system prune -a  # Remove all unused data, when u r out of memory, delete images which are not used 
docker stats eb946c3b7960  # Check used CPU, memory
docker container run -d -p 5002:8080 -m 512m --cpu-quota=50000 in28min/hello-world-java:0.0.1.RELEASE  # use only 512m of memory, 50% of cpu
```


#### Docker build

```bash
cd docker/hello-world/python
docker build -t vyahello/hello-python:0.0.1 .
docker run -p 5001:5000 vyahello/hello-python:0.0.1
docker history 8e70e65991af  # check build layers
docker login
docker push vyahello/hello-python:0.0.1
```

_ENTRYPOINT_ vs _CMD_ 

ENTRYPOINT is used to be static, but you can overwrite via `--entrypoint` cli arg

CMD is used to be modified
