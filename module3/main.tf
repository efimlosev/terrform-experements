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
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "module3-1" {
  name        = "allow-ssh-and-rdp"
  description = "Allow all ssh and rdp from anyware"


  ingress {
    description = "icmp"
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]

  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]

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

locals {
  private_key = file(trimsuffix(var.ssh_key, ".pub"))
}

resource "aws_instance" "module3-1" {
  ami                         = "ami-081aaface2871d0d0"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.module3-1.name]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.module3-1.key_name


  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = self.public_ip
    private_key = local.private_key

  }
  provisioner "remote-exec" {
    inline = ["sudo yum update -y","echo -e '${var.password}\n ${var.password}' | sudo passwd ${var.ssh_user}","shutdown -r 1"]
  }
  tags = {
    Name = "test"
  }
}
