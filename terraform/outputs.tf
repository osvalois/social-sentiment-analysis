output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.tweets_table.name
}

output "tweet_collector_lambda_arn" {
  description = "The ARN of the tweet collector Lambda function"
  value       = aws_lambda_function.tweet_collector.arn
}

output "sentiment_analyzer_lambda_arn" {
  description = "The ARN of the sentiment analyzer Lambda function"
  value       = aws_lambda_function.sentiment_analyzer.arn
}

output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = aws_api_gateway_rest_api.sentiment_api.execution_arn
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.pool.id
}

output "cognito_client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.client.id
}

output "frontend_bucket_name" {
  description = "The name of the S3 bucket hosting the frontend"
  value       = aws_s3_bucket.frontend_bucket.id
}

output "cloudfront_distribution_domain" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend_distribution.domain_name
}