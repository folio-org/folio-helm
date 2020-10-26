output "kubeconfig_filename" {
  description = "The filename of the generated kubectl config."
  value       = module.eks-cluster.kubeconfig_filename
}

output "cluster_id" {
  description = "The Clusters's id."
  value       = module.eks-cluster.cluster_id
}
