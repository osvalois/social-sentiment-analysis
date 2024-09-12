# Architecture Overview

This document outlines the architecture of the Social Sentiment Analysis project.

## High-Level Architecture

```
[Frontend (React)] <-> [API Gateway] <-> [Lambda Functions] <-> [DynamoDB]
                                           ^
                                           |
                                     [Twitter API]
```

## Components

1. **Frontend**: React application hosted on S3 and distributed via CloudFront.
2. **API Gateway**: Manages API endpoints and integrates with Lambda functions.
3. **Lambda Functions**:
   - Tweet Collector: Fetches tweets from Twitter API and stores them in DynamoDB.
   - Sentiment Analyzer: Analyzes sentiment of tweets using Amazon Comprehend.
4. **DynamoDB**: Stores tweets and sentiment analysis results.
5. **Cognito**: Manages user authentication and authorization.
6. **CloudWatch**: Monitors application performance and logs.

## Data Flow

1. The Tweet Collector Lambda function periodically fetches tweets from the Twitter API.
2. Tweets are stored in DynamoDB.
3. The Sentiment Analyzer Lambda function processes tweets and updates sentiment scores in DynamoDB.
4. The frontend application fetches analyzed data through API Gateway and Lambda functions.
5. Users interact with the frontend to view sentiment analysis results and trends.

## Security

- All communications are encrypted using HTTPS.
- API Gateway uses Cognito for authentication and authorization.
- Lambda functions use IAM roles with least privilege principles.
- S3 bucket for frontend hosting is configured for static website hosting with appropriate security headers.

## Scalability

- Lambda functions automatically scale based on incoming requests.
- DynamoDB can handle high read/write throughput with on-demand capacity.
- CloudFront provides global content delivery for the frontend.

## Monitoring and Logging

- CloudWatch is used for monitoring Lambda functions, API Gateway, and DynamoDB.
- CloudWatch Logs capture detailed logs from all components.
- CloudWatch Alarms are set up to notify of any issues or anomalies.