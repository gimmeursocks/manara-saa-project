output "api_gateway_invoke_url" {
  description = "The invoke URL for the API Gateway."
  value       = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.this.stage_name}"
}
