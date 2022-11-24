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


output "waypoint_ui" {
  value = "https://${aws_route53_record.waypoint.fqdn}:9702"
}

output "waypoint" {
  value = "${aws_route53_record.waypoint.fqdn}:9701"
}
output "boundary_address" {
  value = hcp_boundary_cluster.hcp_demostack.cluster_url
}
output "consul_address" {
  value = hcp_consul_cluster.hcp_demostack.consul_public_endpoint_url
}
output "vault_address" {
  value = hcp_vault_cluster.hcp_demostack.vault_public_endpoint_url
}

output "vault_token" {
  value = nonsensitive(hcp_vault_cluster_admin_token.root.token)
}

output "consul_token" {
  value = nonsensitive(hcp_consul_cluster_root_token.root.secret_id)
}
