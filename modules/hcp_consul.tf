
resource "hcp_consul_cluster" "hcp_demostack" {
  hvn_id     = data.hcp_hvn.guystack.hvn_id
  cluster_id = "hcp-demostack-consul-cluster"
  tier       = "development"
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
  description = "manually created agent token "
  policies = [consul_acl_policy.agent.name]
  local = true
}
