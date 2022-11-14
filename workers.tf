# Nomad gossip encryption key
resource "random_id" "nomad_gossip_key" {
  byte_length = 16
}

# Gzip cloud-init config
data "cloudinit_config" "workers" {
  count = var.workers

  gzip          = true
  base64_encode = true

  #base
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/templates/shared/base.sh",{
      enterprise = var.enterprise
     me_ca     = tls_self_signed_cert.root.cert_pem
    me_cert    = element(tls_locally_signed_cert.workers.*.cert_pem, count.index)
    me_key     = element(tls_private_key.workers.*.private_key_pem, count.index)
    public_key = var.public_key
    })
  }

  #docker
  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/templates/shared/docker.sh")
  }

  #consul
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/templates/workers/consul.sh",{
    node_name  = "${var.namespace}-worker-${count.index}" #"
      # HCP Consul
    hcp_config_file = hcp_consul_cluster.hcp_demostack.consul_config_file
    hcp_ca_file     = hcp_consul_cluster.hcp_demostack.consul_ca_file
    hcp_acl_token   = element(data.consul_acl_token_secret_id.token.*.secret_id, count.index)

    })
  }

  #vault
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/templates/workers/vault.sh",{
    VAULT_ADDR  = hcp_vault_cluster.hcp_demostack.vault_private_endpoint_url
    VAULT_TOKEN = hcp_vault_cluster_admin_token.root.token
    })
  }

    #nomad
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/templates/workers/nomad.sh",{
    node_name  = "${var.namespace}-worker-${count.index}"
    hcp_acl_token   = element(data.consul_acl_token_secret_id.token.*.secret_id, count.index)
    VAULT_ADDR  = hcp_vault_cluster.hcp_demostack.vault_private_endpoint_url
    VAULT_TOKEN = hcp_vault_cluster_admin_token.root.token
    # Nomad
    nomad_workers    = var.workers
    nomad_gossip_key = random_id.nomad_gossip_key.id
    cni_plugin_url   = var.cni_plugin_url
    run_nomad_jobs   = var.run_nomad_jobs
    nomadlicense     = var.nomadlicense
    # Nomad EBS Volumes
    region     = var.region
    index                        = count.index + 1
    count                        = var.workers
    dc1                          = data.aws_availability_zones.available.names[0]
    dc2                          = data.aws_availability_zones.available.names[1]
    dc3                          = data.aws_availability_zones.available.names[2]
    aws_ebs_volume_mysql_id      = aws_ebs_volume.shared.id
    aws_ebs_volume_mongodb_id    = aws_ebs_volume.mongodb.id
    aws_ebs_volume_prometheus_id = aws_ebs_volume.prometheus.id
    aws_ebs_volume_shared_id     = aws_ebs_volume.shared.id
    })
  }

      #EBS
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/templates/workers/ebs_volumes.sh",{
    region     = var.region
    # Nomad EBS Volumes
    index                        = count.index + 1
    count                        = var.workers
    dc1                          = data.aws_availability_zones.available.names[0]
    dc2                          = data.aws_availability_zones.available.names[1]
    dc3                          = data.aws_availability_zones.available.names[2]
    aws_ebs_volume_mysql_id      = aws_ebs_volume.shared.id
    aws_ebs_volume_mongodb_id    = aws_ebs_volume.mongodb.id
    aws_ebs_volume_prometheus_id = aws_ebs_volume.prometheus.id
    aws_ebs_volume_shared_id     = aws_ebs_volume.shared.id
    })
  }
}


resource "aws_instance" "workers" {
  count = var.workers

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type_worker
  key_name      = aws_key_pair.demostack.id

  monitoring = true

  subnet_id              = element(aws_subnet.demostack.*.id, count.index)
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [aws_security_group.demostack.id]


  root_block_device {
    volume_size           = "240"
    delete_on_termination = "true"
  }

  ebs_block_device {
    device_name           = "/dev/xvdd"
    volume_type           = "gp2"
    volume_size           = "240"
    delete_on_termination = "true"
  }

  tags = {
    Purpose  = "demostack",
    Function = "worker",
    Name     = "demostack-worker-${count.index}", #"
  }

  user_data_replace_on_change = true
  user_data_base64 = element(data.cloudinit_config.workers.*.rendered, count.index)
}
