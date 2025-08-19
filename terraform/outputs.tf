output "raw_images_bucket_name" {
  description = "The name of the S3 bucket for raw image uploads."
  value       = module.raw_images.bucket_name
}

output "processed_images_bucket_name" {
  description = "The name of the S3 bucket for processed images."
  value       = module.processed_images.bucket_name
}

output "processed_images_bucket_website_endpoint" {
  description = "The website endpoint of the processed images S3 bucket."
  value       = module.processed_images.bucket_website_endpoint
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for image metadata."
  value       = module.metadata.dynamodb_table_name
}

output "api_gateway_invoke_url" {
  description = "The invoke URL for the API Gateway."
  value       = module.image_upload_api.api_gateway_invoke_url
}
