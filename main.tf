provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_tag" "athens" {
  name = "athens-proxy"
}

resource "digitalocean_ssh_key" "athens" {
  name       = "Athens SSH Key"
  public_key = "${file(var.pub_key)}"
}

resource "digitalocean_firewall" "athens-proxy" {
  name        = "athens-proxy-rules"
  droplet_ids = ["${digitalocean_droplet.athens-proxy.id}"]
  tags        = ["${digitalocean_tag.athens.id}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "3000"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["${var.admin_cidrs}"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "udp"
      port_range            = "53"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "tcp"
      port_range            = "22"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "tcp"
      port_range            = "80"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "tcp"
      port_range            = "443"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

resource "digitalocean_droplet" "athens-proxy" {
  image              = "ubuntu-18-04-x64"
  name               = "athens-proxy"
  region             = "nyc1"
  size               = "1gb"
  private_networking = true
  monitoring         = false
  tags               = ["${digitalocean_tag.athens.id}"]

  ssh_keys = [
    "${digitalocean_ssh_key.athens.id}",
  ]

  provisioner "file" {
    source      = "scripts/install.sh"
    destination = "/usr/local/bin/install.sh"
  }

  provisioner "file" {
    source      = "scripts/athens.service"
    destination = "/etc/systemd/system/athens.service"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /usr/local/bin/install.sh",
      "/usr/local/bin/install.sh",
    ]
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.pvt_key)}"
    timeout     = "2m"
  }
}
