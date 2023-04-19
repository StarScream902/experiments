resource "aws_iam_role" "autoscaler_role" {
  name = "EksClusterAutoscalerRole-${var.eks_cluster_id}"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${var.eks_cluster_oidc_provider_arn}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${replace(var.eks_cluster_oidc_issuer_url, "https://", "")}:aud": "sts.amazonaws.com",
            "${replace(var.eks_cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  }
EOF

  tags = {
    Environment = var.environment.full
  }
}

resource "aws_iam_role_policy" "autoscaler_role_policy" {
  name = "EksClusterAutoscalerPolicy-${var.eks_cluster_id}"
  role = aws_iam_role.autoscaler_role.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Visual0",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Visual1",
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "autoscaling:UpdateAutoScalingGroup"
            ],
            "Resource": "*",
        "Condition": {
                "StringEquals": {
                    "autoscaling:ResourceTag/kubernetes.io/cluster/${var.eks_cluster_id}": ["owned"],
                    "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled": ["true"]
                }
            }
        }
    ]
}
  EOF
}

resource "helm_release" "cluster_autoscaler" {
  name       = "aws-cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version = "9.28.0"
  atomic = true
  wait = true

  values = [
    <<YAML
awsRegion: ${var.aws_region}
cloudProvider: "aws"
rbac:
  create: true
  serviceAccount:
    name: "cluster-autoscaler"
    annotations:
      eks.amazonaws.com/role-arn: ${aws_iam_role.autoscaler_role.arn}
autoDiscovery:
  enabled: "true"
  clusterName: ${var.eks_cluster_id}
    YAML
  ]
}
