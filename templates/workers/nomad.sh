#!/usr/bin/env bash
echo "==> Nomad (client)"

echo "==> getting the aws metadata token"
export TOKEN=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

echo "==> check token was set"
echo $TOKEN

echo "--> Installing CNI plugin"
sudo mkdir -p /opt/cni/bin/
wget -O cni.tgz ${cni_plugin_url}
sudo tar -xzf cni.tgz -C /opt/cni/bin/

export AWS_REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -fsq http://169.254.169.254/latest/meta-data/placement/availability-zone |  sed 's/[a-z]$//')
export AWS_AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

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
  http = "$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4):4646"
  rpc  = "$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4):4647"
  serf = "$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4):4648"
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

echo "--> Configuring EBS mounts"
sleep 5

sudo mkdir -p /etc/nomad.d/default_jobs/

echo "--> Create EBS CSI plugin job"
{
sudo tee  /etc/nomad.d/default_jobs/plugin-ebs-controller.nomad > /dev/null <<EOF
job "plugin-aws-ebs-controller" {
  datacenters = ["${region}"]

  group "controller" {
    task "plugin" {
      driver = "docker"

      config {
        image = "amazon/aws-ebs-csi-driver:latest"

        args = [
          "controller",
          "--endpoint=unix://csi/csi.sock",
          "--logtostderr",
          "--v=5",
        ]
      }

      csi_plugin {
        id        = "aws-ebs0"
        type      = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
EOF
} || {
    echo "--> CSI plugin job skipped"
}
echo "--> Create Nodes CSI plugin job"
{
sudo tee  /etc/nomad.d/default_jobs/plugin-ebs-nodes.nomad > /dev/null <<EOF
job "plugin-aws-ebs-nodes" {
  datacenters = ["${region}"]

  # you can run node plugins as service jobs as well, but this ensures
  # that all nodes in the DC have a copy.
  type = "system"

  group "nodes" {
    task "plugin" {
      driver = "docker"

      config {
        image = "amazon/aws-ebs-csi-driver:latest"

        args = [
          "node",
          "--endpoint=unix://csi/csi.sock",
          "--logtostderr",
          "--v=5",
        ]

        # node plugins must run as privileged jobs because they
        # mount disks to the host
        privileged = true
      }

      csi_plugin {
        id        = "aws-ebs0"
        type      = "node"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
EOF
} || {
    echo "--> Nodes job skipped"
}

echo "--> Prometheus"
{
sudo tee  /etc/nomad.d/default_jobs/prometheus_ebs_volume.hcl > /dev/null <<EOF
# volume registration
type = "csi"
id = "prometheus"
name = "prometheus"
external_id = "${aws_ebs_volume_prometheus_id}"
plugin_id = "aws-ebs0"
capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}
EOF
} || {
    echo "--> Prometheus failed, probably already done"
}
echo "--> Shared"
{
sudo tee  /etc/nomad.d/default_jobs/shared_ebs_volume.hcl > /dev/null <<EOF
# volume registration
type = "csi"
id = "shared"
name = "shared"
external_id = "${aws_ebs_volume_shared_id}"
plugin_id = "aws-ebs0"
capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}
EOF
} || {
    echo "--> Shared failed, probably already done"
}
echo "--> checking to see if its last worker ${index} == ${count}"
if [ ${index} == ${count} ]
then
echo "--> last worker, lets do this"

sudo apt install -y jq

echo "--> bootstraping Nomad ACLS"
nomad acl bootstrap -json > /tmp/nomad_acls.json
export NOMAD_TOKEN=$(jq -r .SecretID nomad_acls.json)
echo "--> sending bootstrap token to Vault"
vault secrets enable -version=2 -path=nomad kv
sleep 10
vault kv put nomad/bootstrap nomad_acls=@/tmp/nomad_acls.json


nomad run /etc/nomad.d/default_jobs/plugin-ebs-controller.nomad
nomad run /etc/nomad.d/default_jobs/plugin-ebs-nodes.nomad

nomad volume register /etc/nomad.d/default_jobs/prometheus_ebs_volume.hcl
nomad volume register /etc/nomad.d/default_jobs/shared_ebs_volume.hcl

else
echo "--> not the last worker, skip"
fi
echo "==> Configuring EBS mounts is Done!"
