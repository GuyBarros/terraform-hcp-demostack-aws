
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

output "XX_boundary_config" {
  value = <<EOF

config_application_name = "${var.namespace}"
config_boundary_address  =   "${hcp_boundary_cluster.hcp_demostack.cluster_url}"
config_boundary_auth_method_id = ""
config_boundary_username       = "admin"
config_boundary_password       = "Welcome1"

config_vault_address    = "${hcp_vault_cluster.hcp_demostack.vault_public_endpoint_url}"
config_vault_token   = "${nonsensitive(hcp_vault_cluster_admin_token.root.token)}"
config_vault_namespace = "boundary"

config_nomad_address = "https://${aws_route53_record.nomad.fqdn}:4646"
config_nomad_token = ""

EOF
}
