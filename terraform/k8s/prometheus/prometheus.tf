# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#     annotations = {
#       "meta.helm.sh/release-name"       = "kube-prometheus-stack"
#       "meta.helm.sh/release-namespace"  = "monitoring"
#     }
#     labels = {
#       "app.kubernetes.io/managed-by"  = "Helm"
#       "kubernetes.io/metadata.name"   = "monitoring"
#       "name"                          = "monitoring"
#     }
#   }
# }

resource "helm_release" "kube-prometheus-operator" {
  # depends_on = [ kubernetes_namespace.monitoring ]
  name       = "kube-monitoring"
  namespace  = "monitoring"
  atomic     = true
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "39.13.3"

  values = [
    <<YAML
# fullnameOverride: "kube-prometheus-stack"

namespaceOverride: "monitoring"

prometheus:
  prometheusSpec:
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
  service:
    type: NodePort

grafana:
  enabled: false

alertmanager:
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 2Gi

coreDns:
  service:
    selector:
      k8s-app: "kube-dns"
kubeEtcd:
  enabled: false
kubeControllerManager:
  enabled: false
kubeScheduler:
  enabled: false
kubeProxy:
  enabled: false
kubeletService:
  enabled: false
kubelet:
  serviceMonitor:
    https: true
    YAML
  ]
}
