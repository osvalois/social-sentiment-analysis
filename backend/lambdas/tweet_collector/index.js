const AWS = require('aws-sdk');
const { TwitterApi } = require('twitter-api-v2');

const dynamoDB = new AWS.DynamoDB.DocumentClient();
const sqs = new AWS.SQS();

const twitterClient = new TwitterApi(process.env.TWITTER_BEARER_TOKEN);

exports.handler = async (event) => {
  try {
    const tweets = await collectTweets();
    await storeTweetsInDynamoDB(tweets);
    await sendTweetsToSQS(tweets);
    
    return {
      statusCode: 200,
      body: JSON.stringify({ message: `Successfully processed ${tweets.length} tweets` }),
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Error processing tweets', error: error.message }),
    };
  }
};

async function collectTweets() {
  const query = 'AWS (lang:en)';
  const response = await twitterClient.v2.search(query, {
    max_results: 100,
    'tweet.fields': ['created_at', 'public_metrics'],
  });
  
  return response.tweets;
}

async function storeTweetsInDynamoDB(tweets) {
  const putRequests = tweets.map(tweet => ({
    PutRequest: {
      Item: {
        id: tweet.id,
        text: tweet.text,
        created_at: tweet.created_at,
        retweet_count: tweet.public_metrics.retweet_count,
        reply_count: tweet.public_metrics.reply_count,
        like_count: tweet.public_metrics.like_count,
        quote_count: tweet.public_metrics.quote_count,
      }
    }
  }));
  
  const params = {
    RequestItems: {
      [process.env.DYNAMODB_TABLE_NAME]: putRequests
    }
  };
  
  await dynamoDB.batchWrite(params).promise();
}

async function sendTweetsToSQS(tweets) {
  const entries = tweets.map((tweet, index) => ({
    Id: `${index}`,
    MessageBody: JSON.stringify(tweet),
  }));

  const params = {
    Entries: entries,
    QueueUrl: process.env.SQS_QUEUE_URL,
  };

  await sqs.sendMessageBatch(params).promise();
}