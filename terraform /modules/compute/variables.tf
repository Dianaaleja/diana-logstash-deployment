# variables.tf for compute module

variable "name" {
  description = "A unique name for the instance, used in resource naming."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to launch."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance into."
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created."
  type        = string
}

variable "key_pair_name" {
  description = "The name of the EC2 Key Pair to associate with the instance."
  type        = string
}

variable "security_rules" {
  description = "A map defining ingress and egress rules for the security group."
  type = object({
    ingress = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = list(string)
      security_groups = optional(list(string))
    }))
    egress = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = list(string)
      security_groups = optional(list(string))
    }))
  })
  default = {
    ingress = []
    egress  = [{
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }]
  }
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

# Variable nueva para las etiquetas
variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}