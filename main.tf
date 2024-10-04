provider "aws" {
  region="ap-south-1"
}

resource "aws_instance" {
  ami="ami-00f251754ac5da7f0"
  instance_type="t2.micro"
  tags={
        Name="ec2-terra"
        }
}
