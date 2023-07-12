resource "hcp_boundary_cluster" "hcp_demostack" {
  cluster_id = "${var.namespace}-boundary"
  username   = "admin"
  password   = "Welcome1"
  tier = var.hcp_boundary_cluster_tier
}