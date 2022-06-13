terraform {
  backend "remote" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 1.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.aws_region
  assume_role {
    role_arn = var.role_arn
  }
  default_tags {
    tags = {
      environment="${var.env}"
      appid="LDI"
      creator="cicd"
      support="devops"
      owner="lii-devops@livingstonintl.com"
    }
  }
}

provider "archive" {}

