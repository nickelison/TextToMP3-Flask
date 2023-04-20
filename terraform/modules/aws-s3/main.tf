provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for your Flask app"
}

resource "aws_s3_bucket" "demo_app_bucket" {
  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "demo_app_bucket" {
  bucket = aws_s3_bucket.demo_app_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.demo_app_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}
