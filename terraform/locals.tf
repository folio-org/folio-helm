data "terraform_remote_state" "aws" {
  backend = "local"
  config = {
    path = "./tfstates/rancher_aws.tfstate"
  }
}

provider "rancher2" {
  api_url   = data.terraform_remote_state.aws.outputs.rancher_server_url
  token_key = data.terraform_remote_state.aws.outputs.rancher_server_token
}

locals {
  rancher2_cluster_id   = data.terraform_remote_state.aws.outputs.rancher_cluster_id
}


