# outputs.tf for compute module

output "instance_id" {
  description = "The ID of the created EC2 instance."
  value       = aws_instance.main.id
}

output "security_group_id" {
  description = "The ID of the created security group."
  value       = aws_security_group.instance_sg.id
}

output "instance_private_ip" {
  description = "The private IP address of the EC2 instance."
  value       = aws_instance.main.private_ip
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance (if applicable)."
  value       = aws_instance.main.public_ip
}
