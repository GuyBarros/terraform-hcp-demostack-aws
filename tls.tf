

# Root private key
resource "tls_private_key" "root" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

# Root certificate
resource "tls_self_signed_cert" "root" {
    private_key_pem = tls_private_key.root.private_key_pem
  
  subject {
    common_name  = var.namespace
    organization = "HashiCorp Demostack"
  }

  validity_period_hours = " 720 # 30 days

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "crl_signing",
  ]

  is_ca_certificate = true
}

# Client private key

resource "tls_private_key" "workers" {
  count       = var.workers
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

# Client signing request
resource "tls_cert_request" "workers" {
  count           = var.workers
  private_key_pem = element(tls_private_key.workers.*.private_key_pem, count.index)

  subject {
    common_name  = "${var.namespace}-worker-${count.index}.node.consul"
    organization = "HashiCorp Demostack"
  }

  dns_names = [
    # Consul
    "${var.namespace}-worker-${count.index}.node.consul",
    "${var.namespace}-worker-${count.index}.node.${var.region}.consul",

    # Nomad
    "nomad.service.consul",
    "nomad.service.${var.region}.consul",

    "client.global.nomad",
    "server.global.nomad",

    # Common
    "localhost",
    "127.0.0.1",
    "*.${var.namespace}.${data.aws_route53_zone.fdqn.name}",
  ]

  /*
  ip_addresses = [
    "127.0.0.1",
  ]
  */
  // ip_addresses = ["${aws_eip.server_ips.*.public_ip }"]
}

# Client certificate

resource "tls_locally_signed_cert" "workers" {
  count            = var.workers
  cert_request_pem = element(tls_cert_request.workers.*.cert_request_pem, count.index)

  private_key_pem = tls_private_key.root.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root.cert_pem

  validity_period_hours = 720 # 30 days

  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "server_auth",
  ]
}


// ALB certs
resource "aws_acm_certificate" "cert" {
  domain_name       = "*.${var.namespace}.${data.aws_route53_zone.fdqn.name}"
  validation_method = "DNS"
}


resource "aws_route53_record" "validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id

}



/*
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn
   validation_record_fqdns = [
    aws_route53_record.validation_record.fqdn,
  ]
}
*/

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_record : record.fqdn]
}
