output "public_droplet_ip" {
  value = "${digitalocean_droplet.athens-proxy.ipv4_address}"
}
