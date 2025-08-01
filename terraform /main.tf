# main.tf for the root Terraform configuration

# ---------------------------------------------------
# AWS Provider Configuration
# ---------------------------------------------------
provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
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

  name          = "bastion"
  ami_id        = var.ami_id_al2023
  instance_type = "t3.micro"
  subnet_id     = module.networking.public_subnet_id
  vpc_id        = module.networking.vpc_id
  key_pair_name = var.key_pair_name

  security_rules = {
    ingress = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${var.my_public_ip}/32"]
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }

  project_name = var.project_name
  environment  = var.environment

  tags = {
    Name        = "bastion"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---------------------------------------------------
# Logstash Instance Module Call
# Provisions an EC2 instance (Logstash) and its security group in the private subnet.
# ---------------------------------------------------
module "logstash" {
  source = "./modules/compute"

  name          = "logstash"
  ami_id        = var.ami_id_al2023
  instance_type = "t3.medium"
  subnet_id     = module.networking.private_subnet_id
  vpc_id        = module.networking.vpc_id
  key_pair_name = var.key_pair_name

  security_rules = {
    ingress = [
      {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        security_groups = [module.bastion.security_group_id]
        cidr_blocks     = []
      },
      {
        from_port       = 5044
        to_port         = 5044
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }

  project_name = var.project_name
  environment  = var.environment

  tags = {
    Name        = "logstash"
    Project     = var.project_name
    Environment = var.environment
  }
}


