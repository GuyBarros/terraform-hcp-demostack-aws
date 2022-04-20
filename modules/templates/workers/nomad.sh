#!/usr/bin/env bash
echo "==> Nomad (client)"

echo "--> Installing CNI plugin"
sudo mkdir -p /opt/cni/bin/
wget -O cni.tgz ${cni_plugin_url}
sudo tar -xzf cni.tgz -C /opt/cni/bin/

export AWS_REGION=$(curl -fsq http://169.254.169.254/latest/meta-data/placement/availability-zone |  sed 's/[a-z]$//')
export AWS_AZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)

echo "--> Writing configuration"
sudo mkdir -p /mnt/nomad
sudo mkdir -p /etc/nomad.d
sudo mkdir -p /opt/nomad/scratch

export VAULT_TOKEN=${VAULT_TOKEN}
export VAULT_ADDR=${VAULT_ADDR}
export VAULT_NAMESPACE=admin
export NOMAD_VAULT_TOKEN="$(vault token create -field=token -policy=superuser -policy=nomad-server -display-name=${node_name} -period=72h)"

echo "--> clean up any default config."
sudo rm  /etc/nomad.d/*

sudo chown ubuntu:ubuntu /opt/nomad/

echo "--> Installing"
sudo tee /etc/nomad.d/config.hcl > /dev/null <<EOF
name         = "${node_name}"
data_dir     = "/mnt/nomad"
enable_debug = true
bind_addr = "0.0.0.0"

datacenter = "$AWS_REGION"
region = "aws"

advertise {
  http = "$(public_ip):4646"
  rpc  = "$(public_ip):4647"
  serf = "$(public_ip):4648"
}
server {
  enabled          = true
  bootstrap_expect = ${nomad_workers}
  encrypt          = "${nomad_gossip_key}"
}
client {
  enabled = true
   options {
    "driver.raw_exec.enable" = "1"
     "docker.privileged.enabled" = "true"
  }
  meta {
    "type" = "worker",
    "name" = "${node_name}"
  }
  host_volume "scratch" {
    path      = "/opt/nomad/scratch"
    read_only = false
  }
}
acl {
  enabled = true
}

tls {
  rpc  = true
  http = true
  ca_file   = "/usr/local/share/ca-certificates/01-me.crt"
  cert_file = "/etc/ssl/certs/me.crt"
  key_file  = "/etc/ssl/certs/me.key"
  verify_server_hostname = false
}
consul {
    server_service_name = "nomad-server"
    client_service_name = "nomad-client"
    auto_advertise = true
    server_auto_join = true
    client_auto_join = true
    ca_file = "/etc/consul.d/ca.pem"
    token = "${hcp_acl_token}"
}
vault {
  enabled          = true
  address          = "${VAULT_ADDR}"
  namespace        = "admin"
  create_from_role = "nomad-cluster"
}
autopilot {
    last_contact_threshold = "200ms"
    max_trailing_logs = 250
    server_stabilization_time = "10s"
    enable_redundancy_zones = false
    disable_upgrade_migration = false
    enable_custom_upgrades = false
}
telemetry {
  publish_allocation_metrics = true
  publish_node_metrics = true
  prometheus_metrics = true
}
EOF

echo "--> Writing profile"
sudo tee /etc/profile.d/nomad.sh > /dev/null <<"EOF"
alias noamd="nomad"
alias nomas="nomad"
alias nomda="nomad"
export NOMAD_ADDR="https://${node_name}.node.consul:4646"
export NOMAD_CACERT="/usr/local/share/ca-certificates/01-me.crt"
export NOMAD_CLIENT_CERT="/etc/ssl/certs/me.crt"
export NOMAD_CLIENT_KEY="/etc/ssl/certs/me.key"
EOF
source /etc/profile.d/nomad.sh

echo "--> Generating upstart configuration"
sudo tee /etc/systemd/system/nomad.service > /dev/null <<EOF
[Unit]
Description=Nomad
Documentation=https://www.nomadproject.io/docs/
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/nomad agent -config="/etc/nomad.d"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
Restart=on-failure
LimitNOFILE=65536
#Enterprise License
Environment=NOMAD_LICENSE=${nomadlicense}
Environment=VAULT_TOKEN=$(vault token create -field=token -policy=superuser -policy=nomad-server -display-name=${node_name} -period=72h)
[Install]
WantedBy=multi-user.target
EOF

echo "--> Starting nomad"
sudo systemctl enable nomad
sudo systemctl start nomad

echo "==> Run Nomad is Done!"