variable "rancher2_token_key" {
  type        = string
  description = "Rancher token key"
}

variable "rancher2_api_url" {
  type        = string
  default     = "https://localhost/v3"
  description = "Rancher API url"
}

variable "rancher2_cluster_id" {
  type        = string
  description = "Rancher default cluster ID"
}

variable "rancher2_project_name" {
  type        = string
  description = "Rancher project name to be created"
}

