variable "hcloud_token" {
  type        = string
  description = "Hetzner API token"
}

variable "ssh_public_key" {
  type        = string
  description = "Path to your local SSH public key"
}

variable "environment" {
  type        = string
  description = "The environment name (solvista-dev, solvista-prod)"
}