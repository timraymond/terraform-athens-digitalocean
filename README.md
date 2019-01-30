Athens Terraform Module for DigitalOcean
========================================

This is a Terraform module that will allow you to spawn an Athens proxy on a DigitalOcean droplet. Athens is run in Docker, and you can adjust the tag that is pulled from Docker hub in the module configuration. See the example module config to see how to use it:

```tf
provider "digitalocean" {
  token = "${var.do_token}"
}

module "athens" {
  source = "../athens"
  tag = "canary" // the tag you'd like to pull

  pub_key = "/path/to/your/ssh/pub/key"
  pvt_key = "/path/to/your/ssh/private/key"

  admin_cidrs = [
    "192.0.2.0/24",
  ]

  droplet_region       = "nyc1"
  external_volume_id   = "${digitalocean_volume.athens.id}"
  external_volume_name = "${digitalocean_volume.athens.name}"
}

resource "digitalocean_volume" "athens" {
  region      = "nyc1"
  name        = "athens"
  size        = 10
  description = "all of athens's persistent storage"
}
```
