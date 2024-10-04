provider "aws" {
  region="ap-south-1"
}

resource "aws_instance" {
  iam=""
  instance_type="t2.micro"
  tags={
        Name="ec2-terra"
        }
}
