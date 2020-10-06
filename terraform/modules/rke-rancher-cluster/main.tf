terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = ">= 1.6.0"
    }
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      version = "0.10.4"
      source = "hashicorp/helm"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    rke = {
      source = "rancher/rke"
      version = "1.1.1"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}
