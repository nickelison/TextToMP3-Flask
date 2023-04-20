variable "s3_bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  type        = string
}

variable "origin_id" {
  description = "A unique identifier for the CloudFront origin"
  type        = string
}

variable "oai_cloudfront_access_identity_path" {
  description = "The CloudFront access identity path of the Origin Access Identity"
  type        = string
}
