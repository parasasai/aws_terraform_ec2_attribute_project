terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Local variables for consistent naming patterns
locals {
  name_prefix = "sai_DevOps-${var.environment}"
  common_tags = {
    Owner       = "sai_DevOps"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 1. Virtual Private Cloud
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

# 2. Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet"
  })
}

# 3. Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# 4. Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

# 5. Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 6. Security Group
resource "aws_security_group" "app_sg" {
  name        = "${local.name_prefix}-sg"
  description = "Allow inbound traffic on specific port"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Application access port"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg"
  })
}

# 7. Data Lookup for AWS Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-202*-x86_64"]
  }
}

# 8. EC2 Instance
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]


# User Data wraps the external file template inside an Apache deployment script
  user_data = <<-EOF
              #!/bin/bash
              # Install and activate Apache
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              
              # Write the template file contents directly to the web server path
              cat <<'HTML' > /var/www/html/index.html
              ${file("${path.module}/templates/school_landing.html")}
              HTML
              EOF


  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2"
  })
}



# 9. S3 Storage Bucket
resource "aws_s3_bucket" "storage" {
  # Bucket names must be globally unique; appending a random string prevents conflicts
  bucket_prefix = "sai-devops-${var.environment}-bucket-"

  tags = local.common_tags
}
