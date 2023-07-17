# Find a suitable AMI to use for this purpose
data "hcp_packer_iteration" "demostack" {
  bucket_name = var.packer_bucket_name
  channel     = var.packer_channel
}

data "hcp_packer_image" "demostack" {
  bucket_name    = var.packer_bucket_name
  cloud_provider = "aws"
  iteration_id   = data.hcp_packer_iteration.demostack.ulid
  region         = var.region
}