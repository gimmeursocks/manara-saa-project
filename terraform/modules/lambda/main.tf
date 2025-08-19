resource "aws_lambda_function" "this" {
  function_name = "${var.project_name}-${var.function_name}"
  role          = var.lambda_role
  handler       = "${var.source_dir}.lambda_handler"
  runtime       = "python3.9"
  timeout       = var.timeout

  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  environment {
    variables = var.environment_variables
  }
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/${var.source_dir}"
  output_path = "${path.module}/${var.source_dir}.zip"
}

# S3 bucket notification to trigger the image processing Lambda
resource "aws_s3_bucket_notification" "raw_images_notification" {
  count  = var.enable_s3_trigger ? 1 : 0
  bucket = var.bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_lambda_permission]
}

# Permission for S3 to invoke the Lambda function
resource "aws_lambda_permission" "s3_lambda_permission" {
  count         = var.enable_s3_trigger ? 1 : 0
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}
