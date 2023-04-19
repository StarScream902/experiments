locals {
    termination_set = {
      "enableSpotInterruptionDraining": "true"
      "enableRebalanceMonitoring": "true"
      "enableRebalanceDraining": "true"
    }
}

resource "helm_release" "node_drain" {
  name       = "aws-node-termination-handler"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"
  namespace  = "kube-system"

  atomic  = true
  wait    = true
  timeout = 600

  dynamic "set" {
    for_each = local.termination_set

    content {
        name = set.key
        value = set.value
    }
  }
}
