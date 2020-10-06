variable "domain" {
  type    = string
}

variable "rancher_project_name" {
  type        = string
  default     = "demo"
  description = "Rancher project name to be created"
}

variable "rancher_cluster_id" {
  type        = string
  description = "Rancher existing cluster"
}

variable "rancher_server_url" {
  type        = string
  description = "Rancher URL"
}

variable "rancher_server_token" {
  type        = string
  description = "Rancher token key"
}

variable "repository" {
  type        = string
  default     = "folioorg"
  description = "DockerHub repository. Could be 'folioorg' or 'folioci'"
}

variable "ref_environment" {
  type        = string
  default     = "https://folio-goldenrod.dev.folio.org"
  description = "Reference environment need to be created"
}
