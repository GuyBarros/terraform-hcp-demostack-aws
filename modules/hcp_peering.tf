// Pin the version
/*
terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.4"
    }
  }
}
*/

resource "hcp_hvn" "demostack" {
  hvn_id         = var.hcp_hvn_id
  cloud_provider = "aws"
  region         = "eu-west-2"
  cidr_block     = "172.25.16.0/20"
}


resource "aws_vpc_peering_connection_accepter" "demostack" {
  vpc_peering_connection_id = hcp_aws_network_peering.demostack_peering.provider_peering_id
  auto_accept               = true
    tags = merge(local.common_tags ,{
   Purpose        = "demostack" ,
   Function       = "hcp-peer" 
   Name            = "demostack-hcp-peer" ,
   }
  )

}

// Create a Network peering between the HVN and the AWS VPC
resource "hcp_aws_network_peering" "demostack_peering" {
  hvn_id              = hcp_hvn.demostack.hvn_id
  peer_vpc_id         = aws_vpc.demostack.id
  peer_account_id     = aws_vpc.demostack.owner_id
  peer_vpc_region     = var.region
  peer_vpc_cidr_block = aws_vpc.demostack.cidr_block
  
}
