import json
import os
import boto3
from botocore.config import Config

# Utiliza la región de AWS proporcionada por Lambda
aws_region = os.environ['AWS_REGION']

bedrock = boto3.client('bedrock-runtime', config=Config(region_name=aws_region))
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE_NAME'])

def lambda_handler(event, context):
    for record in event['Records']:
        tweet = json.loads(record['body'])
        sentiment = analyze_sentiment(tweet['text'])
        store_sentiment(tweet['id'], sentiment)

    return {
        'statusCode': 200,
        'body': json.dumps('Sentiment analysis completed successfully')
    }

def analyze_sentiment(text):
    prompt = f"Analyze the sentiment of this tweet: '{text}'. Respond with only one word: positive, negative, or neutral."
    
    response = bedrock.invoke_model(
        modelId='anthropic.claude-v2',
        body=json.dumps({
            "prompt": prompt,
            "max_tokens_to_sample": 10,
            "temperature": 0,
            "top_p": 1,
        })
    )
    
    result = json.loads(response['body'].read())
    return result['completion'].strip().lower()

def store_sentiment(tweet_id, sentiment):
    table.update_item(
        Key={'id': tweet_id},
        UpdateExpression='SET sentiment = :sentiment',
        ExpressionAttributeValues={':sentiment': sentiment}
    )