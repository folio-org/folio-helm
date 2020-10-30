# Folio Terraform module for Rancher server

Terraform module which installs stable version of Folio app. to Kubernetes cluster managed by Rancher.

## Prepare Rancher and cluster

Please use (this link)[https://rancher.com/docs/rancher/v2.x/en/installation/other-installation-methods/single-node-docker/] to install Rancher.

## Requirements to Kubernetes Cluster

Minimal cluster requirements: 12 vCPU, 32 Gb memory

## Prepare access keys

1. Getting Rancher user API Token and keys
    * Go to Rancher management console
    * Drop down menu under username (Upper Right Corner)
        1. Select `API & Keys`
        2. Click `Add Key`
        3. Add description and click `Create`
        4. Copy URL Endpoint, Token, Access Key, Secret key

## Terraform versions

Terraform 0.12

## Usage

```hcl
module "rancher" {
  source                  = "github.com/folio-org/folio-helm/terraform/modules/folio-rancher"
  domain                  = "my.domain.local"
  rancher_project_name    = "demo"
  rancher_cluster_id      = "c-xxxxx"
  rancher_server_url      = "<rancher_url>"
  rancher_server_token    = "<rancher_token>"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| domain | Domain to apply ingress rules for UI, Okapi, Pgadmin | string | `""` | yes |
| rancher_project_name | Project | string | `"demo"` | yes |
| rancher_cluster_id | Existing cluster in Rancher. Typically name is `c-xxxxxx` | string | `""` | yes |
| rancher_server_url | Rancher server URL. It is recommended to use `https` protocol | string | `""` | yes |
| rancher_server_token | Generated token of admin user | string | `""` | yes |

## Ingress

You should apply some Ingress rules to communicate with running Rancher apllication.
Please change Ingress load balancer rules to manage your domain and and subdomain according to your environment.
