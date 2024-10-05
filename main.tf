provider aws{

region="us-east-1"
}


terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.68.0"
    }
    local={
	source = "hashicorp/local"
     version="2.5.0"
	}
    tls={
	source = "hashicorp/tls"
	version="4.0.5"
	}
  }
  
}



resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "terraform-vpc"
  }
}


resource "aws_subnet" "one" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
   availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-terraform"
  }
}


resource "aws_internet_gateway" "two" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terra-igw"
  }
}


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

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.one.id
  route_table_id = aws_route_table.three.id
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}


resource "aws_instance" "two"{
ami="ami-0fff1b9a61dec8a5f"
key_name = aws_key_pair.deployer.key_name
instance_type="t2.micro"
#vpc_security_group_ids = [aws_default_security_group.default.id]
subnet_id=aws_subnet.one.id
associate_public_ip_address = true
tags={
Name="terra-ec2"
}
}
terraform {
  backend "s3" {
    bucket = "mybucket-chakri-1"
    key    = "pord/terraform.tfstate"
    region = "us-east-1"
  }
}

