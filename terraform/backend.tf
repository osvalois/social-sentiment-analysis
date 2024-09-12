terraform {
  backend "s3" {
    bucket         = "social-sentiment-analysis-tfstate"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "social-sentiment-analysis-tfstate-lock"
  }
}