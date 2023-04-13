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
}

# Outputs
output "greeting" {
    value = "Hello terraform"
  
}

output "aws_caller_info" {
    value = data.aws_caller_identity.current
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.available
}

output "bucket_info" {
  value = aws_s3_bucket.Bucket1.bucket
}

# Interpolation
# Substitute values in strings
resource "aws_s3_bucket" "bucket2" {
  bucket = "${data.aws_caller_identity.current.account_id}-bucket2"
}

# Dependency
# Resources can depend on one another. Terraform will ensure that all the dependencies are met
# before creating a resource. Dependancies can be implicit or exlicit.

resource "aws_s3_bucket" "bucket3" {
  bucket = "${data.aws_caller_identity.current.account_id}-bucket3"
  tags = {
    # Implicit dependency
    "dependency" = aws_s3_bucket.bucket2.arn
  }
}
resource "aws_s3_bucket" "bucket4" {
  bucket = "${data.aws_caller_identity.current.account_id}-bucket4"

  depends_on = [
    aws_s3_bucket.bucket3
  ]
}

# Variables
# Can be specified on the commnd line with -var bucket_name my-bucket or 
# in files: terraform.tfvars or *.auto.tfvars
# or in environment variables: TF_VAR_Buckett_name

variable "bucket_name" {


  # `default` is an optional default value, If `default` is ommited
  # then a value must be supplied.
  # default = "my-bucket"
}

# resource "aws_s3_bucket" "Bucket5" {
#   bucket = var.bucket_name
# }

# Local values
# Local values allow you to assign a name to an expression. Locals can make your code more readable
locals {
  aws_account = "${data.aws_caller_identity.current.account_id}-${lower(data.aws_caller_identity.current.user_id)}"
}

resource "aws_s3_bucket" "Bucket6" {
  bucket = "${local.aws_account}-bucket6"
}

# Count
# All the resources have a `count` parameter. The default is 1.
# If a count is set then a list of resources is returned(Even if there is only one)
# If `count` is set, Then a `count.index` value is available. The value contains the current 
# iteration number.
# TIP: Setting `count =0` is a handy way to remove a resource but to keep the config
resource "aws_s3_bucket" "bucketX" {
  count = 4
  bucket = "${local.aws_account}-bucket${count.index+7}"
}

# for_each
# Resources may have a `for_each` parameter.
# If for_each is set, then a resource is created for each item in the set and a 
# special `each` object is available. The each object has a key and value 
# attributes that can be referenced.

locals {
  buckets = {
    bucket101 = "mybucket101"
    bucket102 = "mybucket102"
  }
}

resource "aws_s3_bucket" "bucketFE" {
  for_each = local.buckets
  bucket = "${local.aws_account}-${each.value}"
}

# Conditionals
variable "bucket_count" {
  type = number
}

locals {
  minimum_number_of_buckets = 5
  number_of_buckets = var.bucket_count >0 ? var.bucket_count : local.minimum_number_of_buckets
}

resource "aws_s3_bucket" "buckets" {
  count = local.number_of_buckets
  bucket = "${local.aws_account}-bucket${count.index+7}"
}