provider "aws" {
  region = "ap-south-1"
  access_key = "**************"
  secret_key = "**************"
}

resource "aws_instance" "my-first-server" {
  ami           = "ami-02d26659fd82cf299"
  instance_type = "t3.micro"

  tags = {
    Name = "ubuntu-server"
  }
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name="dev"
  }
}

resource "aws_subnet" "my-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "dev"
  }
}

# any comment