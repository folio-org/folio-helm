terraform {
  required_providers {
    rancher2 = {
      source  = "terraform-providers/rancher2"
      version = ">= 1.6.0"
    }
  }
  backend "local" {
    path = "./tfstates/rancher_project.tfstate"
  }
}

# Create Rancher Project
resource "rancher2_project" "project" {
  provider   = rancher2
  name       = var.rancher_project_name
  cluster_id = var.rancher_cluster_id
  container_resource_limit {
    limits_memory   = "900Mi"
    requests_cpu    = "50m"
    requests_memory = "400Mi"
  }
  enable_project_monitoring = true
  project_monitoring_input {
    answers = {
      "exporter-kubelets.https"                   = true
      "exporter-node.enabled"                     = true
      "exporter-node.ports.metrics.port"          = 9796
      "exporter-node.resources.limits.cpu"        = "200m"
      "exporter-node.resources.limits.memory"     = "200Mi"
      "grafana.persistence.enabled"               = false
      "grafana.persistence.size"                  = "5Gi"
      "grafana.persistence.storageClass"          = "default"
      "operator.resources.limits.memory"          = "500Mi"
      "prometheus.persistence.enabled"            = false
      "prometheus.persistence.size"               = "5Gi"
      "prometheus.persistence.storageClass"       = "default"
      "prometheus.persistent.useReleaseName"      = true
      "prometheus.resources.core.limits.cpu"      = "200m",
      "prometheus.resources.core.limits.memory"   = "500Mi"
      "prometheus.resources.core.requests.cpu"    = "200m"
      "prometheus.resources.core.requests.memory" = "500Mi"
      "prometheus.retention"                      = "12h"
    }
  }
}

# Create a new Rancher2 Project Catalog for Bitnami charts
resource "rancher2_catalog" "bitnamicharts" {
  name       = "bitnamicharts"
  url        = "https://charts.bitnami.com/bitnami"
  scope      = "global"
  version    = "helm_v3"
  project_id = rancher2_project.project.id
}

# Create a new Rancher2 Project Catalog for Folio charts
resource "rancher2_catalog" "foliocharts" {
  name       = "foliocharts"
  url        = "https://folio-org.github.io/folio-helm"
  scope      = "project"
  version    = "helm_v3"
  project_id = rancher2_project.project.id
}

# Create a new rancher2 Namespace assigned to cluster project
resource "rancher2_namespace" "project-namespace" {
  name        = var.rancher_project_name
  project_id  = rancher2_project.project.id
  description = "Deafult namespace"
  container_resource_limit {
    limits_memory   = "900Mi"
    requests_cpu    = "50m"
    requests_memory = "400Mi"
  }
}

resource "rancher2_secret" "db-connect-modules" {
  name         = "db-connect-modules"
  project_id   = rancher2_project.project.id
  namespace_id = rancher2_namespace.project-namespace.name
  data = {
    DB_HOST         = base64encode("pg-folio")
    DB_PORT         = base64encode("5432")
    DB_USERNAME     = base64encode("postgres")
    DB_PASSWORD     = base64encode("postgres_password")
    DB_DATABASE     = base64encode("project_modules")
    DB_MAXPOOLSIZE  = base64encode("5")
    DB_CHARSET      = base64encode("UTF-8")
    DB_QUERYTIMEOUT = base64encode("60000")
    KAFKA_HOST      = base64encode("kafka")
    KAFKA_PORT      = base64encode("9092")
    OKAPI_URL       = base64encode("http://okapi:9130")
  }
}

resource "rancher2_secret" "project-config" {
  name       = "project-config"
  project_id = rancher2_project.project.id
  data = {
    OKAPI_URL    = base64encode(join(".",[join("-", [var.rancher_project_name, "okapi"]), var.domain]))
    TENANT_ID    = base64encode("diku")
    PROJECT_NAME = base64encode(rancher2_project.project.name)
    PROJECT_ID   = base64encode(element(split(":", rancher2_project.project.id), 1))
  }
}

# For edge* modules
resource "rancher2_secret" "edge-props" {
  name         = "ephemeral-properties"
  namespace_id = rancher2_namespace.project-namespace.name
  description  = "For edge* modules"
  project_id   = rancher2_project.project.id
  data = {
    "ephemeral.properties" = filebase64("${path.module}/resources/ephemeral.properties")
  }
}

# Rancher2 Project App Kafka
resource "rancher2_app" "kafka" {
  depends_on       = [rancher2_catalog.bitnamicharts]
  catalog_name     = "bitnamicharts"
  name             = "kafka"
  project_id       = rancher2_project.project.id
  template_name    = "kafka"
  target_namespace = rancher2_namespace.project-namespace.name
  force_upgrade    = "true"
  answers = {
    "global.storageClass"                 = "default"
    "metrics.kafka.enabled"               = "false"
    "persistence.enabled"                 = "true"
    "persistence.size"                    = "5Gi"
    "resources.limits.cpu"                = "500m"
    "resources.limits.memory"             = "1Gi"
    "resources.requests.cpu"              = "250m"
    "resources.requests.memory"           = "256Mi"
    "zookeeper.enabled"                   = "true"
    "zookeeper.persistence.size"          = "5Gi"
    "zookeeper.resources.limits.cpu"      = "500m"
    "zookeeper.resources.limits.memory"   = "1Gi"
    "zookeeper.resources.requests.cpu"    = "250m"
    "zookeeper.resources.requests.memory" = "256Mi"
  }
}

# Rancher2 Project App Postgres
resource "rancher2_app" "postgres" {
  depends_on       = [rancher2_catalog.bitnamicharts]
  catalog_name     = "bitnamicharts"
  name             = "postgres"
  project_id       = rancher2_project.project.id
  template_name    = "postgresql"
  target_namespace = rancher2_namespace.project-namespace.name
  answers = {
    "fullnameOverride"                        = "pg-folio"
    "postgresqlDatabase"                      = "project_modules"
    "persistence.enabled"                     = "true"
    "persistence.storageClass"                = "default"
    "persistence.size"                        = "10Gi"
    "postgresqlPassword"                      = "postgres_password"
    "postgresqlUsername"                      = "postgres"
    "resources.limits.cpu"                    = "1000m"
    "resources.limits.memory"                 = "2048Mi"
    "resources.requests.cpu"                  = "1000m"
    "resources.requests.memory"               = "2048Mi"
    "securityContext.fsGroup"                 = "1001"
    "securityContext.runAsUser"               = "1001"
    "volumePermissions.enabled"               = "true"
    "postgresqlConfiguration.sharedBuffers"   = "1024MB"
    "postgresqlConfiguration.maxConnections"  = "1000"
    "postgresqlConfiguration.listenAddresses" = "'*'"
  }
}

# Create a new rancher2 OKAPI App in a default Project namespace
resource "rancher2_app" "okapi" {
  depends_on       = [rancher2_catalog.foliocharts, rancher2_app.postgres]
  catalog_name     = join(":", [element(split(":", rancher2_project.project.id), 1), rancher2_catalog.foliocharts.name])
  name             = "okapi"
  description      = "OKAPI app"
  force_upgrade    = "true"
  project_id       = rancher2_project.project.id
  template_name    = "okapi"
  target_namespace = rancher2_namespace.project-namespace.name
  answers = {
    "postJob.enabled"           = "false"
    "image.repository"          = join("/" ,[var.repository, "okapi"])
    "image.tag"                 = "latest"
    "ingress.enabled"           = "true"
    "ingress.hosts[0].host"     = join(".",[join("-", [var.rancher_project_name, "okapi"]), var.domain])
    "ingress.hosts[0].paths[0]" = "/"
  }
}

# Create a new rancher2 Folio backend modules App in a default Project namespace
resource "rancher2_app" "folio-backend" {
  for_each         = local.modules-map
  depends_on       = [rancher2_secret.db-connect-modules, rancher2_catalog.foliocharts]
  catalog_name     = join(":", [element(split(":", rancher2_project.project.id), 1), rancher2_catalog.foliocharts.name])
  name             = each.key
  description      = "Folio app."
  force_upgrade    = "true"
  project_id       = rancher2_project.project.id
  template_name    = each.key
  target_namespace = rancher2_namespace.project-namespace.name
  answers = {
    "postJob.enabled"           = "false"
    "image.repository"          = join("/" ,[var.repository, each.key])
    "image.tag"                 = each.value
  }
}

# Create a new rancher2 Stripes Bundle App in a default Project namespace
resource "rancher2_app" "folio-frontend" {
  depends_on       = [rancher2_app.folio-backend]
  catalog_name     = join(":", [element(split(":", rancher2_project.project.id), 1), rancher2_catalog.foliocharts.name])
  name             = "platform-complete"
  description      = "Stripes UI"
  project_id       = rancher2_project.project.id
  template_name    = "platform-complete"
  target_namespace = rancher2_namespace.project-namespace.name
  force_upgrade    = "true"
  answers = {
    "resources.limits.cpu"      = "200m"
    "resources.limits.memory"   = "500Mi"
    "postJob.enabled"           = "false"
    "image.tag"                 = "latest"
    "ingress.enabled"           = "true"
    "ingress.annotations"       = ""
    "ingress.hosts[0].host"     = join(".",[join("-", [var.rancher_project_name, "ui"]), var.domain])
    "ingress.hosts[0].paths[0]" = "/"
  }
}

# Create a new rancher2 PgAdmin4 App in a default Project namespace
resource "rancher2_app" "pgadmin4" {
  depends_on       = [rancher2_catalog.foliocharts]
  catalog_name     = join(":", [element(split(":", rancher2_project.project.id), 1), rancher2_catalog.foliocharts.name])
  name             = "pgadmin4"
  description      = "PgAdmin app"
  project_id       = rancher2_project.project.id
  template_name    = "pgadmin4"
  target_namespace = rancher2_namespace.project-namespace.name
  answers = {
    "env.email"                 = "user@folio.org"
    "env.password"              = "SuperSecret"
    "namespace"                 = var.rancher_project_name
    "persistence.storageClass"  = "default"
    "ingress.enabled"           = "true"
    "ingress.annotations"       = ""
    "ingress.hosts[0].host"     = join(".",[join("-", [var.rancher_project_name, "pgadmin"]), var.domain])
    "ingress.hosts[0].paths[0]" = "/"
  }
}

output "project_id" {
  value = rancher2_project.project.id
}
