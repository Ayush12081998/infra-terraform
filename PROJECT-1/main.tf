provider "aws" {
  region = "ap-south-1"
  access_key = "Access-KEY"
  secret_key = "secret"
}

resource "aws_instance" "my-first-server" {
  ami           = "ami-02d26659fd82cf299"
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}