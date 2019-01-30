data "template_file" "init" {
  template = "${file("${path.module}/scripts/install.sh.tmpl")}"

  vars {
    external_volume_name = "${var.external_volume_name}"
  }
}

data "template_file" "systemd-unit" {
  template = "${file("${path.module}/scripts/athens.service")}"

  vars {
    tag = "${var.tag}"
  }
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

resource "digitalocean_volume" "athens" {
  region      = "nyc1"
  name        = "athens-storage"
  size        = 10
  description = "persistent storage for athens"
}

resource "digitalocean_droplet" "athens-proxy" {
  image              = "ubuntu-18-04-x64"
  name               = "athens-proxy"
  region             = "${var.droplet_region}"
  size               = "${var.droplet_size}"
  monitoring         = false
  tags               = ["${digitalocean_tag.athens.id}"]
  volume_ids         = ["${var.external_volume_id}"]

  ssh_keys = [
    "${digitalocean_ssh_key.athens.id}",
  ]

  provisioner "file" {
    destination = "/etc/systemd/system/athens.service"
    content = "${data.template_file.systemd-unit.rendered}"
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.init.rendered}"]
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.pvt_key)}"
    timeout     = "2m"
  }
}
