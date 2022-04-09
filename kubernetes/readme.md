# Kubernetes

Cheat sheet - https://kubernetes.io/docs/reference/kubectl/cheatsheet

Use case - increase number of docker instances in case of huge load. Make load balancing between available docker instances.
When instance is down it can bring an instance up.

Used for container orchestration (manage 1k instances, 1k of microservices), auto-scaling, load balancing, self-healing.

```bash
docker run -p 8080:8080 in28min/hello-world-rest-api:0.0.1.RELEASE
# create deployment, quickly deploy app with this image
kubectl create deployment hello-world-rest-api --image=in28min/hello-world-rest-api:0.0.1.RELEASE
# expose port 8080
kubectl expose deployment hello-world-rest-api --type=LoadBalancer --port=8080
# create 3 instances 
kubectl scale deployment hello-world-rest-api --replicas=3
# check pods 
kubectl get pods
# delete instance, but it will be created anyway, 3 will be anyway
kubectl delete pod hello-world-rest-api-687d9c7bc7-pcsw7
# set max instances to 10
kubectl autoscale deployment hello-world-rest-api --max=10 --cpu-percent=70
# make new release without anything going down 
kubectl edit deployment hello-world-rest-api  # minReadySeconds: 15
# make new release, application remains up and running
kubectl set image deployment hello-world-rest-api hello-world-rest-api=in28min/hello-world-rest-api:0.0.2.RELEASE
```

## Cluster 

Cluster is a set of master node(s)(manage cluster, manage the nodes) and worker node(s)(run your application, do the work).

Kubernetes can manage 1k nodes.

Create google cloud account at https://console.cloud.google.com

Go to google cloud platform and create a kubernetes cluster.

Kubernetes on Cloud: AKS (azure), Amazon EKS (elastic kubernetes service) and GKE (google kuber engine).

Go to cloud shell and connect to cluster
```bash
gcloud container clusters get-credentials in28minutes-cluster --zone us-central1-c --project carbon-hulling-345821
kubectl version
# deploy application to a kubernetes cluster
kubectl create deployment hello-world-rest-api --image=in28min/hello-world-rest-api:0.0.1.RELEASE
# expose deployment to the outside world
kubectl expose deployment hello-world-rest-api --type=LoadBalancer --port=8080
```

Go to services and ingresses and check deployment and check http://35.188.132.193:8080/hello-world deployment.

```bash
kubectl get pods
kubectl get replicaset
kubectl get deployment
kubectl get service
```

`kubectl create deployment` -> deployment, replicaset and pod

`kubectl expose deployment` -> service

## POD

POD - smallest deployable unit. You cannot have a container without a POD. Container lives inside a POD. POD is a collection of containers that can run on a host.

POD puts containers together. On any node can be multiple pods. Each pod can contain multiple containers.

Node -> POD1 (Container1 and Container2) and POD2 (Container3 and Container4).

```bash
kubectl get pods -o wide  # get ip of a POD
kubectl explain pods
kubectl describe pod hello-world-rest-api-687d9c7bc7-2722m
```

Delete POD
```bash
kubectl get pods,services,deployments,jobs
kubectl delete deployment hello-world-rest-api
kubectl delete -n default deployment hello-world-rest-api
kubectl delete -n default deployment.apps/fast-weather
kubectl get replicaset  # DESIRED = 3
# track what happened 
kubectl get events
# sort by time
kubectl get events --sort-by=.metadata.creationTimestamp
# delete all deployment and replicaset
kubectl delete all -l app=hello-world-rest-api 
```

## Replicaset 

Ensure that specific number of PODs run all the time. If one POD is down, it will create a new POD.
It is all about maintaining the number of PODs.

POD is a wrapper of a set of containers, has an ip address. 

POD is where your containers run, provides a grouping of containers. Replicaset ensures that a N of PODs are always running.

Help:
```bash
kubectl explain replicaset
```

```bash
kubectl get replicaset
kubectl get rs  # same
kubectl get pods -o wide
# pod is absent, but new one is created instead, because of replicaset
kubectl delete pod hello-world-rest-api-687d9c7bc7-2722m
# run 3 replicas of a container
kubectl scale deployment hello-world-rest-api --replicas=3
# now 3 pods
kubectl get pods
```

## Deployment

Deployment is a set of Replicaset1 (POD1 and POD2) and Replicase2 (POD3 and POD4). 
You can create new docker release without cluster being down.
Release new version of application without a downtime. 
Ensure that new release happens without a delay.

```bash
kubectl get rs -o wide
# deploy new version with wrong image name
kubectl set image deployment hello-world-rest-api hello-world-rest-api=DUMMY_IMAGE:TEST
# will be 2 replicaset
kubectl get rs -o wide
kubectl get pods  # one POD has InvalidImageName
# debug failed pod 
kubectl describe pod hello-world-rest-api-84d8799896-tml7w
kubectl get events --sort-by=.metadata.creationTimestamp
# deploy new version with proper image
# check http://35.188.132.193:8080/hello-world - should be V2
kubectl set image deployment hello-world-rest-api hello-world-rest-api=in28min/hello-world-rest-api:0.0.2.RELEASE
kubectl get pods
kubectl get rs 
# check background events
kubectl get events --sort-by=.metadata.creationTimestamp -o wide
# get deployment YAML config 
kubectl get deployment hello-world-rest-api -o yaml
```

Delete deployment
```bash
kubectl delete deployment hello-world-rest-api
```

## Service 

Service allows your app to receive traffic via permanent ip address. Service is created when we do expose deployment.

Go to service and ingress and check services.

Load balances is a service which is created for us.

Kubernetes service is running as a cluster ip service. Cluster service can only be accessed inside the cluster.

```bash
# every pod has ip address
kubectl get pods -o wide
kubectl delete pod hello-world-rest-api-7ddff5dfc6-btv2p
kubectl get services  # will show load balancer and cluster ip
```

## Google cloud engine

Go to `Workload` to see deployments, you can scale, edit, roll update of deployments. 
You can check release history, details, events, see YAML config etc.

## Master vs Worker nodes 

Master node: api server (kube-apiserver), db (etcd), scheduler (kube-scheduler), controller manager (kube-controller-manager).

- All config, deployment, services, scaling, detail stored in DB.
- Scheduler responsible for scheduling PODs into the nodes. In k8s cluster you have several nodes. 
When we create a new POD, you have to decide which node the POD has to be scheduled. 
Schedules PODs onto appropriate node.

- Container manager - kubectl, make sure that actual state of k8s cluster matches with desired state.
- User apps will not be run on master node, but in PODs inside worker node.

Worker node: node agent (kubelet), network component (kube-proxy), container runtime (CRI - docker, rkt), PODs (multiple pods running containers)

- On a single node you can have multiple pods.
- Kubelet - monitors what happens on the node and send it to master node.
- Kube-proxy - expose deployment as a service.
- Container runtime - docker

Master node does not run apps, it contains tools to control worker nodes.

K8S can run not only docker containers.

If master goes down, app will run anyway.

Node is virtual server where your POD is running.

```bash
kubectl get componentstatuses  # check all components
NAME                 STATUS    MESSAGE             ERROR
etcd-0               Healthy   {"health":"true"}
controller-manager   Healthy   ok
etcd-1               Healthy   {"health":"true"}
scheduler            Healthy   ok
```

## Install GCloud & kubectl

GCloud - cmd interface for google cloud. 

Follow gcloud instructions - https://cloud.google.com/sdk/docs/install

```bash
gcloud init
gcloud container clusters get-credentials in28minutes-cluster --zone us-central1-c --project carbon-hulling-345821
```

Follow kubectl instruction - https://kubernetes.io/docs/tasks/tools/install-kubectl-macos

## Switch K8S context 

Useful to switch between gcloud and local docker desktop instance.

```bash
kubectl config get-contexts
kubectl config use-context <context>
```

## Rollout 

```bash
kubectl rollout history deployment hello-world-rest-api
# record to history
kubectl set image deployment hello-world-rest-api hello-world-rest-api=in28min/hello-world-rest-api:0.0.3.RELEASE --record=true
# now it has a rollout record 
kubectl rollout history deployment hello-world-rest-api
# check if V3 is properly deployed 
curl http://35.188.132.193:8080/hello-world
# rollback to previous revision
kubectl rollout undo deployment hello-world-rest-api --to-revision=1
# check if V1 is properly rolled out 
curl http://35.188.132.193:8080/hello-world
# check logs of a POD, same as docker logs and image ID
kubectl logs hello-world-rest-api-687d9c7bc7-5vrf6
```

## YAML 

Kubernetes is declarative - you can define steps in YAML file.

```bash
kubectl get deployment hello-world-rest-api
kubectl get deployment hello-world-rest-api -o yaml
# store deployment to yaml
kubectl get deployment hello-world-rest-api -o yaml > deployment.yaml
# store service to yaml
kubectl get service hello-world-rest-api -o yaml > service.yaml 
# update yaml file and apply 
kubectl apply -f deployment.yaml  # change to 2 replicas
kubectl get pods  # only 2 PODS
# delete deployment and replicas
kubectl get all -o wide
kubectl delete all -l app=hello-world-rest-api 
# build deployment from scratch
kubectl apply -f deployment.yaml
# new pods are created
kubectl get pods
# see interactively
kubectl get service --watch
# same as service
kubectl get svc --watch
# run cmd every 2 secs interactively
watch curl http://35.188.132.193:8080/hello-world
# see changes in deployment yaml
kubectl diff -f deployment.yaml  # change to 3 replicas
kubectl apply -f deployment.yaml
```

## Create replicaset 

Use `kind: ReplicaSet` in YAML file. Replicaset cannot handle releases. If you change `image` nothing will happen.

If you need a release, use deployment.

```bash
kubectl delete all -l app=hello-world-rest-api
kubectl apply -f deployment.yaml  # kind: ReplicaSet
kubectl get svc --watch
curl http://34.132.238.93:8080/hello-world
```

## Multiple deployments with one service

Add two deployments with different version (version: v1 or v2) in deployment.yaml

```bash
# two deployments are created
kubectl apply -f deployment.yaml
kubectl get all  # 2 deployments, 2 replicas, 4 pods
watch curl http://34.132.238.93:8080/hello-world  # will be 2 versions with different pods
# add "version: v1" in "selector" to send traffic to v1 deployment
kubectl apply -f deployment.yaml
```

## Top node and POD commands 

```bash
kubectl get pods --all-namespaces -l app=hello-world-rest-api
# all services
kubectl get services --all-namespaces
# sort by type in deployment.yaml file
get services --all-namespaces --sort-by=.spec.type 
# cluster info 
kubectl cluster-info
# debug cluster
kubectl cluster-info dump
# how much cpu is used in node
kubectl top node
# how much cpu is used in pod
# shortcut
kubectl top pod
kubectl get svc  # services
kubectl get ev  # events
kubectl get rs  # replicas
kubectl get ns  # namespaces
kubectl get no  # nodes
kubectl get po  # pods
```

## Delete all pods and services 

```bash
kubectl delete all -l app=hello-world-rest-api
kubectl get all
# delete deployment 
kubectl get deploy -A
kubectl delete deploy depName -n nameSpace
# delete namespace 
kubectl delete namespaces devops-tools jenkins
kubectl get ns
```

## Run microservices in k8s

```bash
cd 01-currency-exchange
kubectl apply -f deployment.yaml
cd 02-currency-conversion
kubectl apply -f deployment.yaml
kubectl get svc --watch
# 1 exchange container and 2 conversion containers, check ip addresses and ports
kubectl get pods
```

Containers already shared same network cuz `CURRENCY_EXCHANGE_SERVICE_HOST - 10.100.14.185` is set within k8s:
- http://34.132.238.93:8000/currency-exchange/from/EUR/to/INR
- http://104.198.225.20:8100/currency-conversion/from/EUR/to/INR/quantity/10

Also, there is `env` key in deployment.yaml - `name: CURRENCY_EXCHANGE_SERVICE_HOST`.

```bash
kubectl logs currency-conversion-5b8c4cb8d5-f6dpb
kubectl get svc  # there is 'currency-exchange' name so CURRENCY_EXCHANGE_SERVICE_HOST is set as a var automatically.
# check 'CURRENCY_EXCHANGE_SERVICE_HOST - http://currency-exchange'
```

If we have 2 separate microservices then we need 2 deployments with 2 different services. 

If we have 2 container versions are then we can create 2 deployments with same service.

## Microservices centralized config with ConfigMaps

Microservices Envs: 
 - Dev: Dev1 
 - QA: QA1, QA2
 - Stage: Stage1 
 - Prod: Prod1, Prod2, Prod3, Prod4

Centralized configuration is useful for multiple environments via ConfigMaps.

```bash
kubectl apply -f 00-configmap.yaml
kubectl get configMaps
kubectl describe configMaps
kubectl describe configMaps currency-conversion-config-map
# in deployment.yaml uncomment 'valueFrom' to pick up value from configMap
# comment 'value' and uncomment 'valueFrom'
kubectl apply -f deployment.yaml
kubectl logs currency-conversion-c5697fbd8-rvfd9
```

## Kubernetes ingress 

Change `type: NodePort`

```bash
cd 01-currency-exchange
kubectl apply -f deployment.yaml
cd 02-currency-conversion
kubectl apply -f deployment.yaml
# now both types are NodePort
kubectl get svc
# create ingress 
kubectl apply -f ingress.yaml
```

Ingress - maps income requests to specific url pattern. Request first goes to ingress, ingress looks for url pattern. 
More info check in `load balancing` section (there is 34.111.249.71:80 address).

Note - one ip is used for 2 services and port is not required:
  - http://34.111.249.71//currency-exchange/from/EUR/to/INR
  - http://34.111.249.71/currency-conversion/from/EUR/to/INR/quantity/10
