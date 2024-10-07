# Provider configuration
provider "aws" {
  region = "ap-south-1"
}

# Terraform required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.68.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

# VPC Resource
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform-vpc"
  }
}

# Subnet Resource
resource "aws_subnet" "one" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "subnet-terraform"
  }
}

# Internet Gateway Resource
resource "aws_internet_gateway" "two" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terra-igw"
  }
}

# Route Table Resource
resource "aws_route_table" "three" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.two.id
  }

  tags = {
    Name = "terra-route"
  }
}

# Route Table Association with Subnet
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.one.id
  route_table_id = aws_route_table.three.id
}

# Security Group for Tomcat (Allow port 8080)
resource "aws_security_group" "tomcat_sg" {
  name        = "tomcat-sg"
  description = "Allow inbound traffic to Tomcat on port 8080"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows inbound traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tomcat-sg"
  }
}

# EC2 Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

# EC2 Instance with Tomcat Installation
resource "aws_instance" "two" {
  ami                    = "ami-00f251754ac5da7f0"  # Replace with a valid Amazon Linux AMI ID
  key_name               = aws_key_pair.deployer.key_name
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.one.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.tomcat_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y java-1.8.0-openjdk
    sudo yum install -y tomcat
    sudo systemctl start tomcat
    sudo systemctl enable tomcat
  EOF

  tags = {
    Name = "terra-ec2"
  }
}
