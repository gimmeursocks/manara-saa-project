resource "aws_dynamodb_table" "this" {
  name         = "${var.project_name}-${var.name}"
  hash_key     = var.hash_key
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = var.hash_key
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-dynamodb-table"
  }
}