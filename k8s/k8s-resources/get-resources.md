# How to finde all k8s apiGroups, resources and verbs for a role

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
