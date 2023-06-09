
variable "host_access_ip" {
  description = "your IP address to allow ssh to work"
  type        = list(string)
  default     = []
}

variable "create_primary_cluster" {
  description = "Set to true if you want to deploy the AWS delegated zone."
  type        = bool
  default     = "true"
}

variable "create_secondary_cluster" {
  description = "Set to true if you want to deploy the AWS delegated zone."
  type        = bool
  default     = "false"
}

variable "create_tertiary_cluster" {
  description = "Set to true if you want to deploy the AWS delegated zone."
  type        = bool
  default     = "false"
}



variable "namespace" {
  description = <<EOH
this is the differantiates different demostack deployment on the same subscription, everycluster should have a different value
EOH
  default     = "primarystack"
}

variable "primary_namespace" {
  description = <<EOH
this is the differantiates different demostack deployment on the same subscription, everycluster should have a different value
EOH

  default = "primarystack"
}

variable "secondary_namespace" {
  description = <<EOH
this is the differantiates different demostack deployment on the same subscription, everycluster should have a different value
EOH

  default = "secondarystack"
}

variable "tertiary_namespace" {
  description = <<EOH
this is the differantiates different demostack deployment on the same subscription, everycluster should have a different value
EOH

  default = "tertiarystack"
}

variable "primary_region" {
  description = "The region to create resources."
  default     = "eu-west-2"
}

variable "secondary_region" {
  description = "The region to create resources."
  default     = "eu-west-2"
}

variable "tertiary_region" {
  description = "The region to create resources."
  default     = "ap-northeast-1"
}


variable "workers" {
  description = "The number of nomad worker vms to create."
  default     = "3"
}

variable "fabio_url" {
  description = "The url download fabio."
  default     = "https://github.com/fabiolb/fabio/releases/download/v1.6.0/fabio-1.6.0-linux_amd64"
}

variable "cni_plugin_url" {
  description = "The url to download the CNI plugin for nomad."
  default     = "https://github.com/containernetworking/plugins/releases/download/v0.8.2/cni-plugins-linux-amd64-v0.8.2.tgz"
}

variable "owner" {
  description = "IAM user responsible for lifecycle of cloud resources used for training"
}

variable "se-region" {
  description = "Mandatory tags for the SE organization"
}

variable "created-by" {
  description = "Tag used to identify resources created programmatically by Terraform"
  default     = "Terraform"
}
variable "purpose" {
  description = "purpose to be added to the default tags"
  default     = "HCP SE demostack"
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
  description = "The CIDR blocks to create the workstations in."
  default     = ""
}


variable "public_key" {
  description = "The contents of the SSH public key to use for connecting to the cluster."
}

variable "enterprise" {
  description = "do you want to use the enterprise version of the binaries"
  default     = false
}

variable "nomadlicense" {
  description = "Enterprise License for Nomad"
  default     = ""
}

variable "instance_type_worker" {
  description = "The type(size) of data worker (consul, nomad, etc)."
  default     = "t3.medium"
}


variable "run_nomad_jobs" {
  default = "0"
}



variable "hcp_consul_cluster_id" {
  description = "the HCP Consul Cluster ID that you  want to use"
  default     = "demostack"
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

variable "hcp_vault_cluster_id" {
  description = "the HCP Consul Cluster ID that you  want to use"
  default     = "demostack"
}

variable "hcp_consul_address" {
  description = "update before destroy"
  default     = ""
}

variable "hcp_consul_datacenter" {
  description = "update before destroy"
  default     = ""
}

variable "hcp_consul_token" {
  description = "update before destroy"
  default     = ""
}

variable "project_id" {
  description = "the project you want to create resources in"
  default     = ""
}
