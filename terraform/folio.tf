data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

# Create a new rancher2 imported Cluster
resource "rancher2_cluster" "folio-imported" {
  depends_on                    = [data.aws_eks_cluster.cluster]
  name                          = var.cluster_name
  description                   = "Folio rancher2 imported cluster"
  enable_cluster_monitoring     = false
}

data "http" "cattle" {
  url = rancher2_cluster.folio-imported.cluster_registration_token.0.manifest_url
}

locals {
  cattle-list  = compact(split("---", trimspace(data.http.cattle.body)))
}

resource "kubectl_manifest" "cattle" {
  depends_on  = [rancher2_cluster.folio-imported]
  count       = 9
  yaml_body   = local.cattle-list[count.index]
}

# Create a new rancher2 Cluster Sync
resource "rancher2_cluster_sync" "folio-imported" {
  depends_on    = [kubectl_manifest.cattle]
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
