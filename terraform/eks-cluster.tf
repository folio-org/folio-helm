variable "admin_users" {
  type        = list(string)
  description = "List of Kubernetes admins."
}
variable "developer_users" {
  type        = list(string)
  description = "List of Kubernetes developers."
}
variable "asg_instance_types" {
  type        = list(string)
  description = "List of EC2 instance machine types to be used in EKS."
}
variable "autoscaling_minimum_size_by_az" {
  type        = number
  description = "Minimum number of EC2 instances to autoscale our EKS cluster on each AZ."
}
variable "autoscaling_maximum_size_by_az" {
  type        = number
  description = "Maximum number of EC2 instances to autoscale our EKS cluster on each AZ."
}
variable "autoscaling_average_cpu" {
  type        = number
  description = "Average CPU threshold to autoscale EKS EC2 instances."
}

module "eks" {
    source                                      = "./modules/eks-cluster-ha"

    name_prefix                                 = var.name_prefix
    aws_region                                  = var.aws_region
    cluster_name                                = var.cluster_name
    admin_users                                 = var.admin_users
    developer_users                             = var.developer_users
    asg_instance_types                          = var.asg_instance_types
    autoscaling_minimum_size_by_az              = var.autoscaling_minimum_size_by_az
    autoscaling_maximum_size_by_az              = var.autoscaling_maximum_size_by_az
    autoscaling_average_cpu                     = var.autoscaling_average_cpu
    domain                                      = var.domain
    private_subnets                             = module.vpc.private_subnets
    vpc_id                                      = module.vpc.vpc_id
}
