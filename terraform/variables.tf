variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "manara-serverless-image-processing"
}
