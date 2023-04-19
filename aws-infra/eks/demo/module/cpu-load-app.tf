module "pull_git_repo" {
  source = "git::https://github.com/StarScream902/experiments.git"
}

resource "helm_release" "cpu-load-app" {
  depends_on = [ module.pull_git_repo ]

  name = "cpu-load-app"
  namespace = "demo"
  create_namespace = true
  chart = ".terraform/modules/pull_git_repo/Python/Flask/cpu-load-app/helm"
  atomic = true

  # values = [
  #   "${file("values.yaml")}"
  # ]

  values = [
    <<YAML
image:
  pullPolicy: Always
  tag: "2023-04"

ingress:
  enabled: true
  className: "alb"
  annotations:
    alb.ingress.kubernetes.io/scheme: "internet-facing"
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
    alb.ingress.kubernetes.io/tags: "Name=demo-External-ALB,Environment=${var.environment.full}"
    alb.ingress.kubernetes.io/target-type: "ip"
    alb.ingress.kubernetes.io/load-balancer-attributes: "deletion_protection.enabled=true,routing.http2.enabled=true"
  hosts:
    - host: example.com
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: cpu-load-app
              port:
                number: 80

resources:
  limits:
    cpu: 700m
    memory: 128Mi
  requests:
    cpu: 500m
    memory: 128Mi

autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80

    YAML
  ]
}
