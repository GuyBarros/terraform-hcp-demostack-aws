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
