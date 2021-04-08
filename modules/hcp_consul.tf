
resource "hcp_consul_cluster" "hcp_demostack" {
  hvn_id     = hcp_hvn.demostack.hvn_id
  cluster_id = var.hcp_consul_cluster_id
  tier       = var.hcp_cluster_tier
  datacenter = var.region
  public_endpoint = true
}

provider "consul" {
  address    = "https://${hcp_consul_cluster.hcp_demostack.consul_public_endpoint_url }"
  datacenter =  hcp_consul_cluster.hcp_demostack.datacenter
  token      =  hcp_consul_cluster.hcp_demostack.consul_root_token_secret_id

}

resource "consul_acl_policy" "agent" {
  name  = "agent"
  datacenters = [hcp_consul_cluster.hcp_demostack.datacenter]
  rules = <<-RULE
    node_prefix "" {
      policy = "write"
    }
    RULE
}

resource "consul_acl_token" "agent-token" {
  count = var.workers
  description = "TF created agent token"
  policies = [consul_acl_policy.agent.name]
  local = true
}

data "consul_acl_token_secret_id" "token" {
  count = var.workers
    accessor_id =  element(consul_acl_token.agent-token.*.id, count.index)
}



resource "consul_service" "vault" {
  name    = "vault"
  node    = consul_node.vault.name
  port    = 8200
  tags    = ["hcp","vault"]
}

resource "consul_node" "vault" {
  depends_on = [
    hcp_vault_cluster.demostack
  ]
  name    = "compute-vault"
  # address = hcp_vault_cluster.demostack.vault_public_endpoint_url
  # address = substr(hcp_vault_cluster.demostack.vault_public_endpoint_url, 5, length)
  address = replace(hcp_vault_cluster.demostack.vault_public_endpoint_url, ":8200", "")

}