variable "domain" {
  type    = string
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "rancher_password" {
  type        = string
  description = "Password to set for Rancher root user"
}

module "rke" {
#    depends_on                  = [module.vpc]
    source  = "./modules/rke-rancher-cluster"
    
    domain                      = var.domain
    vpc_id                      = module.vpc.vpc_id
    aws_elb_subnet_ids          = module.vpc.public_subnets
    rancher2_master_subnet_ids  = module.vpc.public_subnets
    rancher2_worker_subnet_ids  = module.vpc.public_subnets
    name                        = var.name_prefix
    rancher_password            = var.rancher_password
    aws_region                  = var.aws_region
    master_node_count           = 1
    worker_node_count           = 1
    creds_output_path           = "${path.root}/outputs"
}
