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

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"

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
  availability_zone           = aws_default_subnet.default_az1.availability_zone


  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = self.public_ip
    private_key = local.private_key

  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y amazon-efs-utils",

    ]
  }
  tags = {
    Name = "test"
  }

  depends_on = [
    aws_efs_mount_target.alpha
  ]
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-west-2a"

  tags = {
    Name = "Default subnet for us-west-2a"
  }
}

resource "aws_efs_file_system" "efs" {
  creation_token   = "efs-test"
  performance_mode = "generalPurpose"
  encrypted        = true
  throughput_mode  = "bursting"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"

  }
}

resource "aws_efs_mount_target" "alpha" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_default_subnet.default_az1.id
  security_groups = [
    aws_security_group.module3-1.id
  ]
}

resource "aws_ebs_volume" "ebs" {
  availability_zone = "us-west-2a"
  size              = 100
  type              = "gp2"

  encrypted = true
  tags = {
    Name = "EBSDemo"
  }
} 
