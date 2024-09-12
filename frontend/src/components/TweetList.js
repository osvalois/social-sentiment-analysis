import React, { useState, useEffect } from 'react';
import { List, ListItem, ListItemText, Typography, Chip } from '@mui/material';
import { fetchTweets } from '../utils/api';

function TweetList() {
  const [tweets, setTweets] = useState([]);

  useEffect(() => {
    async function loadTweets() {
      const data = await fetchTweets();
      setTweets(data);
    }
    loadTweets();
  }, []);

  return (
    <div>
      <Typography variant="h5" gutterBottom>Recent Tweets</Typography>
      <List>
        {tweets.map((tweet) => (
          <ListItem key={tweet.id} divider>
            <ListItemText
              primary={tweet.text}
              secondary={
                <>
                  <Typography component="span" variant="body2" color="textPrimary">
                    {new Date(tweet.created_at).toLocaleString()}
                  </Typography>
                  <Chip
                    label={tweet.sentiment}
                    color={tweet.sentiment === 'positive' ? 'success' : tweet.sentiment === 'negative' ? 'error' : 'default'}
                    size="small"
                    style={{ marginLeft: '10px' }}
                  />
                </>
              }
            />
          </ListItem>
        ))}
      </List>
    </div>
  );
}

export default TweetList;