////////////////////// Main //////////////////////////


// Primary

output "Primary_Nomad" {
  value = module.primarycluster.nomad_ui
}

output "Primary_Fabio" {
  value = module.primarycluster.fabio_lb
}

output "Primary_Traefik" {
  value = module.primarycluster.traefik_lb
}

output "Primary_workers_Nodes" {
  value = module.primarycluster.workers
}

output "HCP_Consul_Public_address" {
  value = module.primarycluster.consul_address
}

output "HCP_Consul_Token" {
  value = module.primarycluster.consul_token
}

output "HCP_Vault_Public_address" {
  value = module.primarycluster.vault_address
}
output "HCP_Vault_Token" {
  value = module.primarycluster.vault_token
}
output "HCP_Boundary_Public_address" {
  value = module.primarycluster.boundary_address
}

output "waypoint_ui" {
  value = module.primarycluster.waypoint_ui
}

output "waypoint" {
  value = module.primarycluster.waypoint
}

output "XX_boundary_config" {
  value = <<EOF

config_boundary_address  =   "${module.primarycluster.boundary_address}"
config_boundary_auth_method_id = ""
config_boundary_username       = "admin"
config_boundary_password       = "Welcome1"

config_vault_address    = "${module.primarycluster.vault_address}"
config_vault_token   = "${module.primarycluster.vault_token}"
config_vault_namespace = "boundary"

EOF
}
