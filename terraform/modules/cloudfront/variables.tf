variable "project_name" {
  type        = string
  description = "Project name for prefixing CloudFront distribution"
}

variable "origin_domain_name" {
  type        = string
  description = "Domain name of the S3 website bucket (e.g. bucket-name.s3-website-region.amazonaws.com)"
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "Default root object for CloudFront"
}

variable "aliases" {
  type        = list(string)
  default     = []
  description = "Optional list of CNAMEs for the distribution"
}

variable "comment" {
  type    = string
  default = "CloudFront distribution"
}

variable "price_class" {
  type    = string
  default = "PriceClass_100" # North America + Europe
}

variable "enabled" {
  type    = bool
  default = true
}

variable "bucket_id" {
  type        = string
  description = "ID of the S3 bucket to be used as the origin for CloudFront"
}

variable "bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket to be used as the origin for CloudFront"
}