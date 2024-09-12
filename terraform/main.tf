provider "aws" {
  region = var.aws_region
}

# DynamoDB Table
resource "aws_dynamodb_table" "tweets_table" {
  name           = "${var.project_name}-tweets"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  range_key      = "created_at"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  tags = var.common_tags
}

# Lambda Functions
resource "aws_lambda_function" "tweet_collector" {
  filename         = "../backend/lambdas/tweet_collector/lambda_function.zip"
  function_name    = "${var.project_name}-tweet-collector"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("../backend/lambdas/tweet_collector/lambda_function.zip")
  runtime          = "nodejs14.x"

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.tweets_table.name
      TWITTER_API_KEY     = var.twitter_api_key
      TWITTER_API_SECRET  = var.twitter_api_secret
    }
  }

  tags = var.common_tags
}

resource "aws_lambda_function" "sentiment_analyzer" {
  filename         = "../backend/lambdas/sentiment_analyzer/lambda_function.zip"
  function_name    = "${var.project_name}-sentiment-analyzer"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("../backend/lambdas/sentiment_analyzer/lambda_function.zip")
  runtime          = "python3.8"

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.tweets_table.name
    }
  }

  tags = var.common_tags
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# API Gateway
resource "aws_api_gateway_rest_api" "sentiment_api" {
  name        = "${var.project_name}-api"
  description = "API for Social Sentiment Analysis"

  tags = var.common_tags
}

# Cognito User Pool
resource "aws_cognito_user_pool" "pool" {
  name = "${var.project_name}-user-pool"

  tags = var.common_tags
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "${var.project_name}-client"
  user_pool_id = aws_cognito_user_pool.pool.id

  generate_secret = false
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

# S3 Bucket for Frontend
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${var.project_name}-frontend"

  tags = var.common_tags
}

resource "aws_s3_bucket_website_configuration" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.frontend_bucket.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend_bucket.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.common_tags
}