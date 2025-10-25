terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.52"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

# SSH key (must exist locally)
resource "hcloud_ssh_key" "default" {
  name       = "local-ssh-key"
  public_key = file(var.ssh_public_key)
}

# Server definition
resource "hcloud_server" "vm1" {
  name        = "vm1-${var.environment}"
  server_type = "cx22"
  image       = "ubuntu-24.04"
  location    = "fsn1"
  ssh_keys    = [hcloud_ssh_key.default.id]
}