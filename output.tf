
output "frontend_instance_private_ip" {
  description = "Front Instance private IP"
  value       = aws_instance.frontend.private_ip
}

output "backend_instance_private_ip" {
  description = "Front Instance private IP"
  value       = aws_instance.backend.private_ip
}

