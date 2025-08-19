resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  comment             = var.comment
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.aliases

  origin {
    domain_name = var.origin_domain_name
    origin_id   = "${var.project_name}-s3-origin"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.this.id}"
    }
  }

  default_cache_behavior {
    target_origin_id       = "${var.project_name}-s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized (AWS managed)
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "${var.project_name}-OAI"
}

# Grant OAI access to read bucket
resource "aws_s3_bucket_policy" "oai_access" {
  bucket = var.bucket_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = aws_cloudfront_origin_access_identity.this.iam_arn
      }
      Action   = "s3:GetObject"
      Resource = "${var.bucket_arn}/*"
    }]
  })
}