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

output "Primary_Boundary" {
  value = module.primarycluster.boundary_ui
}


output "Primary_workers_Nodes" {
  value = module.primarycluster.workers
}

output "HCP_Consul_Public_address" {
  value = module.primarycluster.consul_address
}

output "HCP_Vault_Public_address" {
  value = module.primarycluster.vault_address
}
output "HCP_Consul_token" {
  value = module.primarycluster.consul_token
  sensitive = true
}

output "HCP_Vault_token" {
  value = module.primarycluster.vault_token
  sensitive = true
}