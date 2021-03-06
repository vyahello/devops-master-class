# Intro
Agile Automation architecture.

Code commit -> unit tests -> code quality -> package -> integration tests.

After code commit -> run unit/code quality continuously -> this is CI.

## Devops
Devops - enhanced communication between business, development and operations,
make deployment easier, operations work visible. automate as much software activities as possible.

Devops automation focus on provision server, install software, configure software, deploy app

Business -> Development -> Operations. DevOps - CAMS (culture, automation, measurement, sharing).

Continious Deployment - cont deploy new version of software. 
Code commit -> unit tests -> integration tests -> package -> deploy -> automated tests

Continious Delivery - cont deploy software to production. 
Code commit -> unit tests -> integration tests -> package -> deploy -> automated tests -> testing approvals -> deploy next

IAAC - create infra the same way you create your software code. Create infra - servers, load balancers, db using code and configuration.

## DevOps Best practices 

- Standardization. U have standard ways how things are done
- Teams with Cross-Functional Skill
- Focus on Culture
- Automate everything
- Immutable infrastructure. If there are changes for server, create new server but not changing existed.
- Dev/Prod env similar, deploy/monitor apps the same way. If envs are similar you can find problems early.
- Version control everything
- Self provision. Dev team should not wait for operation team for provision, they should be able to provision servers on their own.

DevOps maturity development:
  - Does every commit triggers automated tests and automated code quality?
  - Is your code continuously delivered to prod?
  - Do you use pair programming?
  - Do you use TDD and BDD?
  - Can dev team self provision envs?
  - How long it tak to deliver a quick fix?

DevOps maturity test:
  - Are your tests full automated with high quality?
  - Do your builds fail when your automated tests fail?
  - Are your testing cycles small? How much time it take?
  - Do you have automated non-functional tests (load, perf, etc.)? 

DevOps maturity deployment:
  - Do you have dev/prod similarity?
  - Do you use a/b testing?
  - Do you use canary deployments?
  - Can you deploy at the click of a button?
  - Can you rollback at the click of a button?
  - Can you provision and release infra?
  - Do you use IAAC and version control?

DevOps maturity monitoring:
  - Does the team use monitoring system?
  - Can dev team get access to logs at the click of button?
  - Can the team get an automated alert if something goes wrong in prod?
  
## Docker

Reasons - application packaging (same for java, python, js), multi-platform (local machine, data center, cloud), 
light-weight compared to VM (only specific packages used), isolated containers.

No more - "Works in my local machine".

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

### ENTRYPOINT vs CMD

ENTRYPOINT is used to be static, but you can overwrite via `--entrypoint` cli arg

CMD is used to be modified

### Microservices

Instead of building one monolith, use small microservices.

Service1 (node) -> Service2 (python) -> Service3 (sql)

Share same network:
```bash
docker network ls  # check local networks
docker network inspect bridge  # if containers are in bridge network, they cant talk to each other
# let one container talk to other via 'link'
docker run -p 8100:8100 -d --name=currency-conversion --link=currency-exchange --env=CURRENCY_EXCHANGE_SERVICE_HOST=http://currency-exchange in28min/currency-conversion:0.0.1-RELEASE
# run in host network, but available only on Linux

# create 'custom' network
docker network create currency-network
docker run -p 8000:8000 -d --name=currency-exchange --network=currency-network in28min/currency-exchange:0.0.1-RELEASE
docker run -p 8100:8100 -d --name=currency-conversion --env=CURRENCY_EXCHANGE_SERVICE_HOST=http://currency-exchange --network=currency-network in28min/currency-conversion:0.0.1-RELEASE
```

#### Docker compose 

```bash
docker-compose up
docker-compose up -d
docker network ls  # see new network 'microservices_currency'
docker network inspect 08e5c9121d20
docker-compose config  # validate yaml file
docker-compose images
docker-compose top 
docker-compose down
```