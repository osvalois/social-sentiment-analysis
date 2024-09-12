import React from 'react';
import { Typography, Container } from '@mui/material';
import SentimentDashboard from '../components/SentimentDashboard';

function Home() {
  return (
    <Container>
      <Typography variant="h3" gutterBottom>Welcome to Social Sentiment Analysis</Typography>
      <Typography variant="body1" paragraph>
        This dashboard provides real-time sentiment analysis of tweets related to AWS and cloud computing.
      </Typography>
      <SentimentDashboard />
    </Container>
  );
}

export default Home;