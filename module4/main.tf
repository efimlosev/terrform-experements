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

locals {
  ports = [22, 80, 443]
}
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
resource "aws_security_group" "sg-elb" {
  name        = "allow-ssh-and-rdp"
  description = "Allow all ssh and rdp from anyware"


  ingress {
    description = "icmp"
    protocol    = "icmp"
    from_port   = 0
    to_port     = 8
    cidr_blocks = ["0.0.0.0/0"]

  }

  dynamic "ingress" {
    for_each = local.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow ${ingress.value} port"

    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_key_pair" "module4-key-pair"{
  key_name   = "module-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC40CLwBsChecKwWWWaEsgf2fx26Dvor+gTeLABFzkSlk2560IwtsQ0iUQ8jjv96o0KgFcfMVkM0yzwzeCsat+6YIvUHfesI6oIJ8iYk2vae7qICv+4bcN3mIoWpzTDIAUm3RJCsP25FUumbtTifGhCsQuGfvVzfSgQhv2SSflw2KFlp7cZ+GM9aG9yYlE48iMWrfkSPTNk+T9y0y+ZNjX49dBYSIH8qaGKzSj+CfwiHIYdI31dG54GRXhdkvDUNoYve/jP28iCNro2x2JMeFe+KKJAyYblTGJwwuXghxN1RTPFfSQ4PmP5F6npv0B536gOHRrYs1X5ddr4tIHGbVp/sIp3saGnhrrAfL7mLAnKTkROLgxeXOrVbu/ld3rb7vVvD5UmBK/7QXIyp3xdjZmJY0s/318U3dYK7bHPBb7U4FNW4iAzHChvmcxdHMk49xB466o+4hEIXhWMU2bsx12RjifEyAsifbVWS/g1q9myVYkBHvX70quaqXVkiAp51Uc= efim@efim-laptop"
}

resource "aws_launch_template" "module4" {
    name_prefix   = "module4"
    image_id      = "ami-0d593311db5abb72b"
    instance_type = "t2.nano"
    key_name      = "module-key"
    user_data     = filebase64("user_data.sh")
    block_device_mappings {
        device_name = "/dev/sda1"
        ebs {
        volume_size = 8
        volume_type = "gp2"
        delete_on_termination = true
        }
    }
    
    network_interfaces {
      security_groups = [aws_security_group.sg-elb.id]

    
    }
    private_dns_name_options {
      hostname_type = "ip-name"
    }

}

resource "aws_default_subnet" "az1" {
  availability_zone = "us-west-2a"
  tags = {
    Name = "Default Subnet"
  }
}

resource "aws_default_subnet" "az2" {
  availability_zone = "us-west-2b"
  tags = {
    Name = "Default Subnet"
  }
}

resource "aws_default_subnet" "az3" {
  availability_zone = "us-west-2c"
  tags = {
    Name = "Default Subnet"
  }
}

resource "aws_lb_target_group" "module4-tg" {
  name = "module4-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_default_vpc.default.id
  target_type = "instance"
}

  
resource "aws_autoscaling_group" "module-4-asg" {
  name = "module-4-asg"
  desired_capacity = 3
  max_size = 4
  min_size = 3
  launch_template {
    id = aws_launch_template.module4.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.module4-tg.arn]
  vpc_zone_identifier = [aws_default_subnet.az1.id, aws_default_subnet.az2.id, aws_default_subnet.az3.id]
}
  
resource "aws_lb" "module4-lb" {
  name               = "module4-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-elb.id]
  subnets            = [aws_default_subnet.az1.id, aws_default_subnet.az2.id, aws_default_subnet.az3.id]
}

/* resource "aws_alb" "alb-module4" {
    name = "alb-module4"
    subnets = ["subnet-0b0e1c9f1b0b0b1a1", "subnet-0b0e1c9f1b0b0b1a1", "subnet-0b0e1c9f1b0b0b1a1"]
    security_groups = [aws_security_group.sg-elb.id]
    tags = {
        Name = "alb-module4"
    }
} */
