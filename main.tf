# Terrafrom
terraform {
  required_version = ">=0.12.0"
}

#Provider
# Implement cloud specifc API and Terrafrom API
# Provider configuration is specific to each provider
#Providers expose Data sources and Resources to Terrafrom

provider "aws" {
    version = "~> 2.0"
    region = "us-east-1"

    # access_key = "My Access key"
    # secret_key = "My Secret access key"

    # Many providers accept configuration via environment variables or config files
    # The AWS provider will read the standard AWS CLI settings if they are present
  
}

# Data sources
# Objects not managed by terraform
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
    state = "available"
}

# Resources
# Objects managed by terrafrom
# Declring resources tells terrafrom that it shold create and manage the 
# resources described, If the resouce is already created then it must be imported
# to terraform's state 
resource "aws_s3_bucket" "Bucket1" {
    bucket = "Bucket1"
}

# Output
output "greeting" {
    value = "Hello terraform"
  
}

