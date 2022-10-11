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
  region = "us-east-1"

}

provider "aws" {
  region = "us-west-2"
  alias  = "us-west-2"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "efim-test3"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}
resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    id = "homework"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }
    status = "Enabled"
  }
}

resource "aws_efs_file_system" "efs" {
  creation_token   = "efs-test"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"

  }


  tags = {
    "Name" = "efs-test"
  }

}

locals {
  efs_mount_target_subnets = {
    subnet1 = { availability_zone = "us-east-1a", cidr_block = "10.0.1.0/24" }
    subnet2 = { availability_zone = "us-east-1b", cidr_block = "10.0.2.0/24" }
    subnet3 = { availability_zone = "us-east-1c", cidr_block = "10.0.3.0/24" }
    subnet4 = { availability_zone = "us-east-1d", cidr_block = "10.0.4.0/24" }
  }
}

resource "aws_efs_mount_target" "alpha" {
  for_each       = local.efs_mount_target_subnets
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.alpha[each.key].id    
}

resource "aws_vpc" "efs_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "alpha" {
  vpc_id            = aws_vpc.efs_vpc.id
  for_each          = local.efs_mount_target_subnets
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    "Name" = "${each.key}"
  }

}

resource "aws_ebs_volume" "ebs" {
  provider          = aws.us-west-2
  availability_zone = "us-west-2a"
  size              = 100
  type              = "gp2"

  encrypted = true
  tags = {
    Name = "EBSDemo"
  }
} 

