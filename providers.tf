terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      
    }
  }
}
provider "aws" {
  region     = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}