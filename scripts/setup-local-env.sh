#!/bin/bash

set -e

# Install dependencies
npm install -g aws-cdk

# Set up backend
cd backend
npm install

# Set up frontend
cd ../frontend
npm install

# Set up local environment variables
echo "REACT_APP_API_ENDPOINT=http://localhost:3000/dev" > .env.local
echo "REACT_APP_REGION=us-west-2" >> .env.local

echo "Local environment setup complete. Make sure to set up your AWS credentials."
echo "To start the frontend locally, run: npm start"
echo "To start the backend locally, use: serverless offline"