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

output "vault_ui" {
  value = "https://${aws_route53_record.vault.fqdn}:8200"
}

output "nomad_ui" {
  value = "https://${aws_route53_record.nomad.fqdn}:4646"
}

output "boundary_ui" {
 value = "http://${aws_route53_record.boundary.fqdn}:9200"
 # value = "troubleshooting"
}

output "hcp_consul_root_token"{
  value = hcp_consul_cluster.hcp_demostack.consul_root_token_secret_id
}


/*
output "eks_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}
output "eks_ca" {
 // value = aws_eks_cluster.eks.endpoint
  value = aws_eks_cluster.eks.certificate_authority.0.data
}
*/