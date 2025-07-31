# outputs.tf for the root Terraform configuration

output "vpc_id" {
  description = "The ID of the main VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "The ID of the public subnet."
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "The ID of the private subnet."
  value       = module.networking.private_subnet_id
}

output "bastion_public_ip" {
  description = "The public IP address of the Bastion Host."
  value       = module.bastion.instance_public_ip
}

output "logstash_private_ip" {
  description = "The private IP address of the Logstash instance."
  value       = module.logstash.instance_private_ip
}

output "bastion_security_group_id" {
  description = "The Security Group ID of the Bastion Host."
  value       = module.bastion.security_group_id
}

output "logstash_security_group_id" {
  description = "The Security Group ID of the Logstash instance."
  value       = module.logstash.security_group_id
}