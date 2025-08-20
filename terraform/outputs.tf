output "raw_images_bucket_name" {
  description = "The name of the S3 bucket for raw image uploads."
  value       = module.raw_images.bucket_name
}

output "processed_images_bucket_name" {
  description = "The name of the S3 bucket for processed images."
  value       = module.processed_images.bucket_name
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for image metadata."
  value       = module.metadata.dynamodb_table_name
}

output "api_gateway_invoke_url" {
  description = "The invoke URL for the API Gateway."
  value       = module.image_upload_api.api_gateway_invoke_url
}

output "website_url" {
  description = "The URL for the CloudFront distribution."
  value       = "https://${module.processed_images_cdn.distribution_domain_name}"
}
