
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
  check {
    check_id                          = "vault_health_check"
    name                              = "hcp vault health check"
    status                            = "passing"
    http                              = "${hcp_vault_cluster.demostack.vault_private_endpoint_url}/v1/sys/health"
    method                            = "GET"
    interval                          = "15s"
    timeout                           = "10s"
    deregister_critical_service_after = "30s"

  }
}

resource "consul_node" "vault" {
  depends_on = [
    hcp_vault_cluster.demostack
  ]
  name    = "compute-vault"
  address = replace(hcp_vault_cluster.demostack.vault_private_endpoint_url, ":8200", "")
}
