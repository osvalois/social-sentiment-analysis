#!/bin/bash

# Variables
AWS_REGION="us-east-1"
FUNCTION_NAME="tweet-collector"
ROLE_ARN="arn:aws:iam::864899849021:role/lambda-twitter-role"  # Asegúrate de reemplazar esto con el ARN correcto de tu rol
HANDLER="index.handler"
RUNTIME="nodejs18.x"  # Actualizado a Node.js 18.x
ZIP_FILE="function.zip"

# Variables de entorno para la función Lambda
TWITTER_BEARER_TOKEN="AAAAAAAAAAAAAAAAAAAAAMhwvwEAAAAAKHNoaP07nmEqaSAy3Hi7gdFjkx4%3DF45Q88L6vSgo2ggVjqtAUVaa946E0nC0smrgFlnFTCOyQC44KS"
DYNAMODB_TABLE_NAME="tweet-collector"
SQS_QUEUE_URL="https://sqs.us-east-1.amazonaws.com/864899849021/twitter-queue"

# Instalar dependencias
echo "Installing dependencies..."
npm install

# Crear el archivo ZIP
echo "Creating deployment package..."
zip -r $ZIP_FILE . -x "*.git*" "*.sh" "*.md"

# Crear o actualizar la función Lambda
echo "Deploying Lambda function..."
if aws lambda get-function --function-name $FUNCTION_NAME --region $AWS_REGION 2>&1 | grep -q 'Function not found'; then
    # Crear la función Lambda si no existe
    aws lambda create-function \
      --function-name $FUNCTION_NAME \
      --runtime $RUNTIME \
      --role $ROLE_ARN \
      --handler $HANDLER \
      --zip-file fileb://$ZIP_FILE \
      --environment Variables="{TWITTER_BEARER_TOKEN=$TWITTER_BEARER_TOKEN,DYNAMODB_TABLE_NAME=$DYNAMODB_TABLE_NAME,SQS_QUEUE_URL=$SQS_QUEUE_URL}" \
      --region $AWS_REGION
else
    # Actualizar la función Lambda si ya existe
    aws lambda update-function-code \
      --function-name $FUNCTION_NAME \
      --zip-file fileb://$ZIP_FILE \
      --region $AWS_REGION

    aws lambda update-function-configuration \
      --function-name $FUNCTION_NAME \
      --runtime $RUNTIME \
      --environment Variables="{TWITTER_BEARER_TOKEN=$TWITTER_BEARER_TOKEN,DYNAMODB_TABLE_NAME=$DYNAMODB_TABLE_NAME,SQS_QUEUE_URL=$SQS_QUEUE_URL}" \
      --region $AWS_REGION
fi

# Limpiar
rm $ZIP_FILE

echo "Deployment completed!"
echo "Lambda Function Name: $FUNCTION_NAME"
echo "DynamoDB Table Name: $DYNAMODB_TABLE_NAME"
echo "SQS Queue URL: $SQS_QUEUE_URL"