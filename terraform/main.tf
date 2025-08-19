# S3 buckets for raw images
module "raw_images" {
  source = "./modules/s3"

  project_name = var.project_name
  bucket_name  = "raw-images"

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

  public_access_block = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  aws_s3_bucket_website_configuration = {
    index_document = {
      suffix = "index.html"
    }
    error_document = {
      key = "error.html"
    }
  }
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
  region      = var.aws_region

  lambda_invoke_arn    = module.presigned_url_generator.invoke_arn
  lambda_function_name = module.presigned_url_generator.function_name
}

# CloudFront distribution for processed images
module "processed_images_cdn" {
  source = "./modules/cloudfront"

  bucket_id        = module.processed_images.bucket_id
  bucket_arn       = module.processed_images.bucket_arn

  project_name        = var.project_name
  origin_domain_name  = "${module.processed_images.bucket_id}.s3.amazonaws.com"
  comment             = "${var.project_name} CloudFront for processed images"
  default_root_object = "index.html"
}
