terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"

  backend "s3" {
    bucket = "gload-terraform-state-bucket-463"
    key = "dev/s3/terraform.tfstate"
    region = "eu-central-1"

    dynamodb_table = "gload-terraform-locks"
    encrypt = true
  }
}
