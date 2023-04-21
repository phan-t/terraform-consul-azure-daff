// generic outputs

output "deployment_name" {
  description = "Deployment name, used to prefix resources"
  value       = var.deployment_name
}

output "deployment_id" {
  description = "Deployment identifier"
  value       = local.deployment_id
}

// azure outputs