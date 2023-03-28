resource "gitlab_project" "this" {
  count = var.gitlab_project_create ? 1 : 0

  namespace_id     = var.gitlab_project.namespace_id
  name             = var.gitlab_project.name
  description      = var.gitlab_project.description
  visibility_level = var.gitlab_project.visibility_level
}
