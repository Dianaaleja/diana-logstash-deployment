# variables.tf for networking module

variable "region" {
  description = "The AWS region to deploy resources."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet."
  type        = string
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet."
  type        = string
}

variable "project_name" {
  description = "A unique name for the project, used for resource naming and tagging."
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, prod, staging)."
  type        = string
  default     = "dev"
}