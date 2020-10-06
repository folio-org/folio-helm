output "kubeconfig_filename" {
  description = "The filename of the generated kubectl config."
  value       = module.eks-cluster.kubeconfig_filename
}
