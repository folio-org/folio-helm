output "rancher_server_url" {
  value = module.rancher_common.rancher_url
}

output "rancher_server_token" {
  value = module.rancher_common.rancher_token
}

output "rancher_cluster_id" {
  value = module.rancher_common.cluster_id
}

output "rancher_node_ip" {
  value = aws_instance.rancher_server.public_ip
}

output "workload_node_ip" {
  value = aws_instance.folio_node.*.public_ip
}
