variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "name" {
  description = "The name of the API Gateway."
  type        = string
}

variable "region" {
  description = "The AWS region where the API Gateway is deployed."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "The URI for the Lambda function integration."
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function to integrate with the API Gateway."
  type        = string
}
