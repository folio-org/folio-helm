terraform {
  backend "local" {
    path = "./tfstates/terraform.tfstate"
  }  
}
