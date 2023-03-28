variable "gitlab_token" {
  type = string
  description = "Token for the GitLab server API"
  default = ""
}

variable "gitlab_project_create" {
  description = "Controls if GitLab project resources should be created"
  type        = bool
  default     = false
}

variable "gitlab_project" {
  type = object({
    name             = string
    description      = string
    visibility_level = string
    namespace_id     = string
  })
  default = {
    description = ""
    name = ""
    visibility_level = ""
    namespace_id = ""
  }
}

variable "gitlab_group_create" {
  description = "Controls if GitLab group resources should be created"
  type        = bool
  default     = false
}

variable "gitlab_group" {
  type = object({
    name        = string
    path        = string
    description = string
    parent_id   = number
  })
  default = {
    description = ""
    name        = ""
    path        = ""
    parent_id   = 0
  }
}
