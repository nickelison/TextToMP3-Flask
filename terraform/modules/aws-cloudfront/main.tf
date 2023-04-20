resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = var.s3_bucket_regional_domain_name
    origin_id   = var.s3_bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = var.oai_cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_bucket_regional_domain_name
    trusted_signers  = ["self"]
    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:431608762876:certificate/2976efa0-44ba-4a28-895f-f7d2f3a6906a"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  enabled         = true
  price_class     = "PriceClass_All"
  is_ipv6_enabled = true
  comment         = "CloudFront distribution for your Flask app"
}
