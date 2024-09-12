#!/bin/bash

# Variables
AWS_REGION="us-east-1"
FUNCTION_NAME="tweet-sentiment-analyzer"
ROLE_NAME="lambda-twitter-role"
HANDLER="index.lambda_handler"
RUNTIME="python3.9"
LAYER_NAME="tweet-sentiment-dependencies"
ZIP_FILE="function.zip"
LAYER_ZIP="layer.zip"

# Variables de entorno para la función Lambda
DYNAMODB_TABLE_NAME="tweet-collector"

# Verificar si el rol ya existe y obtener su ARN
echo "Checking for existing IAM role..."
ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query 'Role.Arn' --output text 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "Creating new IAM role..."
    ROLE_ARN=$(aws iam create-role --role-name $ROLE_NAME \
        --assume-role-policy-document '{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "lambda.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }' \
        --query 'Role.Arn' \
        --output text)

    # Adjuntar políticas al rol
    aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
    aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
    aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess

    # Crear política personalizada para Amazon Bedrock
    aws iam put-role-policy --role-name $ROLE_NAME --policy-name BedrockInvokePolicy --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "bedrock:InvokeModel"
                ],
                "Resource": "*"
            }
        ]
    }'

    echo "Waiting for IAM role to propagate..."
    sleep 10
else
    echo "Using existing IAM role"
fi

echo "Role ARN: $ROLE_ARN"

# Crear entorno virtual e instalar dependencias
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate

# Crear el archivo ZIP para la capa
mkdir -p python/lib/python3.9/site-packages
pip install -r requirements.txt -t python/lib/python3.9/site-packages
zip -r $LAYER_ZIP python

# Crear o actualizar la capa de Lambda
LAYER_VERSION=$(aws lambda publish-layer-version \
    --layer-name $LAYER_NAME \
    --zip-file fileb://$LAYER_ZIP \
    --compatible-runtimes python3.9 \
    --region $AWS_REGION \
    --query 'Version' \
    --output text)

echo "Layer version: $LAYER_VERSION"

# Crear el archivo ZIP para la función
zip -j $ZIP_FILE index.py

# Crear o actualizar la función Lambda
if aws lambda get-function --function-name $FUNCTION_NAME --region $AWS_REGION 2>&1 | grep -q 'Function not found'; then
    # Crear la función Lambda si no existe
    aws lambda create-function \
      --function-name $FUNCTION_NAME \
      --runtime $RUNTIME \
      --role $ROLE_ARN \
      --handler $HANDLER \
      --zip-file fileb://$ZIP_FILE \
      --layers $(aws lambda list-layer-versions --layer-name $LAYER_NAME --query 'LayerVersions[0].LayerVersionArn' --output text) \
      --environment Variables="{DYNAMODB_TABLE_NAME=$DYNAMODB_TABLE_NAME}" \
      --region $AWS_REGION
else
    # Actualizar la función Lambda si ya existe
    aws lambda update-function-code \
      --function-name $FUNCTION_NAME \
      --zip-file fileb://$ZIP_FILE \
      --region $AWS_REGION

    aws lambda update-function-configuration \
      --function-name $FUNCTION_NAME \
      --role $ROLE_ARN \
      --layers $(aws lambda list-layer-versions --layer-name $LAYER_NAME --query 'LayerVersions[0].LayerVersionArn' --output text) \
      --environment Variables="{DYNAMODB_TABLE_NAME=$DYNAMODB_TABLE_NAME}" \
      --region $AWS_REGION
fi

# Limpiar
rm $ZIP_FILE $LAYER_ZIP
rm -rf python venv

echo "Deployment completed!"
echo "Lambda Function Name: $FUNCTION_NAME"
echo "IAM Role Name: $ROLE_NAME"
echo "IAM Role ARN: $ROLE_ARN"
echo "DynamoDB Table Name: $DYNAMODB_TABLE_NAME"
echo "AWS Region: $AWS_REGION"