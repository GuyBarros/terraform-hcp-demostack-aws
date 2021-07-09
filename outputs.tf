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
