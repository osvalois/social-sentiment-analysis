const AWS = require('aws-sdk-mock');
const { handler } = require('../lambdas/tweet_collector/index');

jest.mock('twitter-v2');

describe('Tweet Collector Lambda', () => {
  beforeEach(() => {
    AWS.mock('DynamoDB.DocumentClient', 'batchWrite', (params, callback) => {
      callback(null, {});
    });
    AWS.mock('SQS', 'sendMessageBatch', (params, callback) => {
      callback(null, {});
    });
  });

  afterEach(() => {
    AWS.restore('DynamoDB.DocumentClient');
    AWS.restore('SQS');
  });

  test('should process tweets successfully', async () => {
    const mockTweets = [
      { id: '1', text: 'Test tweet 1', created_at: '2023-05-01T12:00:00Z', public_metrics: { retweet_count: 5, reply_count: 2, like_count: 10, quote_count: 1 } },
      { id: '2', text: 'Test tweet 2', created_at: '2023-05-01T13:00:00Z', public_metrics: { retweet_count: 3, reply_count: 1, like_count: 7, quote_count: 0 } },
    ];

    require('twitter-v2').mockImplementation(() => ({
      get: jest.fn().mockResolvedValue({ data: mockTweets })
    }));

    const result = await handler({});

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body).message).toContain('Successfully processed 2 tweets');
  });

  test('should handle errors gracefully', async () => {
    require('twitter-v2').mockImplementation(() => ({
      get: jest.fn().mockRejectedValue(new Error('API Error'))
    }));

    const result = await handler({});

    expect(result.statusCode).toBe(500);
    expect(JSON.parse(result.body).message).toBe('Error processing tweets');
  });
});