variable "environment" {
  description = "Environment name"
}

variable "app" {
  description = "Application name"
  default     = "app"
}

variable "aws_region" {
  description = "AWS Region"
}

variable "vpc" {
  description = "VPC ID"
}

variable "private_subnets" {
  description = "Private subnets seperated by comma"
}

variable "public_subnets" {
  description = "Private subnets seperated by comma"
  default = ""
}

