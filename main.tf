provider "digitalocean" {
  token = "${var.do_token}"
}

variable "do_token" {
  description = "The token used to access DigitalOcean services"
}

variable "pub_key" {
  description = "The location of the public key used for provisioning"
}

variable "pvt_key" {
  description = "The location of the private key used for provisioning"
}

output "public_droplet_ip" {
  value = "${digitalocean_droplet.athens-proxy.ipv4_address}"
}

resource "digitalocean_ssh_key" "athens" {
  name = "Athens SSH Key"
  public_key = "${file(var.pub_key)}"
}

resource "digitalocean_droplet" "athens-proxy" {
  image = "ubuntu-18-04-x64"
  name = "athens-proxy"
  region = "nyc1"
  size = "1gb"
  private_networking = true
  ssh_keys = [
    "${digitalocean_ssh_key.athens.id}"
  ]

  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable\"",
      "apt update",
      "apt install -y docker-ce",

      "mkdir /var/lib/athens",
      "docker run -d -v /var/lib/athens:/var/lib/athens -e ATHENS_DISK_STORAGE_ROOT=/var/lib/athens -e ATHENS_STORAGE_TYPE=disk --name athens-proxy --restart always -p 3000:3000 gomods/proxy:latest"
    ]

    connection {
      type = "ssh"
      user = "root"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
    }
  }
}
