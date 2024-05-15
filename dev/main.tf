// Configure the provider
provider "aws" {
  region = var.primary_region
  default_tags {
    tags = {
      Name      = var.namespace
      owner     = var.owner
      se-region = var.se-region
      terraform = true
      purpose   = var.purpose
      ttl       = var.TTL
    }
  }
}

provider "hcp" {
  
}



module "primarycluster" {
   source  = "app.terraform.io/emea-se-playground-2019/demostack-aws/hcp"
  # source = "github.com/GuyBarros/terraform-hcp-demostack-aws"
  owner                   = var.owner
  region                  = var.primary_region
  namespace               = var.primary_namespace
  public_key              = var.public_key
  workers                 = var.workers
  nomadlicense            = var.nomadlicense
  enterprise              = var.enterprise
  fabio_url               = var.fabio_url
  cni_plugin_url          = var.cni_plugin_url
  created-by              = var.created-by
  sleep-at-night          = var.sleep-at-night
  TTL                     = var.TTL
  vpc_cidr_block          = var.vpc_cidr_block
  cidr_blocks             = var.cidr_blocks
  instance_type_worker    = var.instance_type_worker
  zone_id                 = var.zone_id
  run_nomad_jobs          = var.run_nomad_jobs
  host_access_ip          = var.host_access_ip
  hcp_consul_cluster_tier = var.hcp_consul_cluster_tier
  hcp_consul_cluster_size = var.hcp_consul_cluster_size
  hcp_vault_cluster_tier  = var.hcp_vault_cluster_tier
  hcp_hvn_id              = var.hcp_hvn_id

}
