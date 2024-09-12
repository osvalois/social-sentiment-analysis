import unittest
from unittest.mock import patch, MagicMock
import json
import os
import sys

# Add the Lambda function directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + '/lambdas/sentiment_analyzer')

from index import lambda_handler, analyze_sentiment, store_sentiment

class TestSentimentAnalyzer(unittest.TestCase):

    @patch('index.analyze_sentiment')
    @patch('index.store_sentiment')
    def test_lambda_handler(self, mock_store_sentiment, mock_analyze_sentiment):
        mock_analyze_sentiment.return_value = 'positive'
        
        event = {
            'Records': [
                {'body': json.dumps({'id': '1', 'text': 'I love AWS!'})},
                {'body': json.dumps({'id': '2', 'text': 'Cloud computing is amazing'})}
            ]
        }
        
        result = lambda_handler(event, None)
        
        self.assertEqual(result['statusCode'], 200)
        self.assertEqual(json.loads(result['body']), 'Sentiment analysis completed successfully')
        self.assertEqual(mock_analyze_sentiment.call_count, 2)
        self.assertEqual(mock_store_sentiment.call_count, 2)

    @patch('index.bedrock')
    def test_analyze_sentiment(self, mock_bedrock):
        mock_response = MagicMock()
        mock_response['body'].read.return_value = json.dumps({'completion': 'Positive'})
        mock_bedrock.invoke_model.return_value = mock_response

        sentiment = analyze_sentiment('I love AWS!')
        
        self.assertEqual(sentiment, 'positive')
        mock_bedrock.invoke_model.assert_called_once()

    @patch('index.table')
    def test_store_sentiment(self, mock_table):
        store_sentiment('1', 'positive')
        
        mock_table.update_item.assert_called_once_with(
            Key={'id': '1'},
            UpdateExpression='SET sentiment = :sentiment',
            ExpressionAttributeValues={':sentiment': 'positive'}
        )

if __name__ == '__main__':
    unittest.main()