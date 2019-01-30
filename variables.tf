variable "pub_key" {
  description = "The location of the public key used for provisioning"
}

variable "pvt_key" {
  description = "The location of the private key used for provisioning"
}

variable "admin_cidrs" {
  description = "The CIDR ranges used by administrators to SSH into droplets. These are added to firewall rules"
  type        = "list"
}

variable "external_volume_id" {
  description = "The Volume ID used to store modules that the athens proxy downloads"
}

variable "external_volume_name" {
  description = "The Volume Name used to store modules that the athens proxy downloads"
}

variable "droplet_region" {
  description = "The region the athens proxy will be deployed to"
  default = "nyc1"
}

variable "droplet_size" {
  description = "The requested memory used for the athens proxy"
  default = "1gb"
}

variable "tag" {
  description = "The Docker tag for Athens that you want to run"
  default = "stable"
}
