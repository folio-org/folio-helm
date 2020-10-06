provider "aws" {
  version = "~> 3.0"
  region  = var.aws_region
}

provider "random" {
  version = "~> 2.2.1"
}

provider "rancher2" {
  api_url   = module.rke.rancher_url
  token_key = module.rke.rancher_token
}

