# Kubernetes Horizontal Autoscaling Demo

This piece of code can be used to see how Horizontal Pod Autoscaler works in Kubernetes.

# Setting up

- Install minikube.

- Spin a cluster - `minikube start`. You can use your host's Docker daemon if you want by using `eval $(minikube docker-env)` - this would allow you to use the docker image that you've built locally.

- Get the metric server up and running - 
```shell
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/metrics-server/v1.8.x.yaml
serviceaccount/metrics-server created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io configured
service/metrics-server configured
```
This will allow our resources to get metrics from other deployments.

- Run the server - 
```shell
$ kubectl run flask-cpu-server --image=singhpratyush/flask-cpu-server:latest --requests=cpu=200m --limits=cpu=500m --expose --port=8000
service/flask-cpu-server created
deployment.apps/flask-cpu-server created
```

- You should have the deployment and service resources created
```shell
$ kubectl get deployments
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
flask-cpu-server   1/1     1            1           93s
$ kubectl get services
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
flask-cpu-server   ClusterIP   10.103.125.12   <none>        8000/TCP   3m14s
kubernetes         ClusterIP   10.96.0.1       <none>        443/TCP    6m27s
```
    Note that since the service is `ClusterIP` type and hence can't be accessed outside the cluster (just in case if you were planning to use `minikube proxy flask-cpu-server`).

- Enable autoscaling 
```shell
$ kubectl autoscale deployment flask-cpu-server --cpu-percent=50 --min=1 --max=10
horizontalpodautoscaler.autoscaling/flask-cpu-server autoscaled
```

You should have a horizontal pod autoscaling resource now - 
```shell
$ kubectl get hpa
NAME               REFERENCE                     TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
flask-cpu-server   Deployment/flask-cpu-server   0%/50%          1         10        1          36s
```

- Start making loads of request and see how hpa changes
```
$ kubectl run -i --tty load-generator --image=alpine sh

/ # while true; do wget -q -O- http://flask-cpu-server.default.svc.cluster.local:8000; done
```
