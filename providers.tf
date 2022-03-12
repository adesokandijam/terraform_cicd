terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  cloud {
    organization = "IoTeam"

    workspaces {
      name = "dev-arch"
    }
  }

}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}