variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "public_access_block" {
  description = "Configuration for public access block settings."
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "lambda_notifications" {
  type = list(object({
    lambda_arn    = string
    lambda_name   = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  }))
  default = []
}

variable "enable_s3_cors" {
  description = "Enable CORS configuration for the S3 bucket."
  type        = bool
  default     = false
} 