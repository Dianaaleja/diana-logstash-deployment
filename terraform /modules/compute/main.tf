# main.tf for compute module

# ---------------------------------------------------
# Security Group
# ---------------------------------------------------
resource "aws_security_group" "instance_sg" {
  name        = "${var.project_name}-${var.environment}-${var.name}-sg"
  description = "Security group for ${var.name} instance"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.security_rules.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      security_groups = lookup(ingress.value, "security_groups", null) # Optional: allows referencing other SGs
    }
  }

  dynamic "egress" {
    for_each = var.security_rules.egress
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      security_groups = lookup(egress.value, "security_groups", null) # Optional
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.name}-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ---------------------------------------------------
# EC2 Instance
# ---------------------------------------------------
resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  key_name      = var.key_pair_name # Assuming a key pair is provided

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.name}"
    Environment = var.environment
    Project     = var.project_name
  }
}