# Social Sentiment Analysis

This project provides real-time sentiment analysis of social media posts related to specific topics using AWS services.

## Architecture

![Architecture Diagram](https://via.placeholder.com/800x400.png?text=Architecture+Diagram)

For a detailed explanation of the architecture, see [architecture.md](docs/architecture.md).

## Prerequisites

- AWS Account
- Node.js (v14 or later)
- AWS CLI configured
- Terraform installed

## Setup

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/social-sentiment-analysis.git
   cd social-sentiment-analysis
   ```

2. Set up the local environment:
   ```
   ./scripts/setup-local-env.sh
   ```

3. Configure AWS credentials:
   ```
   aws configure
   ```

4. Deploy the infrastructure:
   ```
   ./scripts/deploy.sh
   ```

## Usage

After deployment, you can access the dashboard at the CloudFront URL provided in the deployment output.

For API documentation, see [api-spec.md](docs/api-spec.md).

## Development

- Frontend code is in the `frontend/` directory
- Backend Lambda functions are in the `backend/lambdas/` directory
- Infrastructure as Code (Terraform) is in the `terraform/` directory

## Testing

Run frontend tests:
```
cd frontend
npm test
```

Run backend tests:
```
cd backend
npm test
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.