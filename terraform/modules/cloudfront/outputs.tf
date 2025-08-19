output "distribution_id" {
  value       = aws_cloudfront_distribution.this.id
  description = "ID of the CloudFront distribution"
}

output "distribution_domain_name" {
  value       = aws_cloudfront_distribution.this.domain_name
  description = "Domain name of the CloudFront distribution"
}
