variable "stack_name" {
  description = "Define stack name"
  type        = string
  default     = "Lab-architecture"
}

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/24"
}

variable "vpc_instance_tenancy" {
  description = "VPC tenancy"
  type        = string
  default     = "default"
}

variable "vpc_tags_name" {
  description = "VPC name"
  type        = string
  default     = "vpc"
}

variable "igw_tags_name" {
  description = "VPC name"
  type        = string
  default     = "igw"
}

variable "public_subnet_1_cidr_block" {
  description = "Public subnet 1 CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_1_name" {
  description = "Public subnet 1 name"
  type        = string
  default     = "public-subnet-1"
}

variable "public_subnet_2_cidr_block" {
  description = "Public subnet 2 CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_2_name" {
  description = "Public subnet 2 name"
  type        = string
  default     = "public-subnet-2"
}

variable "public_route_table_name" {
  description = "Public route table name"
  type        = string
  default     = "public-route-table"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "dns_domain" {
  type    = string
  default = "dev.uhrsb.de"
}

variable "service" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}