variable "aws_region" {
  type        = string
  description = "AWS region"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.aws_region
}

provider "random" {
  version = "~> 2.2.1"
}

 # used for accesing Account ID and ARN
data "aws_caller_identity" "current" {}
