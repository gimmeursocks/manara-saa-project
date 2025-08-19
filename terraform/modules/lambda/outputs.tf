output "invoke_arn" {
  description = "The invoke ARN of the Lambda function."
  value       = aws_lambda_function.this.invoke_arn
}

output "function_name" {
  description = "The name of the Lambda function."
  value       = aws_lambda_function.this.function_name
}