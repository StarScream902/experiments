terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.4.1"
    }
    # kubectl = {
    #   source  = "gavinbunney/kubectl"
    #   version = ">=1.14.0"
    # }
  }

  required_version = ">= 1.1.6"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
  }
}
# provider "kubectl" {
#   host = local.kubeconfig.host
#   token = local.kubeconfig.token
#   cluster_ca_certificate = base64decode(local.kubeconfig.cluster_ca_certificate)
#   load_config_file       = false
# }
