import React from 'react';
import { Link } from 'react-router-dom';
import { AppBar, Toolbar, Typography, Button } from '@mui/material';

function Header({ user, signOut }) {
  return (
    <AppBar position="static">
      <Toolbar>
        <Typography variant="h6" style={{ flexGrow: 1 }}>
          Social Sentiment Analysis
        </Typography>
        <Button color="inherit" component={Link} to="/">Home</Button>
        <Button color="inherit" component={Link} to="/analysis">Analysis</Button>
        <Button color="inherit" component={Link} to="/about">About</Button>
        <Typography variant="subtitle1" style={{ marginRight: '10px' }}>
          Welcome, {user.username}
        </Typography>
        <Button color="inherit" onClick={signOut}>Sign Out</Button>
      </Toolbar>
    </AppBar>
  );
}

export default Header;