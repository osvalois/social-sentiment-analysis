variable "aws_region" {
  description = "The AWS region to deploy resources"
  default     = "us-west-2"
}

variable "project_name" {
  description = "The name of the project"
  default     = "social-sentiment-analysis"
}

variable "twitter_api_key" {
  description = "Twitter API Key"
  type        = string
}

variable "twitter_api_secret" {
  description = "Twitter API Secret"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Project     = "Social Sentiment Analysis"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}