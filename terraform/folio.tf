
# Create a new rancher2 imported Cluster
resource "rancher2_cluster" "folio-imported" {
    name                          = var.cluster_name
    description                   = "Folio rancher2 imported cluster"
    enable_cluster_monitoring     = true
}

# register EKS cluster to rancher
resource "null_resource" "register_cluster" {
  provisioner "local-exec" {
    command = "curl --insecure -sfL  ${rancher2_cluster.folio-imported.cluster_registration_token.0.manifest_url} | kubectl --kubeconfig ${module.eks.kubeconfig_filename} apply -f -"
  }
}

# Create a new rancher2 Cluster Sync
resource "rancher2_cluster_sync" "folio-imported" {
  cluster_id    = rancher2_cluster.folio-imported.id
  state_confirm = 3
}

module "rancher" {
    source                  = "./modules/folio-rancher"
    domain                  = var.domain
    rancher_project_name    = var.name_prefix
    rancher_cluster_id      = rancher2_cluster_sync.folio-imported.id
    rancher_server_url      = module.rke.rancher_url
    rancher_server_token    = module.rke.rancher_token
}
