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
