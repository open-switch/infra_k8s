# store terraform state in s3 with locking

resource "aws_s3_bucket" "opx-terraform-state-store" {
  bucket = "opx-openswitch-net-terraform-state-store"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
  tags {
    Name = "OPX Remote Terraform State Store"
  }
}

resource "aws_dynamodb_table" "opx-terraform-state-lock" {
  name = "opx-openswitch-net-terraform-state-lock"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
  tags {
    Name = "OPX DynamoDB Terraform State Lock Table"
  }
}

terraform {
  backend "s3" {
    encrypt = true
    bucket = "opx-openswitch-net-terraform-state-store"
    dynamodb_table = "opx-openswitch-net-terraform-state-lock"
    region = "us-west-2"
    key = "terraform.tfstate"
  }
}

