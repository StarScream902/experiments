locals {
  alb_set = {
    "fullnameOverride" : "aws-load-balancer-controller",
    "clusterName" : var.eks_cluster_id,
    "vpcId" : var.vpc_id,
    "region": var.aws_region,
    "serviceAccount.create": "true"
    "serviceAccount.name": "aws-load-balancer-controller"
    "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn": module.iam_assumable_role_alb.iam_role_arn
    "defaultTags.Environment": var.environment.full
  }
}

resource "aws_iam_policy" "alb_ingress" {
  name = title(format("%s-alb-ingress-policy", var.eks_cluster_id))

  policy = file("${path.module}/resources/aws-load-balancer/iam-policy.json")
}

module "iam_assumable_role_alb" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.1"
  create_role                   = true
  role_name                     = title(format("%s-alb-ingress-role", var.eks_cluster_id))
  provider_url                  = replace(var.eks_cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [ aws_iam_policy.alb_ingress.arn ]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:alb-ingress-controller",
    "system:serviceaccount:kube-system:aws-load-balancer-controller",
  ]

  tags = {
    Environment = var.environment.full
  }
}

resource "helm_release" "alb_ingress_controller" {
  name = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart = "aws-load-balancer-controller"
  namespace = "kube-system"
  version = "1.4.7"
  atomic = true
  dependency_update = true
  wait = true

  dynamic "set" {
    for_each = local.alb_set

    content {
      name = set.key
      value = set.value
    }
  }
}
