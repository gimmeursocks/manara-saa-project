variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "name" {
  description = "The name of the DynamoDB table."
  type        = string
}

variable "hash_key" {
  description = "The hash key for the DynamoDB table."
  type        = string
}