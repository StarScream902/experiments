remote_state {
  backend = "s3"
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket          = "example-infra-terraform-f2j4mc8n8w12"
    key             = "terragrunt/${path_relative_to_include()}/terraform.tfstate"
    region          = "us-east-1"
    encrypt         = true
    dynamodb_table  = "example-infra-terraform-lock"
    profile         = "private"
  }
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
  profile = "private"
}
EOF
}
