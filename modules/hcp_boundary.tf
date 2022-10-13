resource "hcp_boundary_cluster" "hcp_demostack" {
  cluster_id = "${var.namespace}-boundary"
  username   = "admin"
  password   = "Welcome1"
}