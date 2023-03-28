module "gitlab" {
  source = "./module"

  gitlab_token = var.gitlab_token
  gitlab_group_create = true
  gitlab_group        = {
    name        = "test"
    path        = "my-project"
    # path        = ""
    description = "test group description"
    parent_id   = 7806491
  }
}
