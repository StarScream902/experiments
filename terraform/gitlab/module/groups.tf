resource "gitlab_group" "this" {
  count       = var.gitlab_group_create ? 1 : 0

  name        = var.gitlab_group.name
  path        = var.gitlab_group.path
  description = var.gitlab_group.description
  parent_id   = var.gitlab_group.parent_id
}
