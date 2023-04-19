variable "environment" {
  type = object({
    short = string
    full = string
  })
}

variable "eks_cluster_id" {
  type = string
}

variable "eks_cluster_oidc_issuer_url" {
  type = string
}

variable "eks_cluster_oidc_provider_arn" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}
