terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "paultrig"

    workspaces {
      name = "paultrig"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.39.0"
    }
  }
}


locals {
  project_name = "MyServer"
}