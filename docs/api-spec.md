# API Specification

This document outlines the API endpoints for the Social Sentiment Analysis project.

## Base URL

`https://api.example.com/v1`

## Endpoints

### Get Sentiment Analysis

Retrieves sentiment analysis data for a specified time range.

- **URL**: `/sentiment`
- **Method**: `GET`
- **Auth Required**: Yes
- **Query Parameters**:
  - `start_date` (optional): Start date for analysis (format: YYYY-MM-DD)
  - `end_date` (optional): End date for analysis (format: YYYY-MM-DD)
- **Success Response**:
  - **Code**: 200
  - **Content**: 
    ```json
    {
      "sentiment_data": [
        {
          "date": "2023-05-01",
          "positive": 45,
          "negative": 15,
          "neutral": 40
        },
        ...
      ]
    }
    ```

### Get Recent Tweets

Retrieves recent analyzed tweets.

- **URL**: `/tweets`
- **Method**: `GET`
- **Auth Required**: Yes
- **Query Parameters**:
  - `limit` (optional): Number of tweets to return (default: 20, max: 100)
- **Success Response**:
  - **Code**: 200
  - **Content**: 
    ```json
    {
      "tweets": [
        {
          "id": "1234567890",
          "text": "Tweet text here",
          "created_at": "2023-05-01T12:00:00Z",
          "sentiment": "positive"
        },
        ...
      ]
    }
    ```

## Error Responses

- **Unauthorized**:
  - **Code**: 401
  - **Content**: `{ "error": "Unauthorized" }`

- **Bad Request**:
  - **Code**: 400
  - **Content**: `{ "error": "Invalid parameters" }`

- **Internal Server Error**:
  - **Code**: 500
  - **Content**: `{ "error": "Internal server error" }`

## Rate Limiting

API requests are limited to 100 requests per minute per user.

## Authentication

This API uses Amazon Cognito for authentication. Include the Cognito token in the Authorization header of each request:

```
Authorization: Bearer YOUR_COGNITO_TOKEN
```