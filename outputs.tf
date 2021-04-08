////////////////////// Main //////////////////////////


// Primary

output "Primary_Nomad" {
  value = module.primarycluster.nomad_ui
}

output "Primary_Vault" {
  value = module.primarycluster.vault_ui
}

output "Primary_Fabio" {
  value = module.primarycluster.fabio_lb
}

output "Primary_Traefik" {
  value = module.primarycluster.traefik_lb
}

output "Primary_Boundary" {
  value = module.primarycluster.boundary_ui
}


output "Primary_workers_Nodes" {
  value = module.primarycluster.workers
}

output "Primary_hcp_consul_root_token" {
  value = module.primarycluster.hcp_consul_root_token
}

output "Primary_hcp_vault_root_token" {
  value = module.primarycluster.hcp_vault_root_token
}
