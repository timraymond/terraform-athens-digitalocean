provider "digitalocean" {
  token = "${var.do_token}"
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

  provisioner "file" {
    source = "scripts/"
    destination = "/usr/local/bin"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /usr/local/bin/install.sh",
      "/usr/local/bin/install.sh"
    ]
  }

  connection {
    type = "ssh"
    user = "root"
    private_key = "${file(var.pvt_key)}"
    timeout = "2m"
  }
}
