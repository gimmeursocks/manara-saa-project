# IAM role for the image processing Lambda function
resource "aws_iam_role" "image_processor_lambda_role" {
  name = "${var.project_name}-image-processor-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for the image processing Lambda function
resource "aws_iam_policy" "image_processor_lambda_policy" {
  name        = "${var.project_name}-image-processor-lambda-policy"
  description = "Policy for the image processing Lambda function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "s3:GetObject"
        ],
        Effect   = "Allow",
        Resource = "${var.raw_images_bucket_arn}/*"
      },
      {
        Action = [
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = "${var.processed_images_bucket_arn}/*"
      },
      {
        Action = [
          "dynamodb:PutItem"
        ],
        Effect   = "Allow",
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "image_processor_lambda_attachment" {
  role       = aws_iam_role.image_processor_lambda_role.name
  policy_arn = aws_iam_policy.image_processor_lambda_policy.arn
}

# IAM role for the pre-signed URL Lambda function
resource "aws_iam_role" "presigned_url_lambda_role" {
  name = "${var.project_name}-presigned-url-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for the pre-signed URL Lambda function
resource "aws_iam_policy" "presigned_url_lambda_policy" {
  name        = "${var.project_name}-presigned-url-lambda-policy"
  description = "Policy for the pre-signed URL Lambda function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = "${var.raw_images_bucket_arn}/*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "presigned_url_lambda_attachment" {
  role       = aws_iam_role.presigned_url_lambda_role.name
  policy_arn = aws_iam_policy.presigned_url_lambda_policy.arn
}
