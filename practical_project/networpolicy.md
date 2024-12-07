## Verify network policy setup:


First, create a `demo` namespace to run the example pods:
```sh
kubectl create namespace demo
```
Create a `server` pod. This pod serves on TCP port 80:
```sh
kubectl run server -n demo --image=k8s.gcr.io/e2e-test-images/agnhost:2.33 --labels="app=server" --port=80 --command -- /agnhost serve-hostname --tcp --http=false --port "80"
```
Create a `client` pod. The following command runs Bash on the client pod:
```sh
kubectl run -it client -n demo --image=k8s.gcr.io/e2e-test-images/agnhost:2.33 --command -- bash
```
Now, in a separate window, run the following command to get the server IP
```sh
kubectl get pod --output=wide -n demo
#server   1/1     Running   0          45m   10.244.1.246   aks-nodepool1-22495599-vmss000000   <none>           <none>
```
## Test connectivity without network policy:

In the client's shell, run the this to verify connectivity with the server. No output means  the connection is successful.
```sh
/agnhost connect <server-ip>:80 --timeout=3s --protocol=tcp
```
## Test connectivity with network policy:

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
