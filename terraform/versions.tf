terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    rancher2 = {
      source = "rancher/rancher2"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.12"
}
