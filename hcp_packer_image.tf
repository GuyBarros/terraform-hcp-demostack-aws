# Find a suitable AMI to use for this purpose

data "hcp_packer_artifact" "demostack" {
  bucket_name    = var.packer_bucket_name
  platform  = "aws"
  channel_name     = var.packer_channel
  region         = var.region
}