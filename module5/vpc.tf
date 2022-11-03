resource "aws_vpc" "docker-vpc" {
  
    cidr_block                           = "10.0.0.0/16"
  
    enable_dns_hostnames                 = true
    enable_dns_support                   = true

    tags                                 = {
        "Name" = "project-vpc"
    }

}

resource "aws_internet_gateway" "docker-internet-gateway" {
    vpc_id = aws_vpc.docker-vpc.id
    tags = {
        "Name" = "docker-igw"
    }
}

resource "aws_route_table" "docker-route-table" {
    vpc_id = aws_vpc.docker-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id  = aws_internet_gateway.docker-internet-gateway.id
}

}

resource "aws_subnet" "docker-subnet" {
    vpc_id                  = aws_vpc.docker-vpc.id
    cidr_block              = "10.0.1.0/24"
    availability_zone = "us-west-2a"

}

resource "aws_route_table_association" "docker-route-table-association" {
    subnet_id      = aws_subnet.docker-subnet.id
    route_table_id = aws_route_table.docker-route-table.id
}


locals {
  ports = [22, 80, 443]
}
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "sg-docker" {
  name        = "allow-ssh-and-rdp"
  description = "Allow all ssh and rdp from anyware"


  ingress {
    description = "icmp"
    protocol    = "icmp"
    from_port   = 0
    to_port     = 0
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
