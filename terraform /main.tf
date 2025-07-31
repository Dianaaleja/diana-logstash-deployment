# main.tf for the root Terraform configuration

# ---------------------------------------------------
# AWS Provider Configuration
# ---------------------------------------------------
provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------
# Networking Module Call
# Provisions VPC, subnets, Internet Gateway, NAT Gateway, and route tables.
# ---------------------------------------------------
module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  region             = var.aws_region
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# ---------------------------------------------------
# Bastion Host Module Call
# Provisions an EC2 instance (Bastion) and its security group in the public subnet.
# ---------------------------------------------------
module "bastion" {
  source = "./modules/compute"

  name          = "bastion" # A descriptive name for this instance
  ami_id        = var.ami_id_al2023 # AL2023 AMI ID (defined in root variables.tf)
  instance_type = "t3.micro"
  subnet_id     = module.networking.public_subnet_id # Place Bastion in public subnet
  vpc_id        = module.networking.vpc_id
  key_pair_name = var.key_pair_name # SSH Key Pair for access

  # Define security rules for the bastion
  # Note: 'security_rules' is an object with 'ingress' and 'egress' lists
  security_rules = {
    ingress = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        # IMPORTANT: Replace var.my_public_ip with your actual public IP address
        # or a specific CIDR range for EC2 Instance Connect access.
        # For a real setup, consider using AWS Systems Manager Session Manager for SSH without direct IP exposure.
        cidr_blocks = ["${var.my_public_ip}/32"] # Allow SSH from your public IP
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1" # Allow all outbound traffic
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }

  project_name = var.project_name
  environment  = var.environment
}

# ---------------------------------------------------
# Logstash Instance Module Call
# Provisions an EC2 instance (Logstash) and its security group in the private subnet.
# ---------------------------------------------------
module "logstash" {
  source = "./modules/compute"

  name          = "logstash" # A descriptive name for this instance
  ami_id        = var.ami_id_al2023 # AL2023 AMI ID (defined in root variables.tf)
  instance_type = "t3.medium"
  subnet_id     = module.networking.private_subnet_id # Place Logstash in private subnet
  vpc_id        = module.networking.vpc_id
  key_pair_name = var.key_pair_name # SSH Key Pair for access

  # Define security rules for Logstash
  security_rules = {
    ingress = [
      {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        security_groups = [module.bastion.security_group_id] # Allow SSH only from the Bastion Host SG
        cidr_blocks     = [] # No direct CIDR blocks for SSH
      },
      {
        from_port   = 5044 # Standard Beats port
        to_port     = 5044
        protocol    = "tcp"
        # IMPORTANT: Replace with CIDR blocks of your application servers
        # or specific security group IDs if your apps are in the same VPC.
        cidr_blocks = ["0.0.0.0/0"] # Placeholder: Restrict to actual app server IPs/SGs
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "tcp" # Or specific port for Elasticsearch
        # IMPORTANT: Replace with the CIDR block or IP of your Elasticsearch cluster
        cidr_blocks = ["0.0.0.0/0"] # Placeholder: Restrict to actual Elasticsearch endpoint
      },
      {
        from_port   = 443 # Allow HTTPS outbound for updates/package downloads
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }

  project_name = var.project_name
  environment  = var.environment
}
