provider "consul" {
  address    = "https://hcp-demostack-consul-cluster.consul.90c8be71-8b86-4967-b3d0-913bf19b96a0.aws.hashicorp.cloud"
  datacenter =  "eu-west-2"
  token      =  "1b10e168-7306-90ec-5b7c-5714f992038d"

}


resource "consul_service" "vault-test" {
  name    = "vault-test"
  node    = consul_node.vault-test.name
  port    = 8200
  tags    = ["hcp","vault"]
  check {
    check_id                          = "vault_health_check"
    name                              = "hcp vault health check"
    status                            = "passing"
    http                              = "https://demostack.vault.90c8be71-8b86-4967-b3d0-913bf19b96a0.aws.hashicorp.cloud:8200/v1/sys/health"
    method                            = "GET"
    interval                          = "15s"
    timeout                           = "10s"
    deregister_critical_service_after = "30s"

  }
}

resource "consul_node" "vault-test" {
  name    = "hcp-vault-test"
  address = "https://demostack.vault.90c8be71-8b86-4967-b3d0-913bf19b96a0.aws.hashicorp.cloud"
  # address = substr(hcp_vault_cluster.demostack.vault_public_endpoint_url, 5, length)
  # address = replace(hcp_vault_cluster.demostack.vault_public_endpoint_url, ":8200", "")

}