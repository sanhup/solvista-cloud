# Public IPv4 address of the VM
output "vm_ip" {
  description = "The public IPv4 address of the Hetzner VM"
  value       = hcloud_server.vm1.ipv4_address
}

# Server ID (useful if you need to reference this VM later)
output "vm_id" {
  description = "The Hetzner server ID"
  value       = hcloud_server.vm1.id
}

# Server name (optional, for clarity)
output "vm_name" {
  description = "The name of the Hetzner server"
  value       = hcloud_server.vm1.name
}

# Optional: if you have an SSH key resource and want to output its fingerprint
output "ssh_key_fingerprint" {
  description = "Fingerprint of the SSH key added to the VM"
  value       = hcloud_ssh_key.default.fingerprint
}