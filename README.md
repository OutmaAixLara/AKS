# AKS

**Environment variables**
```sh
$clusterName="AKS-Cluster"
$resourceGroup="K8S-Test-Small-Env"
$location="swedencentral"
$sectravnet="sectra-vnet"
$sectrasubnetkubernetes = "sectra-subnet-kubernetes"
$subscription="Sectra One Cloud Test - Kubernetes 1"
$subscriptionID="622693e3-522a-4968-af8b-d88f7a78a66a"
```


# Create the resource group
```sh
az group create --subscription $subscription --name $resourcegroup --location $location
```

**AKS Cluster**
#Create the AKS cluster with node pool configuration using "sectra-subnet-Kubernetes" subnet:
```sh
az aks create --name $clusterName --resource-group $resourceGroup --location $location --node-count 2 --vnet-subnet-id /subscriptions/$subscriptionID/resourceGroups/$resourceGroup/providers/Microsoft.Network/virtualNetworks/$sectravnet/subnets/$sectrasubnetkubernetes --network-plugin azure --network-plugin-mode overlay --network-policy azure --pod-cidr 10.244.0.0/16 --dns-service-ip 10.0.0.10 --service-cidr 10.0.0.0/16 --generate-ssh-keys 
```



