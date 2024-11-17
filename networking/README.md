# AKS

**Environment variables:**
```sh
$clusterName="AKS-Cluster"
$resourceGroup="K8S-Test-Small-Env"
$location="swedencentral"
$sectravnet="sectra-vnet"
$sectrasubnetkubernetes = "sectra-subnet-kubernetes"
$subscription="Sectra One Cloud Test - Kubernetes 1"
$subscriptionID="622693e3-522a-4968-af8b-d88f7a78a66a"
```


**Create the resource group:**
```sh
az group create --subscription $subscription --name $resourcegroup --location $location
```

**AKS Cluster:**

*Create the AKS cluster with node pool configuration using "sectra-subnet-Kubernetes" subnet. We are using the Overlay netowkring model and we enable network policy to implement network segmentation.*
```sh
az aks create --name $clusterName --resource-group $resourceGroup --location $location --node-count 2 --vnet-subnet-id /subscriptions/$subscriptionID/resourceGroups/$resourceGroup/providers/Microsoft.Network/virtualNetworks/$sectravnet/subnets/$sectrasubnetkubernetes --network-plugin azure --network-plugin-mode overlay --network-policy azure --pod-cidr 10.244.0.0/16 --dns-service-ip 10.0.0.10 --service-cidr 10.0.0.0/16 --generate-ssh-keys 
```


**Verify the network configuration:**
```sh
Download credentials and configures the Kubectl to use them:
az aks get-credentials -n $clusterName -g $resourceGroup
#Merged "AKS-Cluster" as current context in C:\Users\mo-el\.kube\config

kubectl config use-context AKS-Cluster
#Switched to context "AKS-Cluster".

kubectl get node -o wide
#aks-nodepool1-22495599-vmss000000   Ready    <none>   105m   v1.29.9   192.168.8.4   <none>        Ubuntu 22.04.5 LTS   5.15.0-1074-azure   containerd://1.7.23-1
#aks-nodepool1-22495599-vmss000001   Ready    <none>   105m   v1.29.9   192.168.8.5   <none>        Ubuntu 22.04.5 LTS   5.15.0-1074-azure   containerd://1.7.23-1

kubectl get pod -o wide -n kube-system
#kube-proxy-hts9g                      1/1     Running   0          97m   192.168.8.4    aks-nodepool1-22495599-vmss000000 -> This pod for instance is using host networking.
#metrics-server-f46f56d7b-hncmh        2/2     Running   0          96m   10.244.1.195   aks-nodepool1-22495599-vmss000000 -> This pod has an IP address from the Pod CIDR.

az aks show -n $clusterName -g $resourceGroup --query networkProfile.podCidr -o tsv
#10.244.0.0/16 -> Pod CIDR

az aks show -n $clusterName -g $resourceGroup --query networkProfile.serviceCidr -o tsv
#10.0.0.0/16 -> service CIDR

az aks show -n $clusterName -g $resourceGroup --query networkProfile.dnsServiceIp -o tsv
#10.0.0.10 -> DNS service IP
```


**Verify network policy setup:**


First, create a *demo* namespace to run the example pods:
```sh
kubectl create namespace demo
```
Create a *server* pod. This pod serves on TCP port 80:
```sh
kubectl run server -n demo --image=k8s.gcr.io/e2e-test-images/agnhost:2.33 --labels="app=server" --port=80 --command -- /agnhost serve-hostname --tcp --http=false --port "80"
```
Create a *client* pod. The following command runs Bash on the client pod:
```sh
kubectl run -it client -n demo --image=k8s.gcr.io/e2e-test-images/agnhost:2.33 --command -- bash
```
Now, in a separate window, run the following command to get the server IP
```sh
kubectl get pod --output=wide -n demo
#server   1/1     Running   0          45m   10.244.1.246   aks-nodepool1-22495599-vmss000000   <none>           <none>
```
**Test connectivity without network policy:**

In the client's shell, run the this to verify connectivity with the server. No output means  the connection is successful.
```sh
/agnhost connect <server-ip>:80 --timeout=3s --protocol=tcp
```
**Test connectivity with network policy:**

Create a file named demo-policy.yaml:
```sh
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: demo-policy
  namespace: demo
spec:
  podSelector:
    matchLabels:
      app: server
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: client
    ports:
    - port: 80
      protocol: TCP
```
Apply the YAML manifest:
```sh
kubectl apply –f demo-policy.yaml
```
Now, in the client's shell, verify again connectivity with the server:
```sh
/agnhost connect <server-ip>:80 --timeout=3s --protocol=tcp
```
Output should display a timeout, because connectivity with traffic is blocked:
```sh
TIMEOUT
```
To be able to connect to the server again you can label the client with what we have in demo-policy.yaml:
```sh
kubectl label pod client -n demo app=client
```