Kubernetes Dashboard is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage applications running in the cluster and troubleshoot them, as well as manage the cluster itself.


## Installation with Helm

Kubernetes Dashboard supports only Helm-based installation currently as it is faster and gives us better control
over all dependencies required by Dashboard to run. We now use a single-container, DBless [Kong](https://hub.docker.com/r/kong/kong-gateway) installation
as a gateway that connects all our containers and exposes the UI. Users can then use any ingress controller or proxy
in front of kong gateway. To find out more about ways to customize your installation check out [helm chart values](charts/kubernetes-dashboard/values.yaml).

In order to install Kubernetes Dashboard simply run:
```console
# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
```
## Accessing Dashboard

Use `kubectl port-forward` and access Dashboard with a simple URL. Depending on the chosen installation method you might need to access different service.

For Helm-based installation when `kong` is being installed by our Helm chart simply run:
```shell
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

Now access Dashboard at: [https://localhost:8443](https://localhost:8443).

Or you can use `kubectl proxy` and access Dashboard with a simple URL.

```shell
kubectl proxy --port=8001
```

Now access Dashboard at: [http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard-kong-proxy:443/proxy/](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard-kong-proxy:443/proxy/)



## Creating sample user and getting Bearer Token for ServiceAccount

For each of the following snippets for `ServiceAccount` and `ClusterRoleBinding`, you should copy them to new manifest files like `dashboard-adminuser.yaml` and use `kubectl apply -f dashboard-adminuser.yaml` to create them.
To create these manifests and get a Bearer Token for ServiceAccount, please refer to https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md.



