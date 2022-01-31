
resource "hcp_vault_cluster" "hcp_demostack" {
  cluster_id      = "${var.namespace}-vault"
  hvn_id          = hcp_hvn.demostack.hvn_id
  public_endpoint = true
  tier            = "standard_small"
}

resource "hcp_vault_cluster_admin_token" "root" {
  cluster_id = hcp_vault_cluster.hcp_demostack.cluster_id
}
