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

resource "aws_key_pair" "module4-key-pair" {
  key_name   = "module-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC40CLwBsChecKwWWWaEsgf2fx26Dvor+gTeLABFzkSlk2560IwtsQ0iUQ8jjv96o0KgFcfMVkM0yzwzeCsat+6YIvUHfesI6oIJ8iYk2vae7qICv+4bcN3mIoWpzTDIAUm3RJCsP25FUumbtTifGhCsQuGfvVzfSgQhv2SSflw2KFlp7cZ+GM9aG9yYlE48iMWrfkSPTNk+T9y0y+ZNjX49dBYSIH8qaGKzSj+CfwiHIYdI31dG54GRXhdkvDUNoYve/jP28iCNro2x2JMeFe+KKJAyYblTGJwwuXghxN1RTPFfSQ4PmP5F6npv0B536gOHRrYs1X5ddr4tIHGbVp/sIp3saGnhrrAfL7mLAnKTkROLgxeXOrVbu/ld3rb7vVvD5UmBK/7QXIyp3xdjZmJY0s/318U3dYK7bHPBb7U4FNW4iAzHChvmcxdHMk49xB466o+4hEIXhWMU2bsx12RjifEyAsifbVWS/g1q9myVYkBHvX70quaqXVkiAp51Uc= efim@efim-laptop"
}

resource "aws_instance" "module5-instance" {
  ami                         = "ami-081aaface2871d0d0"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.sg-docker.name]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.module4-key-pair.key_name
  availability_zone           = aws_subnet.docker-subnet.availability_zone
  user_data                   = filebase64("user_data.sh")

  tags = {
    Name = "test"
  }
}
