provider "aws" {
  region = "ap-south-1"
  access_key = "AKIAYMTFGKE3WNSTCLPX"
  secret_key = "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"
}

resource "aws_instance" "my-first-server" {
  ami           = "ami-02d26659fd82cf299"
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}