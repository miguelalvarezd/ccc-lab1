terraform {
  required_version = ">= 1.14"
  backend "s3" {
    bucket = "tf-state-029516685363-us-east-1"
    key   = "lab1/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true 
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

