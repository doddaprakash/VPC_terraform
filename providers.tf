terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
    region = "eu-west-1"
}

provider "aws" {
    region = "eu-west-1"
    alias = "euw1"
}

provider "aws" {
    region = "eu-west-2"
    alias = "euw2"
}
