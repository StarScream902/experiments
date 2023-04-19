variable "environment" {
  type = object({
    short = string
    full = string
  })
}

variable "eks_cluster_id" {
  type = string
}
