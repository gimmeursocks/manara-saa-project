# S3 bucket
resource "aws_s3_bucket" "this" {
  bucket = "${var.project_name}-${var.bucket_name}-bucket"
  force_destroy = true
  
  tags = {
    Name = "${var.bucket_name}"
  }
}

# Modify public access to the bucket
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.public_access_block.block_public_acls
  block_public_policy     = var.public_access_block.block_public_policy
  ignore_public_acls      = var.public_access_block.ignore_public_acls
  restrict_public_buckets = var.public_access_block.restrict_public_buckets
}

resource "aws_s3_bucket_notification" "this" {
  bucket = aws_s3_bucket.this.id

  dynamic "lambda_function" {
    for_each = var.lambda_notifications
    content {
      lambda_function_arn = lambda_function.value.lambda_arn
      events              = lambda_function.value.events
      filter_suffix       = lookup(lambda_function.value, "filter_suffix")
      filter_prefix       = lookup(lambda_function.value, "filter_prefix")
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count  = var.enable_s3_cors ? 1 : 0
  bucket = aws_s3_bucket.this.id

  cors_rule {
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}