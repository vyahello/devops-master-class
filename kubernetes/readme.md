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
kubectl delete -n default deployment hello-world-rest-api
kubectl get replicaset  # DESIRED = 3
# track what happened 
kubectl get events
# sort by time
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Replicaset 

Ensure that specific number of PODs run all the time. If one POD is down, it will create a new POD.
It is all about maintaining the number of PODs.

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

