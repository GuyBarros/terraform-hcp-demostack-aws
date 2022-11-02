# Using a single workspace:

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "emea-se-playground-2019"
    workspaces {
      name = "GUY-HCP-Demostack-AWS"
    }
  }
}

// Workspace Data
data "terraform_remote_state" "tls" {
  backend = "remote"
  config = {
    hostname     = "app.terraform.io"
    organization = "emea-se-playground-2019"
    workspaces = {
      name = "tls-root-certificate"
    }
  } //config
}

data "terraform_remote_state" "dns" {
  backend = "remote"

  config = {
    hostname     = "app.terraform.io"
    organization = "emea-se-playground-2019"
    workspaces = {
      name = "Guy-DNS-Zone"
    }
  } //network
}