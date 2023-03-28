terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "3.18.0"
    }
  }
  required_version = ">= 1.1.6"
}

provider "gitlab" {
  token = var.gitlab_token
}
