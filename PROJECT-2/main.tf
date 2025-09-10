provider "aws" {
  region = "ap-south-1"
  access_key = "*****"
  secret_key = "*****"
}

resource "aws_vpc" "proj-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name="dev"
  }
}

# print output on console when resource is created
output "vpc_cidr_block" {
  value = aws_vpc.proj-vpc.arn
}

resource "aws_internet_gateway" "proj-internet-gw" {
  vpc_id = aws_vpc.proj-vpc.id

  tags = {
    Name = "dev"
  }
}

resource "aws_route_table" "proj-route-table" {
  vpc_id = aws_vpc.proj-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proj-internet-gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.proj-internet-gw.id
  }

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "proj-subnet" {
  vpc_id     = aws_vpc.proj-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "dev"
  }
}

resource "aws_route_table_association" "proj-route-table-association1" {
  subnet_id      = aws_subnet.proj-subnet.id
  route_table_id = aws_route_table.proj-route-table.id
}



resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.proj-vpc.id

  tags = {
    Name = "allow_web_traffic_dev"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_traffic_https_ipv4" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_traffic_http_ipv4" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_traffic_ssh_ipv4" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_network_interface" "proj-nic" {
  subnet_id       = aws_subnet.proj-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web_traffic.id]
}

resource "aws_eip" "proj-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.proj-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.proj-internet-gw ]
}

variable "var_az" {
  description = "availability zone"
  # default="ap-south-1a"
  type = string
}

resource "aws_instance" "web-server-instance" {
  ami           = "ami-02d26659fd82cf299"
  instance_type = "t3.micro"
  availability_zone = var.var_az
  key_name = "main-key"
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.proj-nic.id
  }
  
  user_data = <<EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y apache2
              sudo bash -c 'echo your server > /var/www/html/index.html'
              EOF
tags = {
    Name = "dev-server"
  }
}


# any comment