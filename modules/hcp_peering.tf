resource "hcp_hvn" "demostack" {
  hvn_id         = var.hcp_hvn_id
  cloud_provider = "aws"
  region         = var.region
  cidr_block     = "172.25.16.0/20"
}


// Create a Network peering between the HVN and the AWS VPC
resource "hcp_aws_network_peering" "demostack_peering" {
  peering_id      = "dev"
  hvn_id          = hcp_hvn.demostack.hvn_id
  peer_vpc_id     = aws_vpc.demostack.id
  peer_account_id = aws_vpc.demostack.owner_id
  peer_vpc_region = var.region
  //peer_vpc_cidr_block = aws_vpc.demostack.cidr_block

}


resource "hcp_hvn_route" "main-to-dev" {
  hvn_link         = hcp_hvn.demostack.self_link
  hvn_route_id     = "demostack-to-dev"
  destination_cidr = var.vpc_cidr_block
  target_link      = hcp_aws_network_peering.demostack_peering.self_link
}

resource "aws_vpc_peering_connection_accepter" "demostack" {
  vpc_peering_connection_id = hcp_aws_network_peering.demostack_peering.provider_peering_id
  auto_accept               = true
  tags = merge(local.common_tags, {
    Purpose  = "demostack",
    Function = "hcp-peer"
    Name     = "demostack-hcp-peer",
    }
  )

}
