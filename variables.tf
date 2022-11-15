
locals {
  # Common tags to be assigned to all resources
  common_tags = {
    name           = var.namespace
    owner          = var.owner
    created-by     = var.created-by
    sleep-at-night = var.sleep-at-night
    ttl            = var.TTL
    se-region      = var.region
    terraform      = true
    purpose        = "SE Demostack"
  }
}


variable "region" {
  description = "The region to create resources."
  default     = "eu-west-2"
}

variable "namespace" {
  description = <<EOH
this is the differantiates different demostack deployment on the same subscription, everycluster should have a different value
EOH
  default     = "connectdemo"
}


variable "workers" {
  description = "The number of nomad worker vms to create."
  default     = "3"
}


variable "fabio_url" {
  description = "The url download fabio."
  default     = "https://github.com/fabiolb/fabio/releases/download/v1.5.7/fabio-1.5.7-go1.9.2-linux_amd64"
}


variable "cni_plugin_url" {
  description = "The url to download teh CNI plugin for nomad."
  default     = "https://github.com/containernetworking/plugins/releases/download/v0.8.2/cni-plugins-linux-amd64-v0.8.2.tgz"
}

variable "owner" {
  description = "Email address of the user responsible for lifecycle of cloud resources used for training."
}

variable "hashi_region" {
  description = "the region the owner belongs in.  e.g. NA-WEST-ENT, EU-CENTRAL"
  default     = "EMEA"
}

variable "created-by" {
  description = "Tag used to identify resources created programmatically by Terraform"
  default     = "Terraform"
}

variable "sleep-at-night" {
  description = "Tag used by reaper to identify resources that can be shutdown at night"
  default     = true
}

variable "TTL" {
  description = "Hours after which resource expires, used by reaper. Do not use any unit. -1 is infinite."
  default     = "240"
}

variable "vpc_cidr_block" {
  description = "The top-level CIDR block for the VPC."
  default     = "10.1.0.0/16"
}

variable "cidr_blocks" {
  description = "The CIDR blocks to create the workstations in."
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "zone_id" {
  description = "The Zone ID which Holds the FQDN to which the subdomains will be added "
}

variable "public_key" {
  description = "The contents of the SSH public key to use for connecting to the cluster."
}

variable "enterprise" {
  description = "do you want to use the enterprise version of Nomad"
  default     = false
}

variable "nomadlicense" {
  description = "Enterprise License for Nomad"
  default     = ""
}


variable "instance_type_worker" {
  description = "The type(size) of data workers (consul, nomad, etc)."
  default     = "t3.medium"
}

variable "run_nomad_jobs" {
  default = "0"
}

variable "host_access_ip" {
  description = "list of CIDR blocks allowed to connect via SSH on port 22 e.g. your public ip "
  type        = list(string)
}

variable "hcp_consul_cluster_tier" {
  description = "the HCP Consul Cluster tier that you  want to use"
  default     = "plus"
  validation {
    condition     = contains(["development", "standard", "plus"], var.hcp_consul_cluster_tier)
    error_message = "Valid values for var: hcp_consul_cluster_tier are (development, standard, plus)."
  } 
}

variable "hcp_consul_cluster_size" {
  description = "the HCP Consul Cluster tier that you  want to use"
  default     = "small"
  validation {
    condition     = contains(["x_small", "small", "medium", "large"], var.hcp_consul_cluster_size)
    error_message = "Valid values for var: hcp_consul_cluster_size are (development, standard, plus)."
  } 
}

variable "hcp_vault_cluster_tier" {
  description = "the HCP Consul Cluster tier that you  want to use"
  default     = "plus_small"
  validation {
    condition     = contains(["dev", "starter_small", "standard_small", "standard_medium", "standard_large", "plus_small", "plus_medium", "plus_large"], var.hcp_vault_cluster_tier)
    error_message = "Valid values for var: hcp_vault_cluster_tier are (dev, starter_small, standard_small, standard_medium, standard_large, plus_small, plus_medium, plus_large)."
  } 
}

variable "hcp_hvn_id" {
  description = "the Hashicorp Virtual Network id you want use"
}

variable "postgres_username" {
  description = "Username that will be used to create the AWS Postgres instance"
  default     = "postgresql"
}

variable "postgres_password" {
  description = "Password that will be used to create the AWS Postgres instance"
  default     = "YourPwdShouldBeLongAndSecure!"
}

  variable "postgres_db_name" {
  description = "Db_name that will be used to create the AWS Postgres instance"
  default     = "postgress"
}

variable "mysql_username" {
  description = "Username that will be used to create the AWS mysql instance"
  default     = "mysql"
}

variable "mysql_password" {
  description = "Password that will be used to create the AWS mysql instance"
  default     = "YourPwdShouldBeLongAndSecure!"
}

  variable "mysql_db_name" {
  description = "Db_name that will be used to create the AWS mysql instance"
  default     = "mydb"
}