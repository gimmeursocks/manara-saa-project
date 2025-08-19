# S3 bucket
resource "aws_s3_bucket" "this" {
  bucket = "${var.project_name}-${var.bucket_name}-bucket"

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

# Enable static website hosting for the processed images bucket
resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  index_document {
    suffix = var.aws_s3_bucket_website_configuration.index_document.suffix
  }
  error_document {
    key = var.aws_s3_bucket_website_configuration.error_document.key
  }
}

resource "aws_s3_bucket_notification" "this" {
  bucket = aws_s3_bucket.this.id

  dynamic "lambda_function" {
    for_each = var.lambda_notifications
    content {
      lambda_function_arn = lambda_function.value.lambda_arn
      events              = lambda_function.value.events
      filter_suffix       = lookup(lambda_function.value, "filter_suffix", null)
      filter_prefix       = lookup(lambda_function.value, "filter_prefix", null)
    }
  }
}