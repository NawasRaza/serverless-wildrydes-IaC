terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "credentials"
}

