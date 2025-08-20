# A map of file extensions to their appropriate content types (MIME types)
locals {
  content_types = {
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "text/javascript"
    "json" = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "ico"  = "image/vnd.microsoft.icon"
  }
}

# Find all files in the 'frontend' directory
locals {
  website_files = fileset("${path.module}/frontend/", "**/*")
}


# S3 buckets for raw images
module "raw_images" {
  source = "./modules/s3"

  project_name = var.project_name
  bucket_name  = "raw-images"

  enable_s3_cors = true

  public_access_block = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

# S3 buckets for processed images
module "processed_images" {
  source = "./modules/s3"

  project_name = var.project_name
  bucket_name  = "processed-images"

  enable_s3_cors = true

  public_access_block = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

# Upload each file found in the 'frontend' directory to the processed_images S3 bucket
resource "aws_s3_object" "website_files" {
  for_each = local.website_files

  bucket       = module.processed_images.bucket_id
  key          = each.value
  source       = "${path.module}/frontend/${each.value}"
  etag         = filemd5("${path.module}/frontend/${each.value}")
  content_type = lookup(local.content_types, regex("[^.]+$", each.value), "application/octet-stream")
}

resource "local_file" "frontend_config" {
  content  = <<EOT
export const API_URL = "${module.image_upload_api.api_gateway_invoke_url}/upload";
export const PROCESSED_BUCKET_URL = "https://${module.processed_images.bucket_name}.s3.eu-central-1.amazonaws.com";
EOT
  filename = "${path.module}/frontend/config.js"
}

# DynamoDB table for metadata
module "metadata" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  name         = "images-metadata"
  hash_key     = "image_id"
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name                = var.project_name
  raw_images_bucket_arn       = module.raw_images.bucket_arn
  processed_images_bucket_arn = module.processed_images.bucket_arn
  dynamodb_table_arn          = module.metadata.dynamodb_table_arn
}

# Presigned URL Lambda Module
module "presigned_url_generator" {
  source = "./modules/lambda"

  project_name  = var.project_name
  function_name = "presigned-url-generator"
  lambda_role   = module.iam.presigned_url_lambda_role_arn
  timeout       = 30

  source_dir = "presigned_url"

  environment_variables = {
    RAW_BUCKET = module.raw_images.bucket_name
  }
}

# Image Processor Lambda Module
module "image_processor" {
  source = "./modules/lambda"

  project_name  = var.project_name
  function_name = "image-processor"
  lambda_role   = module.iam.image_processor_lambda_role_arn
  timeout       = 60

  source_dir = "image_processor"

  layers = ["arn:aws:lambda:eu-central-1:770693421928:layer:Klayers-p39-pillow:1"]
  environment_variables = {
    PROCESSED_BUCKET = module.processed_images.bucket_name
    DYNAMODB_TABLE   = module.metadata.dynamodb_table_name
  }

  enable_s3_trigger = true
  bucket_name       = module.raw_images.bucket_name
  bucket_arn        = module.raw_images.bucket_arn
}

# API Gateway for image upload
module "image_upload_api" {
  source = "./modules/api_gateway"

  project_name = var.project_name
  name         = "api-gateway"
  region       = var.aws_region

  lambda_invoke_arn    = module.presigned_url_generator.invoke_arn
  lambda_function_name = module.presigned_url_generator.function_name
}

# CloudFront distribution for processed images
module "processed_images_cdn" {
  source = "./modules/cloudfront"

  bucket_id  = module.processed_images.bucket_id
  bucket_arn = module.processed_images.bucket_arn

  project_name        = var.project_name
  origin_domain_name  = module.processed_images.bucket_regional_domain_name
  comment             = "${var.project_name} CloudFront for processed images"
  default_root_object = "index.html"
}
