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

# create External DNS Role
resource "kubernetes_cluster_role" "external-dns" {
  metadata {
    name = "external-dns"
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "podes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["networking.istio.io"]
    resources  = ["gateways"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
  api_groups = [""]
  resources  = ["nodes"]
  verbs      = ["list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "external-dns" {
  metadata {
    name = "external-dns"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external-dns.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.external-dns.metadata.0.name
    namespace = kubernetes_service_account.external-dns.metadata.0.namespace
  }
}

resource "kubernetes_service_account" "external-dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external-dns.arn
    }
  }
  automount_service_account_token = true
}

resource "aws_iam_role" "external-dns" {
  name  = "${module.eks-cluster.cluster_id}-external-dns"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_url}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.oidc_url}:sub": "system:serviceaccount:kube-system:external-dns"
        }
      }
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "external-dns" {
  name_prefix = "${module.eks-cluster.cluster_id}-external-dns"
  role        = aws_iam_role.external-dns.name
  policy      = file("${path.module}/files/external-dns-iam-policy.json")
}


# get official iam policy for aws alb ingress controller
data "http" "alb-worker-policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  request_headers = {
    Accept = "application/json"
  }
}

resource "aws_iam_policy" "alb-worker-policy" {
  name = "${module.eks-cluster.cluster_id}-alb-worker-policy"
  policy = file("${path.module}/files/alb-ingress-iam-policy.json")
}

resource "aws_iam_policy" "external-dns" {
  name = "${module.eks-cluster.cluster_id}-external-dns"
  policy = file("${path.module}/files/external-dns-iam-policy.json")
}

# Helm RBAC
resource "kubernetes_service_account" "helm" {
  metadata {
    name      = "helm"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "helm" {
  metadata {
    name = "helm"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.helm.metadata[0].name
    namespace = "kube-system"
  }
}

