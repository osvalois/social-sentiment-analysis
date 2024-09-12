import { API } from 'aws-amplify';

export async function fetchSentimentData() {
  try {
    const response = await API.get('sentimentApi', '/sentiment');
    return response;
  } catch (error) {
    console.error('Error fetching sentiment data:', error);
    throw error;
  }
}

export async function fetchTweets() {
  try {
    const response = await API.get('sentimentApi', '/tweets');
    return response;
  } catch (error) {
    console.error('Error fetching tweets:', error);
    throw error;
  }
}