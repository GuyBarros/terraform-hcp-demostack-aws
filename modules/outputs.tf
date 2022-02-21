////////////////////// Module //////////////////////////



output "workers" {
  value = aws_route53_record.workers.*.fqdn
}

output "traefik_lb" {
  value = "http://${aws_route53_record.traefik.fqdn}:8080"
}

output "fabio_lb" {
  value = "http://${aws_route53_record.fabio.fqdn}:9999"
}


output "nomad_ui" {
  value = "https://${aws_route53_record.nomad.fqdn}:4646"
}

output "boundary_ui" {
  value = "http://${aws_route53_record.boundary.fqdn}:9200"
  # value = "troubleshooting"
}

output "consul_address" {
  value = hcp_consul_cluster.hcp_demostack.consul_public_endpoint_url
  # value = "troubleshooting"
}
output "vault_address" {
  value = hcp_vault_cluster.hcp_demostack.vault_public_endpoint_url
  # value = "troubleshooting"
}
output "consul_token" {
  value = hcp_consul_cluster_root_token.root.secret_id
}
output "vault_token" {
  value = hcp_vault_cluster_admin_token.root.token
}