# Provider configuration
provider "aws" {
  region = "ap-south-1"
}

# EC2 Instance with Tomcat Installation
resource "aws_instance" "two" {
  ami                    = "ami-0e0e417dfa2028266"  # Replace with a valid Amazon Linux AMI ID
  instance_type          = "t2.micro"

  tags = {
    Name = "terra-ec2"
  }
}
