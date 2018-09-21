variable "do_token" {
  description = "The token used to access DigitalOcean services"
}

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
