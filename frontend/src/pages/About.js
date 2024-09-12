import React from 'react';
import { Typography, Container, Paper } from '@mui/material';

function About() {
  return (
    <Container>
      <Paper elevation={3} style={{ padding: '20px', marginTop: '20px' }}>
        <Typography variant="h3" gutterBottom>About This Project</Typography>
        <Typography variant="body1" paragraph>
          This Social Sentiment Analysis project is designed to provide real-time insights into public sentiment
          regarding AWS and cloud computing topics on Twitter.
        </Typography>
        <Typography variant="body1" paragraph>
          We use advanced natural language processing techniques powered by Amazon Bedrock to analyze tweets
          and categorize them as positive, negative, or neutral.
        </Typography>
        <Typography variant="body1">
          The project leverages various AWS services including Lambda, DynamoDB, API Gateway, and Amplify
          to create a scalable and responsive application.
        </Typography>
      </Paper>
    </Container>
  );
}

export default About;