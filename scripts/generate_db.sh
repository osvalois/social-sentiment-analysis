#!/bin/bash

# Variables
AWS_REGION=""
FUNCTION_NAME="tweet-collector"
ROLE_NAME="lambda-twitter-role"
DYNAMODB_TABLE_NAME="twitter-data"
SQS_QUEUE_NAME="twitter-queue"
HANDLER="index.handler"
RUNTIME="nodejs14.x"
ZIP_FILE="function.zip"

# Crear rol de IAM para Lambda
echo "Creating IAM role..."
ROLE_ARN=$(aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}' \
  --query 'Role.Arn' \
  --output text)

# Adjuntar políticas necesarias al rol
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess

# Esperar a que el rol se propague
echo "Waiting for IAM role to propagate..."
sleep 10

# Crear tabla DynamoDB
echo "Creating DynamoDB table..."
aws dynamodb create-table \
    --table-name $DYNAMODB_TABLE_NAME \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region $AWS_REGION

# Crear cola SQS
echo "Creating SQS queue..."
SQS_QUEUE_URL=$(aws sqs create-queue \
    --queue-name $SQS_QUEUE_NAME \
    --attributes DelaySeconds=0,MaximumMessageSize=262144 \
    --region $AWS_REGION \
    --query 'QueueUrl' \
    --output text)

# Instalar dependencias
echo "Installing dependencies..."
npm install

# Crear el archivo ZIP
echo "Creating deployment package..."
zip -r $ZIP_FILE . -x "*.git*" "*.sh" "*.md"

# Crear la función Lambda
echo "Creating Lambda function..."
aws lambda create-function \
  --function-name $FUNCTION_NAME \
  --runtime $RUNTIME \
  --role $ROLE_ARN \
  --handler $HANDLER \
  --zip-file fileb://$ZIP_FILE \
  --environment Variables="{TWITTER_BEARER_TOKEN=$TWITTER_BEARER_TOKEN,DYNAMODB_TABLE_NAME=$DYNAMODB_TABLE_NAME,SQS_QUEUE_URL=$SQS_QUEUE_URL}" \
  --region $AWS_REGION

# Limpiar
rm $ZIP_FILE

echo "Deployment completed!"
echo "DynamoDB Table Name: $DYNAMODB_TABLE_NAME"
echo "SQS Queue URL: $SQS_QUEUE_URL"
echo "Lambda Function Name: $FUNCTION_NAME"