# Kubernetes

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

Create google cloud account at https://console.cloud.google.com

Cluster is a set of master node(s)(manages cluster) and worker node(s)(run your application).
