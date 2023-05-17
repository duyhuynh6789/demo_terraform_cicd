# Define
provider "aws" {
  region = "us-east-1"
}

# Create a vpc
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
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
    Name = "${var.stack_name} | ${var.env} |${var.igw_tags_name}"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true #tfsec:ignore:aws-ec2-no-public-ip-subnet
  tags = {
    Name = "${var.stack_name} | ${var.vpc_tags_name} | ${var.env} | ${var.public_subnet_1_name}"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true #tfsec:ignore:aws-ec2-no-public-ip-subnet
  tags = {
    Name = "${var.stack_name} | ${var.vpc_tags_name} | ${var.env} | ${var.public_subnet_2_name}"
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
    Name = "${var.stack_name} | ${var.vpc_tags_name} | ${var.env} | ${var.public_route_table_name}"
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
#tfsec:ignore:aws-s3-block-public-policy
#tfsec:ignore:aws-s3-enable-bucket-encryption
#tfsec:ignore:aws-s3-ignore-public-acls
#tfsec:ignore:aws-s3-no-public-buckets
#tfsec:ignore:aws-s3-encryption-customer-key
#tfsec:ignore:aws-s3-block-public-acls
#tfsec:ignore:aws-s3-specify-public-access-block
#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "frontend" {
  bucket = "tf-aokumo-${var.env}"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# resource "aws_s3_bucket_ownership_controls" "s3_own_ctl" {
#   bucket = aws_s3_bucket.frontend.id
#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "access_block" {
#   bucket = aws_s3_bucket.frontend.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }


# resource "aws_s3_bucket_acl" "acl_bucket" {
#   depends_on = [
#     aws_s3_bucket_ownership_controls.s3_own_ctl,
#     aws_s3_bucket_public_access_block.access_block,
#   ]

#   bucket = aws_s3_bucket.frontend.id
#   acl    = "public-read"
# }

# data "aws_iam_policy_document" "allow_access_from_another_account" {
#   statement {
#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     actions = [
#       "s3:GetObject"
#     ]

#     resources = [
#       "${aws_s3_bucket.frontend.arn}/*"
#     ]
#   }
#   depends_on = [aws_s3_bucket.frontend]
# }

# resource "aws_s3_bucket_policy" "attach_s3_policy" {
#   bucket = aws_s3_bucket.frontend.id
#   policy = data.aws_iam_policy_document.allow_access_from_another_account.json
# }

# resource "aws_s3_bucket_website_configuration" "website_config" {
#   bucket = aws_s3_bucket.frontend.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "error.html"
#   }
# }