#!/bin/bash

set -e

# Navigate to the Terraform directory
cd terraform

# Initialize Terraform
terraform init

# Plan the changes
terraform plan -out=tfplan

# Apply the changes
terraform apply tfplan

# Get the outputs
FRONTEND_BUCKET=$(terraform output -raw frontend_bucket_name)
CLOUDFRONT_DOMAIN=$(terraform output -raw cloudfront_distribution_domain)

# Navigate back to the root directory
cd ..

# Build the React app
cd frontend
npm run build

# Deploy to S3
aws s3 sync build s3://$FRONTEND_BUCKET

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DOMAIN --paths "/*"

echo "Deployment complete. Frontend available at: https://$CLOUDFRONT_DOMAIN"