#!/bin/bash

# Configuración inicial
AWS_REGION="us-east-1"
PROJECT_NAME=""
S3_BUCKET_NAME=""

# Función para crear User Pool
create_user_pool() {
    echo "Creando User Pool..."
    USER_POOL_ID=$(aws cognito-idp create-user-pool \
        --pool-name "${PROJECT_NAME}-user-pool" \
        --policies '{"PasswordPolicy":{"MinimumLength":8,"RequireUppercase":true,"RequireLowercase":true,"RequireNumbers":true,"RequireSymbols":true}}' \
        --auto-verified-attributes email \
        --schema '[{"Name":"email","Required":true,"Mutable":true},{"Name":"name","Required":false,"Mutable":true}]' \
        --username-attributes email \
        --query 'UserPool.Id' --output text)
    
    echo "User Pool creado con ID: $USER_POOL_ID"

    # Crear App Client
    APP_CLIENT_ID=$(aws cognito-idp create-user-pool-client \
        --user-pool-id $USER_POOL_ID \
        --client-name "${PROJECT_NAME}-app-client" \
        --no-generate-secret \
        --explicit-auth-flows ALLOW_USER_SRP_AUTH ALLOW_REFRESH_TOKEN_AUTH \
        --prevent-user-existence-errors ENABLED \
        --supported-identity-providers COGNITO \
        --query 'UserPoolClient.ClientId' --output text)
    
    echo "App Client creado con ID: $APP_CLIENT_ID"
}

# Función para crear Identity Pool
create_identity_pool() {
    echo "Creando Identity Pool..."
    IDENTITY_POOL_ID=$(aws cognito-identity create-identity-pool \
        --identity-pool-name "${PROJECT_NAME}-identity-pool" \
        --allow-unauthenticated-identities \
        --cognito-identity-providers ProviderName="cognito-idp.${AWS_REGION}.amazonaws.com/${USER_POOL_ID}",ClientId="${APP_CLIENT_ID}" \
        --query 'IdentityPoolId' --output text)
    
    echo "Identity Pool creado con ID: $IDENTITY_POOL_ID"

    # Crear roles de IAM para usuarios autenticados y no autenticados
    AUTHENTICATED_ROLE_ARN=$(aws iam create-role \
        --role-name "${PROJECT_NAME}_AuthenticatedRole" \
        --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Federated":"cognito-identity.amazonaws.com"},"Action":"sts:AssumeRoleWithWebIdentity","Condition":{"StringEquals":{"cognito-identity.amazonaws.com:aud":"'${IDENTITY_POOL_ID}'"},"ForAnyValue:StringLike":{"cognito-identity.amazonaws.com:amr":"authenticated"}}}]}' \
        --query 'Role.Arn' --output text)

    UNAUTHENTICATED_ROLE_ARN=$(aws iam create-role \
        --role-name "${PROJECT_NAME}_UnauthenticatedRole" \
        --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Federated":"cognito-identity.amazonaws.com"},"Action":"sts:AssumeRoleWithWebIdentity","Condition":{"StringEquals":{"cognito-identity.amazonaws.com:aud":"'${IDENTITY_POOL_ID}'"},"ForAnyValue:StringLike":{"cognito-identity.amazonaws.com:amr":"unauthenticated"}}}]}' \
        --query 'Role.Arn' --output text)

    # Asignar roles al Identity Pool
    aws cognito-identity set-identity-pool-roles \
        --identity-pool-id $IDENTITY_POOL_ID \
        --roles authenticated=$AUTHENTICATED_ROLE_ARN,unauthenticated=$UNAUTHENTICATED_ROLE_ARN
}

# Función para crear API Gateway
create_api_gateway() {
    echo "Creando API Gateway..."
    API_ID=$(aws apigateway create-rest-api --name "${PROJECT_NAME}-api" --query 'id' --output text)
    ROOT_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id $API_ID --query 'items[0].id' --output text)
    
    # Crear un autorizador de Cognito
    AUTHORIZER_ID=$(aws apigateway create-authorizer \
        --rest-api-id $API_ID \
        --name CognitoAuthorizer \
        --type COGNITO_USER_POOLS \
        --provider-arns arn:aws:cognito-idp:$AWS_REGION:$AWS_ACCOUNT_ID:userpool/$USER_POOL_ID \
        --identity-source 'method.request.header.Authorization' \
        --query 'id' --output text)

    # Crear un recurso y un método de ejemplo
    RESOURCE_ID=$(aws apigateway create-resource --rest-api-id $API_ID --parent-id $ROOT_RESOURCE_ID --path-part "example" --query 'id' --output text)
    aws apigateway put-method --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method GET --authorization-type "COGNITO_USER_POOLS" --authorizer-id $AUTHORIZER_ID
    
    # Crear una integración mock
    aws apigateway put-integration --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method GET --type MOCK --request-templates '{"application/json":"{\"statusCode\": 200}"}'
    aws apigateway put-method-response --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method GET --status-code 200
    aws apigateway put-integration-response --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method GET --status-code 200 --response-templates '{"application/json":"{\"message\":\"Hello from API Gateway\"}"}'
    
    # Desplegar la API
    aws apigateway create-deployment --rest-api-id $API_ID --stage-name prod
    
    API_ENDPOINT="https://${API_ID}.execute-api.${AWS_REGION}.amazonaws.com/prod"
    echo "API Gateway creada con endpoint: $API_ENDPOINT"
}

# Función para crear AppSync API
create_appsync_api() {
    echo "Creando AppSync API..."
    APPSYNC_API_ID=$(aws appsync create-graphql-api --name "${PROJECT_NAME}-appsync" --authentication-type "AMAZON_COGNITO_USER_POOLS" --user-pool-config userPoolId=$USER_POOL_ID,awsRegion=$AWS_REGION,defaultAction=ALLOW --query 'graphqlApi.apiId' --output text)
    APPSYNC_ENDPOINT=$(aws appsync get-graphql-api --api-id $APPSYNC_API_ID --query 'graphqlApi.uris.GRAPHQL' --output text)
    echo "AppSync API creada con ID: $APPSYNC_API_ID y endpoint: $APPSYNC_ENDPOINT"
}

# Ejecutar funciones
create_user_pool
create_identity_pool
create_api_gateway
create_appsync_api

# Generar JSON de configuración
echo "Generando configuración JSON..."
cat << EOF > awsmobile.json
{
    "aws_project_region": "$AWS_REGION",
    "aws_cognito_identity_pool_id": "$IDENTITY_POOL_ID",
    "aws_cognito_region": "$AWS_REGION",
    "aws_user_pools_id": "$USER_POOL_ID",
    "aws_user_pools_web_client_id": "$APP_CLIENT_ID",
    "oauth": {},
    "aws_appsync_graphqlEndpoint": "$APPSYNC_ENDPOINT",
    "aws_appsync_region": "$AWS_REGION",
    "aws_appsync_authenticationType": "AMAZON_COGNITO_USER_POOLS",
    "aws_cloud_logic_custom": [
        {
            "name": "${PROJECT_NAME}Api",
            "endpoint": "$API_ENDPOINT",
            "region": "$AWS_REGION"
        }
    ],
    "aws_user_files_s3_bucket": "$S3_BUCKET_NAME",
    "aws_user_files_s3_bucket_region": "$AWS_REGION"
}
EOF

echo "Configuración completada. El archivo awsmobile.json ha sido generado."