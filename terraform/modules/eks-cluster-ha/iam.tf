# create developers Role using RBAC
resource "kubernetes_cluster_role" "iam_roles_developers" {
  metadata {
    name = "${var.name_prefix}-developers"
  }

  rule {
    api_groups = ["*"]
    resources  = ["pods", "pods/log", "deployments", "ingresses", "services"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["*"]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }

  rule {
    api_groups = ["*"]
    resources  = ["pods/portforward"]
    verbs      = ["*"]
  }
}

# bind developer Users with their Role
resource "kubernetes_cluster_role_binding" "iam_roles_developers" {
  metadata {
    name = "${var.name_prefix}-developers"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.name_prefix}-developers"
  }

  dynamic "subject" {
    for_each = toset(var.developer_users)

    content {
      name      = subject.key
      kind      = "User"
      api_group = "rbac.authorization.k8s.io"
    }
  }
}
