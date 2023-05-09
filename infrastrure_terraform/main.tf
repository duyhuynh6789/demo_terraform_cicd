# Define
provider "aws" {
  region     = "us-east-1"
}

# Create a vpc
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = var.vpc_instance_tenancy

  tags = {
    Name = "${var.stack_name} | ${var.vpc_tags_name}"
  }
}

# Create an internet gateway and attachment an internet gateway into vpc
resource "aws_internet_gateway" "igw" {
  # Attachment an internet gateway into vpc
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.stack_name} | ${var.igw_tags_name}"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.stack_name} | ${var.vpc_tags_name} | ${var.public_subnet_1_name}"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.stack_name} | ${var.vpc_tags_name} | ${var.public_subnet_2_name}"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.stack_name} | ${var.vpc_tags_name} | ${var.public_route_table_name}"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table_association" "public_subnet_1_public_table" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
  depends_on     = [aws_route_table.public_route_table, aws_subnet.public_subnet_1]
}

resource "aws_route_table_association" "public_subnet_2_public_table" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
  depends_on     = [aws_route_table.public_route_table, aws_subnet.public_subnet_2]
}

resource "aws_s3_bucket" "frontend" {
  bucket = "tf-aokumo"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["123456789012"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.frontend.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}