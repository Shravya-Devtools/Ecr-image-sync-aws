provider "aws" {
  region = "us-east-1"
}

variable "repositories" {
  type = list(string)
}

module "ecr" {
  for_each        = toset(var.repositories)
  source          = "./modules/ecr"
  repository_name = each.value
}

# Create the S3 bucket for Terraform backend (if not exists)
resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = "my-terraform-state-bucket-123" # Replace with your bucket name

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "cleanup"
    enabled = true
    expiration {
      days = 90
    }
  }
}

# Create DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "tf_lock_table" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
