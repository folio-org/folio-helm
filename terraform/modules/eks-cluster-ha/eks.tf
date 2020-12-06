######################
# variables
######################
variable "domain" {
  description = "External-dns Domain filter"
  type        = string
}
variable "name_prefix" {
  type        = string
  description = "Name prefix for cluster users"
}
variable "cluster_name" {
  type        = string
  description = "Cluster name"
}
variable "vpc_id" {
  type        = string
  description = "VPC id."
}
variable "private_subnets" {
  type        = list(string)
  description = "List of private subnets."
}
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

# get all available AZs in our region
data "aws_availability_zones" "available_azs" {
  state = "available"
}

# render Admin & Developer users list with the structure required by EKS module
locals {
  admin_user_map_users = [
    for admin_user in var.admin_users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${admin_user}"
      username = admin_user
      groups   = ["system:masters"]
    }
  ]
  developer_user_map_users = [
    for developer_user in var.developer_users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${developer_user}"
      username = developer_user
      groups   = ["${var.name_prefix}-developers"]
    }
  ]
  worker_groups_launch_template = [
    {
      override_instance_types = var.asg_instance_types
      asg_desired_capacity    = var.autoscaling_minimum_size_by_az * length(data.aws_availability_zones.available_azs.zone_ids)
      asg_min_size            = var.autoscaling_minimum_size_by_az * length(data.aws_availability_zones.available_azs.zone_ids)
      asg_max_size            = var.autoscaling_maximum_size_by_az * length(data.aws_availability_zones.available_azs.zone_ids)
      # use Spot EC2 instances to save some money and scale more
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      public_ip               = false
    },
  ]

  oidc_url = replace(module.eks-cluster.cluster_oidc_issuer_url, "https://", "")

}

# create EKS cluster
module "eks-cluster" {
  source              = "github.com/terraform-aws-modules/terraform-aws-eks"
  cluster_name        = var.cluster_name
  cluster_version     = "1.18"
  write_kubeconfig    = true
  config_output_path  = "${path.root}/outputs/"

  subnets = var.private_subnets
  vpc_id  = var.vpc_id

  worker_groups_launch_template = local.worker_groups_launch_template

  # map developer & admin ARNs as kubernetes Users
  map_users = concat(local.admin_user_map_users, local.developer_user_map_users)

  # Create OIDC provider
  enable_irsa = true

  # Not recommended
  workers_additional_policies = [aws_iam_policy.alb-worker-policy.arn, aws_iam_policy.external-dns.arn]
}

# get EKS cluster info to configure Kubernetes and Helm providers
data "aws_eks_cluster" "cluster" {
  name = module.eks-cluster.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-cluster.cluster_id
}

# get EKS authentication for being able to manage k8s objects from terraform
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}

# deploy spot termination handler
resource "helm_release" "spot_termination_handler" {
  depends_on = [module.eks-cluster]
  name       = "aws-node-termination-handler"
  chart      = "aws-node-termination-handler"
  repository = "https://aws.github.io/eks-charts"
  version    = "0.9.1"
  namespace  = "kube-system"
}

# add spot fleet Autoscaling policy
resource "aws_autoscaling_policy" "eks_autoscaling_policy" {
  count = length(local.worker_groups_launch_template)

  name                   = "${module.eks-cluster.workers_asg_names[count.index]}-autoscaling-policy"
  autoscaling_group_name = module.eks-cluster.workers_asg_names[count.index]
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.autoscaling_average_cpu
  }
}

# add External DNS
resource "helm_release" "external-dns" {
  name       = "external-dns"
  namespace  = "kube-system"
  wait       = true
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  set {
    name  = "rbac.create"
    value = true
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "rbac.pspEnabled"
    value = false
  }
  set {
    name  = "name"
    value = "${var.cluster_name}-external-dns"
  }
  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "logLevel"
    value = "debug"
  }
  set {
    name  = "domainFilters[0]"
    value = var.domain
  }
  set {
    name  = "aws.region"
    value = var.aws_region
  }
}

#resource "helm_release" "ingress" {
#  depends_on = [module.eks-cluster]
#  name       = "ingress"
#  namespace  = "kube-system"
#  chart      = "aws-alb-ingress-controller"
#  repository = "http://storage.googleapis.com/kubernetes-charts-incubator"
#  set {
#    name  = "autoDiscoverAwsRegion"
#    value = "true"
#  }
#  set {
#    name  = "autoDiscoverAwsVpcID"
#    value = "true"
#  }
#  set {
#    name  = "clusterName"
#    value = var.cluster_name
#  }
#}