
Used tools ; 

minikube
kubectl
helm
docker 
istio
grafana 
prometheus

Steps to follow : 

1. create k8s cluster with minikube
2. set docker env for use the Docker daemon inside the Minikube 
3. Build go and java image with dockerfile (for java used openjdk, for go used alpine images)
4. create grafana and prometheus pods with helm for monitor requests.
5. port-forward for accessing prometheus and grafana interface and create dashboard with query 
6. Apply manifest files  

Commands to run step by step :

# Minikube create kubernetes cluster , default memory is not enough
$ minikube start --memory 8192 

# set docker env for use the Docker daemon inside the Minikube 
$ eval $(minikube docker-env)

# create app images into minikube
$ docker build -t trivago-go:trivago-go-app -t trivago-java:trivago-java-app .

# create prometheus containers (alertmanager, pushgateway, nodeexporter, prom-server)
$ helm install prometheus stable/prometheus

# create grafana container
$ helm install grafana --set=adminUser=trivago --set=adminPassword=trivago --set=service.type=NodePort stable/grafana

# port forwarding for manage dashboards 
$ export POD_NAME=$(kubectl get pods --namespace default -l "app=grafana" -o jsonpath="{.items[0].metadata.name}")
$ kubectl port-forward $POD_NAME 3000
$ export POD_NAME=$(kubectl get pods | grep prometheus-server | awk '{print $1}' )
$ kubectl port-forward $POD_NAME 9090

# create grafana dashboard
sum(rate(http_requests_total{app="trivago-app"}[5m])) by (version)

# istio injection enabled
$ kubectl label namespace default istio-injection=enabled

# manifest files applied
$ kubectl apply -f app-go.yaml -f app-java.yaml
$ kubectl apply -f ./gateway.yaml -f ./weight.yaml

# test
$ service=$(minikube service istio-ingressgateway -n istio-system --url | head -n1)
$ while sleep 0.1; do curl "$service" -H 'Host: trivago-app.local'; done

