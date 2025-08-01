# variables.tf for the root Terraform configuration

variable "aws_region" {
  description = "The AWS region for the deployment."
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "A unique name for the project, used for resource naming and tagging."
  type        = string
  default     = "logstash-deployment"
}

variable "environment" {
  description = "The environment name (e.g., dev, prod, staging)."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the main VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "ami_id_al2023" {
  description = "ID de AMI de Amazon Linux 2023 para la región eu-central-1."
  type        = string
  default     = "ami-000263cdbfb72aa30" # REPLACE WITH A VALID AL2023 AMI ID FOR YOUR REGION
}

variable "key_pair_name" {
  description = "The name of an existing EC2 Key Pair to use for SSH access."
  type        = string
  # IMPORTANT: You must have this key pair already created in your AWS account.
  default     = "layered-dev"
}

variable "my_public_ip" {
  description = "Your current public IP address to allow SSH access to the Bastion Host."
  type        = string
  # IMPORTANT: You can find your public IP by searching "what is my ip" on Google,
  # or using a service like: curl ifconfig.me
  # Example: "192.0.2.100"
}
variable "aws_profile" {
  description = "The AWS profile to use for authentication."
  type        = string
  default     = "default"
}
