# ─────────────────────────────────────────
# 1. PROVIDER
# ─────────────────────────────────────────
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}


# ─────────────────────────────────────────
# 2. S3 BUCKET
# ─────────────────────────────────────────
resource "aws_s3_bucket" "project_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Project     = var.project_name
    Environment = "dev"
  }
}

resource "aws_s3_bucket_public_access_block" "project_bucket_block" {
  bucket = aws_s3_bucket.project_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "project_bucket_versioning" {
  bucket = aws_s3_bucket.project_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}


# ─────────────────────────────────────────
# 3. NETWORKING
# ─────────────────────────────────────────
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 Ubuntu instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-ec2-sg"
    Project = var.project_name
  }
}


# ─────────────────────────────────────────
# 4. UBUNTU 22.04 AMI
# ─────────────────────────────────────────
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical official Ubuntu account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


# ─────────────────────────────────────────
# 5. EC2 INSTANCE — Ubuntu t2.micro
# ─────────────────────────────────────────
resource "aws_instance" "project_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    # Update system
    apt-get update -y
    apt-get upgrade -y

    # Install Python, pip, git
    apt-get install -y python3 python3-pip python3-venv git curl unzip

    # Create virtual environment for dbt
    python3 -m venv /home/ubuntu/dbt_venv

    # Install dbt-snowflake inside venv
    /home/ubuntu/dbt_venv/bin/pip install --upgrade pip
    /home/ubuntu/dbt_venv/bin/pip install dbt-snowflake

    # Add venv to ubuntu user's PATH permanently
    echo 'source /home/ubuntu/dbt_venv/bin/activate' >> /home/ubuntu/.bashrc

    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install

    # Log versions
    echo "Setup complete" >> /tmp/setup.log
    python3 --version >> /tmp/setup.log
    /home/ubuntu/dbt_venv/bin/dbt --version >> /tmp/setup.log
    aws --version >> /tmp/setup.log

    # Fix ownership
    chown -R ubuntu:ubuntu /home/ubuntu/dbt_venv
  EOF

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-ec2"
    Project     = var.project_name
    Environment = "dev"
    OS          = "Ubuntu-22.04"
  }
}