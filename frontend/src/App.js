import React from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import { Amplify } from 'aws-amplify';
import { Authenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';

import Header from './components/Header';
import Home from './pages/Home';
import Analysis from './pages/Analysis';
import About from './pages/About';

import awsconfig from './aws-exports';
Amplify.configure(awsconfig);

function App() {
  return (
    <Authenticator>
      {({ signOut, user }) => (
        <Router>
          <div className="App">
            <Header user={user} signOut={signOut} />
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/analysis" element={<Analysis />} />
              <Route path="/about" element={<About />} />
            </Routes>
          </div>
        </Router>
      )}
    </Authenticator>
  );
}

export default App;