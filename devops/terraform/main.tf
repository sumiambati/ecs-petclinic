provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "dhs-poc-devsecops-terraform"
    key    = "ecs-petclinic-dev.tfstate"
    region = "us-east-1"
  }
}

module "global" {
  source = "./global"

  App = var.app
  Environment = var.environment
}