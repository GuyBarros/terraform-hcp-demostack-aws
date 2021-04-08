
resource "hcp_vault_cluster" "demostack" {
  cluster_id = var.hcp_vault_cluster_id
  hvn_id     = hcp_hvn.demostack.hvn_id
  public_endpoint = true
}

resource "hcp_vault_cluster_admin_token" "root" {
  cluster_id = hcp_vault_cluster.demostack.cluster_id
}
