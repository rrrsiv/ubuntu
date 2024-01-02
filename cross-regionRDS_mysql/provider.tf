terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.46.0"
    }
  }
  required_version = "~> 1.2.3"
}

# provider "aws" {
#   region = "us-east-2"
#  }

# provider "aws" {
#   alias = "replica"
#   region = "ap-south-1"
#  }