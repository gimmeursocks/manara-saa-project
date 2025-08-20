variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "lambda_role" {
  description = "ARN of the IAM role for the image processing Lambda function."
  type        = string
}

variable "function_name" {
  description = "Name of the Lambda function to generate pre-signed URLs."
  type        = string
}

variable "timeout" {
  description = "Timeout for the Lambda function in seconds."
  type        = number
}

variable "source_dir" {
  description = "Directory containing the source code for the Lambda function."
  type        = string
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for the Lambda"
  default     = {}
}

variable "enable_s3_trigger" {
  type        = bool
  description = "Whether to create S3 bucket notification + permission"
  default     = false
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = ""
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
  default     = ""
}

variable "layers" {
  description = "List of Lambda layers to attach to the function"
  type        = list(string)
  default     = []
}