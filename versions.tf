terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" 
      version = "~> 5.0"       
    }
  }
}

# Configures the AWS Provider
provider "aws" {
  region = var.aws_region
}

# IMPORTANT: CloudFront certificates MUST be in us-east-1 (N. Virginia).
# We define a second AWS provider instance specifically for this region.
provider "aws" {
  alias  = "us_east_1"
  region = var.acm_certificate_region
}