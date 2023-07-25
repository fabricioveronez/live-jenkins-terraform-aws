terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.56.0"
    }
  }
  backend "s3" {
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "labs_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "labs_sub" {
  vpc_id            = aws_vpc.labs_vpc.id
  cidr_block        = var.sub_net_cidr_block
  availability_zone = var.sub_net_availability_zone

  tags = {
    Name = var.sub_net_name
  }
}

resource "aws_internet_gateway" "labs_gw" {
  tags = {
    Name = var.internet_gateway_name
  }
}

resource "aws_internet_gateway_attachment" "ig_vpc" {
  internet_gateway_id = aws_internet_gateway.labs_gw.id
  vpc_id              = aws_vpc.labs_vpc.id
}

resource "aws_route_table_association" "association" {
  subnet_id      = aws_subnet.labs_sub.id
  route_table_id = aws_route_table.labs_rt.id
}

resource "aws_route_table" "labs_rt" {
  vpc_id = aws_vpc.labs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.labs_gw.id
  }

  tags = {
    Name = var.route_table_name
  }
}

data "aws_key_pair" "deployer" {
  key_name = var.key_pair_name
}

resource "aws_instance" "lab_ec2" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  key_name                    = data.aws_key_pair.deployer.key_name
  subnet_id                   = aws_subnet.labs_sub.id
  associate_public_ip_address = true
  vpc_security_group_ids              = [aws_security_group.allow_all.id]

  tags = {
    Name = "lab-ec2"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Permitir o trafego de tudo"
  vpc_id      = aws_vpc.labs_vpc.id

  tags = {
    Name = "allow_all"
  }
}

resource "aws_security_group_rule" "allow_all_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.allow_all.id
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.allow_all.id
}

output "public_ip" {
  value = aws_instance.lab_ec2.public_ip
}
