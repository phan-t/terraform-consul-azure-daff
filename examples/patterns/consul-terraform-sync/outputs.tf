// consul outputs

output "consul_server_public_ip" {
  description = "Consul server public ip address"
  value       = module.consul-server.public_ip
}

output "consul_server_private_ip" {
  description = "Consul server private ip address"
  value       = module.consul-server.private_ip
}

output "consul_initial_acl_token" {
  description = "Initial acl token"
  value       = random_uuid.consul-initial-acl-token.result
  sensitive   = true
}

output "consul_terraform_sync_public_ip" {
  description = "Consul-Terraform-Sync public ip address"
  value       = module.consul-terraform-sync.public_ip
}