import React from 'react';
import { Typography, Container, Grid } from '@mui/material';
import SentimentDashboard from '../components/SentimentDashboard';
import TweetList from '../components/TweetList';

function Analysis() {
  return (
    <Container>
      <Typography variant="h3" gutterBottom>Detailed Analysis</Typography>
      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <SentimentDashboard />
        </Grid>
        <Grid item xs={12} md={4}>
          <TweetList />
        </Grid>
      </Grid>
    </Container>
  );
}

export default Analysis;