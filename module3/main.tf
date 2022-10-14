terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}


resource "aws_security_group" "module3-1" {
  name        = "allow-ssh-and-rdp"
  description = "Allow all ssh and rdp from anyware"


  ingress {
    description = "icmp"
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["98.47.170.87/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["98.47.170.87/32"]

  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["98.47.170.87/32"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "module3-1" {
  key_name   = "module-3-1"
  public_key = file(var.ssh_key)
}

resource "aws_instance" "module3-1" {
  ami                         = "ami-081aaface2871d0d0"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.module3-1.name]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.module3-1.key_name

  user_data = <<EOF
#!/bin/bash
sudo yum update -y
EOF

  tags = {
    Name = "test"
  }
}
