# Users and privileges in k8s

## Generate new certificate
First, we have to generate a private key and a certificate signing request:

```bash
openssl genrsa -out developers.pem
openssl req -new -key developers.pem -out developers.csr -subj "/CN=developers"
```

Developers will be my username. You can add your user to specific groups by adding them as groups like devops-group:

```bash
openssl req -new -key ivnilv.pem -out ivnilv.csr -subj "/CN=developers/O=devops-group"
```

## Signing the certificate
Use the csr file for generating a CertificateSigningRequest object n Kubernetes:

```bash
cat developers.csr | base64 | tr -d '\n'

cat <<'EOF'> developers-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: user-request-developers
spec:
  groups:
  - system:authenticated
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1dqQ0NBVUlDQVFBd0ZURVRNQkVHQTFVRUF3d0taR1YyWld4dmNHVnljekNDQVNJd0RRWUpLb1pJaHZjTgpBUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBS1hjWERHZG9JOElOMW5PSGRnS3FTRi83cktqeHJZRkZDd2RydThuCm9aRVlUUUtjd2VZSElUVHhMdU14RHFVeTZrb0RwcWhpQUhsMDZIWjhmWWFKSjBuQVpGMCtXb0RyMnlIM296U1MKQXVPeGJuUzFCak91UExvZWdOUjNmeGJEaDdJMkxaRFRFRXV6eFNtWkk5VURtVCtxaHc5SXgzNEJVRXpZNExjawp6bHVxUlE2d3hEZktPenVVZUU0MW50MWtoQldvUEE5dkwwdDNKWUJMbUZvazMreklzMEh4TzZaUW5EV1VxekJkCm0yMC85WCtlSlZWRWZVZmEzendrS2VZS2VteEJQcVF4cDZNMFVRWVlkWHVCajZvbWY2eWZ2OU5rVXJ0VHZaMWoKVDJkbjNIUlk1dWxJQmRxaHVmbVV6VmVDa2FXQURnc3M0NGVpRXpmZDN2RWhmV2NDQXdFQUFhQUFNQTBHQ1NxRwpTSWIzRFFFQkN3VUFBNElCQVFCVEhjOGZ1RWE0NzJLcXFKbmhKbElMdzZjOE93b3BjS3ROeEg3TVJiS01McHM0CndxZUgxbExEdTE0aHZaUVppT1ptM1Zlb28xMUIzOTZjLzFsbjU4WEsvVnBVNk1jZnV2ajVuQ1VoQ1J4aFowenUKUlFScHA3cHVDcEJ5aGQ4WVpVVjJ3cVpKRlNiWk95Sng4VllVS0hZRnQvRGdoZEMvbVNSQ2NhTTVqNnQ4Sk55dQpXQ1FsYy8zUHBnT3p6ZlV0dDh6SUtZRHR4WERYdE1HWFRGTjdoTklEdE9ubTlKa0ovemFDaUthdjYyRzMydTMvCmdtZThla1krNDNNVkFNd0Rxc2l0cFJPeWR4SGUzTm5hT3BuQ1VuWEUyampvdXFkY3VmVGVuVFNId1lmTUMxbU4KUDZSOWRlQXQxYWwycGg4TWVWbUpYOE9Gbnh4SDlrN2krdzVrY0RvQwotLS0tLUVORCBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0K
  usages:
  - client auth
EOF
```

## Create the CertificateSigningRequest and approve it.
Then the Kubernetes API server will generate the certificate that you can use for authentication.

```bash
kubectl create -f developers-csr.yaml
kubectl certificate approve user-request-developers

kubectl get csr
```

output
```
kubectl api-resources -o wide
NAME                       AGE       REQUESTOR   CONDITION
user-request-developers   1m        admin       Approved,Issued`
```

## Now the certificate should be signed.
You can download the new signed public key from the csr resource:

```bash
kubectl get csr user-request-developers -o jsonpath='{.status.certificate}' | base64 -d > developers-user.crt
```

## Create a new user config file

```bash
kubectl --kubeconfig ~/.kube/${KUBECONFIG_NAME}.yaml config set-cluster ${K8S_NAME} --server=https://${K8S_API_SERVER} # if your cluster use selfsignet certificate add --insecure-skip-tls-verify=true
kubectl --kubeconfig ~/.kube/${KUBECONFIG_NAME}.yaml config set-credentials ${K8S_USER_NAME} --client-certificate=developers-user.crt --client-key=developers.pem --embed-certs=true
kubectl --kubeconfig ~/.kube/${KUBECONFIG_NAME}.yaml config set-context default --cluster=${K8S_NAME} --user=${K8S_USER_NAME}
kubectl --kubeconfig ~/.kube/${KUBECONFIG_NAME}.yaml config use-context default
```

After that, you will have a file with such content
```yaml
apiVersion: v1
kind: Config
clusters:
  - cluster:
      insecure-skip-tls-verify: true # if your cluster use selfsignet certificate and you've added --insecure-skip-tls-verify=true
      server: https://K8S_API_SERVER
    name: K8S_NAME
contexts:
  - context:
      cluster: K8S_NAME
      user: K8S_USER_NAME
    name: K8S_USER_NAME@K8S_NAME
current-context: K8S_USER_NAME@K8S_NAME
preferences: {}
users:
  - name: K8S_USER_NAME
    user:
      client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMrekNDQWVPZ0F3SUJBZ0lSQUlFYkJWNUU4RmV3cEREaEpOWVBwUU13RFFZSktvWklodmNOQVFFTEJRQXcKRlRFVE1CRUdBMVVFQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TWpBM01UZ3dPREV4TkRWYUZ3MHlNekEzTVRndwpPREV4TkRWYU1CVXhFekFSQmdOVkJBTVRDbVJsZG1Wc2IzQmxjbk13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBCkE0SUJEd0F3Z2dFS0FvSUJBUUNsM0Z3eG5hQ1BDRGRaemgzWUNxa2hmKzZ5bzhhMkJSUXNIYTd2SjZHUkdFMEMKbk1IbUJ5RTA4UzdqTVE2bE11cEtBNmFvWWdCNWRPaDJmSDJHaVNkSndHUmRQbHFBNjlzaDk2TTBrZ0xqc1c1MAp0UVl6cmp5NkhvRFVkMzhXdzRleU5pMlEweEJMczhVcG1TUFZBNWsvcW9jUFNNZCtBVkJNMk9DM0pNNWJxa1VPCnNNUTN5anM3bEhoT05aN2RaSVFWcUR3UGJ5OUxkeVdBUzVoYUpOL3N5TE5COFR1bVVKdzFsS3N3WFp0dFAvVi8KbmlWVlJIMUgydDg4SkNubUNucHNRVDZrTWFlak5GRUdHSFY3Z1krcUpuK3NuNy9UWkZLN1U3MmRZMDluWjl4MApXT2JwU0FYYW9ibjVsTTFYZ3BHbGdBNExMT09Ib2hNMzNkN3hJWDFuQWdNQkFBR2pSakJFTUJNR0ExVWRKUVFNCk1Bb0dDQ3NHQVFVRkJ3TUNNQXdHQTFVZEV3RUIvd1FDTUFBd0h3WURWUjBqQkJnd0ZvQVVvUlN4TWtTT2F4djYKQW1hZkppeXltc2V1eEFnd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFFbE90dnVCMmFXSlZUbFUrK1RZWGhFUQpobmQzLzBrZkpJV1NSUVNxY1BGY0EyN25FUnI3NDd0MCtZK01CbEJ2RmJmVTcxcThhMndpdnFTNVJtcHY0ZGo2CjJZM0ZKWnpoMFd0ZHdJa3FVUWRNZEl3djl4TFRyUmthMkhCd3RZQjk3ZldBeVBncG1VdCtpVzZPRk5OcHA0UjIKeVNJdlhXUVBzSzNIa0lxaTdtYTJ1bkJjQzhWTFZueWJEWUtpUU9aRlY1SVdxV3hoSmRGWTFzd1h4cnNQa2Fjdgo1SlBCWkxONDR6bGlIV3dENVJpTTFMK0luVlF3UVM1bGhKVytEUGUvTktrbDBENzRsOUxtVkUxU0oyU21pb1NqCkp6NlhWMm82Z1NaR2JxY2VPTDk5Tk5oVTRxL1pDVFVjYjlENjF0M0l1VkZVdW8vZzlPYXFqVjB4ekNjMHNpOD0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
      client-key-data: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2Z0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktnd2dnU2tBZ0VBQW9JQkFRQ2wzRnd4bmFDUENEZFoKemgzWUNxa2hmKzZ5bzhhMkJSUXNIYTd2SjZHUkdFMENuTUhtQnlFMDhTN2pNUTZsTXVwS0E2YW9ZZ0I1ZE9oMgpmSDJHaVNkSndHUmRQbHFBNjlzaDk2TTBrZ0xqc1c1MHRRWXpyank2SG9EVWQzOFd3NGV5TmkyUTB4QkxzOFVwCm1TUFZBNWsvcW9jUFNNZCtBVkJNMk9DM0pNNWJxa1VPc01RM3lqczdsSGhPTlo3ZFpJUVZxRHdQYnk5TGR5V0EKUzVoYUpOL3N5TE5COFR1bVVKdzFsS3N3WFp0dFAvVi9uaVZWUkgxSDJ0ODhKQ25tQ25wc1FUNmtNYWVqTkZFRwpHSFY3Z1krcUpuK3NuNy9UWkZLN1U3MmRZMDluWjl4MFdPYnBTQVhhb2JuNWxNMVhncEdsZ0E0TExPT0hvaE0zCjNkN3hJWDFuQWdNQkFBRUNnZ0VBQW5BOGJNQlFBWHBSOGdDTlFNVmJXakk2ekthS3Y5ZFFSaHZEbkNGOWh4Z1AKM2NkM05FNExoMjg2VEwzR1pOaGNTRzFJVUhac1lseTlKQ3pOWGFKN2tPS0N0em80ODJkRVIvb1BqTERPMlJFZApPaHNGTmRKTWMwSUtpOVViNmJaRE12UUg5SGFkNlRjQjRZd3VVaTNrM1dKQTdSRVpXYmxrT0ZVQjdMOWVSMHV4CitKeEhOaUcwM2xKdG5PajYyM1pBaHZUbWZOWXBVVXVhUHlzYmJmb2I4aFh1TVFXREpadWFuM1czdSs2cEVXankKY3I2bjBvMGRReTEwejFWZk5Xb21VK2hBMGdXS1BTRWhreXI0M2pNdWpBbHR3OXkyS1pmMGxEcEVORVlPRzZJcgpEZ0I1R1prdzViaGt2c0V6aVJCOG9sVTBoS1JBRGE2VlkvTkx3aTlmcFFLQmdRRGNiZVNianlaMHZKcmp3bGJ1ClByNjZsajE3cUNOS3pwQjkzWWFiWVZFNjZJcjJGZ2NzM2c3Z3U2Vlo0S1RFNjBqM0I0eHQ2M3JSRGNCMy9VWjAKeSt6WWRIL3I4TTVYNVhUTTk0bm5CTzZmeUpJNGNLQ0JlZmtkU1hmTEZuV0p3YTVuMnhVMlBVZE53aW5taFJPbgppL2o2SWhwU2tEVmxzMUp1MjVMZVkyTFdYUUtCZ1FEQW9ETXFBdDJ5ajZLVTJ1UHV6dm5BSkpGSzV1eTdVUEwvCnBJa01HQ3MyYnpldjVqOU5VbnhqNlcvL0s3OTY5TDRLRzlnc3kvcmdXK3ZvMUVYWmp6Ris0V28vR1ZINDBCMm0KeUtweC9ONytiN3ZyZmNOMGVIbGd0SFVqNzYyQkxoWkVWRTcwaWVxSTB5MHNqckNoYUNrWE9xT0w5Z3ZtQUQ5cQpTK2N0VkMrZWt3S0JnR3FsMEtGaTFSeE4xREsxNkJGRTBrcThQZXNDSW5FakY4Mk56SDZJeXlCUk9rcHR4Zkx6ClRRZDJRajRGN2pKSUUvbFE4YVNNOWRNSGNFT2RpdVVmZE93VkVYODU5dHVYN0xidVhRNGsyTDc5NzZEVy9SRW4Kemx0WkhGaHArVnc1RlFTeWZzVExTU0JaL0tQSFp3YjlOZXp2YXdUZk9MYUgyQzVDbGdCNjNXc1JBb0dCQUpqdwoyWTdhdGJIbjc1dW03R0VaUHgxN0swMUFhdWdUVHMwQms3cmhtYlhmdW1SVU9TQ29oSkZEc0tQMjFWTEg3ZmZTCndlSlhsdnI2b1NXOUhUU3ZTQXBJNmZYdG9iTWZjdHVRNmh3VlBlemhSR0NtKzBDSHd6K3dLRzMvQ0ZEUUNlZjQKMUxPK3FWUTM3OTgzOERCSHBwQ0dBNExHT2c1RlZoU003YUdFL1VZM0FvR0JBS0lPZjNMTVc5OXpTNDEwTTFragp6VnUyQ3NZYTdNYmZlM0dDdFhHV3ZUUE1KL0ZjREZwbmNYTy9ubTJTeUxSSU1PMTcwMDN1VXAxS2dLV3ZMZFduCkxaYnl0SzJ2a1YwZ2ZqWmZYWEFVSU8rWWhKN0RKeTJzbUJaNHlVYjVpejB3aWhWZzdWM2JrUWpDQ2kxa3dicnEKSSs5MXNZSFMxNWpidjUzdmQ2NEU3ZStjCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K
```
## Of course, you need rbac for this user:

All resources you can fine here, executed this command
```bash
kubectl api-resources -o wide
```
This command will show you all possible apiGroups, resources and verbs.

Below you can see an example of output.
```
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND                             VERBS
bindings                                       v1                                     true         Binding                          [create]
componentstatuses                 cs           v1                                     false        ComponentStatus                  [get list]
deployments                       deploy       apps/v1                                true         Deployment                       [create delete deletecollection get list patch update watch]
localsubjectaccessreviews                      authorization.k8s.io/v1                true         LocalSubjectAccessReview         [create]
alertmanagerconfigs               amcfg        monitoring.coreos.com/v1alpha1         true         AlertmanagerConfig               [delete deletecollection get list patch create update watch]
alertmanagers                     am           monitoring.coreos.com/v1               true         Alertmanager                     [delete deletecollection get list patch create update watch]
csistoragecapacities                           storage.k8s.io/v1beta1                 true         CSIStorageCapacity               [create delete deletecollection get list patch update watch]
storageclasses                    sc           storage.k8s.io/v1                      false        StorageClass                     [create delete deletecollection get list patch update watch]
```

The `NAME` is the `resource` that you want to apply permissions to.

`APIVERSION` corresponds to the `apiGroups` role specification

Also, these are all the supported `VERBS` for the resource and what you specify in `verbs`.

```bash
cat <<'EOF'> developers-rbac.yaml
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: developers
rules:
- apiGroups: ["*"]
  resources: ["pods","deployments","configmaps","daemonsets","statefulstates","replicasets","jobs","cronjobs","services","ingresses","apps","namespaces"]
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["*"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["*"]
  resources: ["pods/portforward"]
  verbs: ["create"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: developers
  namespace: dev
subjects:
- kind: User
  name: developers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: developers
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: dev
  name: developers
rules:
- apiGroups: ["*"]
  resources: ["pods/*"]
  verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: developers
  namespace: dev
subjects:
- kind: User
  name: developers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: developers
EOF

kubectl apply -f developers-rbac.yaml
```

## Let’s test if the new kubeconfig we generated worked fine:

```bash
kubectl --kubeconfig ~/.kube/scw-k8s-developers.yaml get pods
```
And finally you have to see a list of pods
