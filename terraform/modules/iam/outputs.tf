output "image_processor_lambda_role_arn" {
  value = aws_iam_role.image_processor_lambda_role.arn
}

output "presigned_url_lambda_role_arn" {
  value = aws_iam_role.presigned_url_lambda_role.arn
}
