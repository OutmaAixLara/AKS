# Deploy Istio to the cluster

istioctl install --set profile=default -y
kubectl get pods -n istio-system
kubectl label namespace default istio-injection=enabled
kubectl apply -f networking/service-mesh/bookinfo/networking/bookinfo-gateway.yaml