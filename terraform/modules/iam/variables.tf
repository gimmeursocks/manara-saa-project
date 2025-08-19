variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "raw_images_bucket_arn" {
  description = "ARN of the raw images S3 bucket."
  type        = string
}

variable "processed_images_bucket_arn" {
  description = "ARN of the processed images S3 bucket."
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB metadata table."
  type        = string
}