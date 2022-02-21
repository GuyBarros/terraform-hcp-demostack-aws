
resource "hcp_consul_cluster" "hcp_demostack" {
  hvn_id          = hcp_hvn.demostack.hvn_id
  cluster_id      = "${var.namespace}-consul"
  tier            = var.hcp_consul_cluster_tier
  size            = var.hcp_consul_cluster_size
  datacenter      = var.region
  public_endpoint = true
}

provider "consul" {
  address    = hcp_consul_cluster.hcp_demostack.consul_public_endpoint_url
  datacenter = hcp_consul_cluster.hcp_demostack.datacenter
  token      = hcp_consul_cluster.hcp_demostack.consul_root_token_secret_id
}

resource "consul_acl_policy" "agent" {
  name        = "agent"
  datacenters = [hcp_consul_cluster.hcp_demostack.datacenter]
  rules       = <<-RULE
   agent_prefix "" {
  policy = "write"
}

node_prefix "" {
  policy = "write"
}

service "nomad" {
  policy = "write"
}

service_prefix "" {
  policy = "write"
}

acl = "write"

operator = "write"
    RULE
}

resource "consul_acl_policy" "anon" {
  name        = "anon"
  datacenters = [hcp_consul_cluster.hcp_demostack.datacenter]
  rules       = <<-RULE
    node_prefix "" {
      policy = "read"
    }
    service_prefix "" {
      policy = "read"
    }
    key_prefix "" {
      policy = "read"
    }

    RULE
}

resource "consul_acl_token_policy_attachment" "anon-readonly-policy-attachment" {
    token_id = "00000000-0000-0000-0000-000000000002"
    policy   = consul_acl_policy.anon.name
}

resource "consul_acl_token" "agent-token" {
  depends_on  = [hcp_consul_cluster.hcp_demostack, hcp_vault_cluster.hcp_demostack]
  count       = var.workers
  description = "TF created agent token"
  policies    = [consul_acl_policy.agent.name]
  local       = true
}

data "consul_acl_token_secret_id" "token" {
  count       = var.workers
  accessor_id = element(consul_acl_token.agent-token.*.id, count.index)
}

resource "random_pet" "animal" {
  depends_on = [hcp_consul_cluster.hcp_demostack, hcp_vault_cluster.hcp_demostack]
  length     = 1
  prefix     = hcp_consul_cluster.hcp_demostack.consul_root_token_secret_id
  separator  = "-"
}


resource "consul_service" "vault" {
  depends_on = [hcp_consul_cluster.hcp_demostack, hcp_vault_cluster.hcp_demostack]
  name       = "vault"
  node       = consul_node.vault.name
  port       = 8200
  tags       = ["hcp", "vault"]
  check {
    check_id                          = "vault_health_check"
    name                              = "hcp vault health check"
    status                            = "passing"
    http                              = "${hcp_vault_cluster.hcp_demostack.vault_private_endpoint_url}/v1/sys/health"
    method                            = "GET"
    interval                          = "15s"
    timeout                           = "10s"
    deregister_critical_service_after = "30s"

  }
}


resource "consul_node" "vault" {
  depends_on = [hcp_consul_cluster.hcp_demostack, hcp_vault_cluster.hcp_demostack]
  name       = "compute-vault"
  # address = hcp_vault_cluster.hcp_demostack.vault_public_endpoint_url
  address = replace(hcp_vault_cluster.hcp_demostack.vault_private_endpoint_url, ":8200", "")
}
resource "hcp_consul_cluster_root_token" "root" {
  cluster_id = "${var.namespace}-consul"
}
