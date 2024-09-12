# QuickSight Setup Guide

This document provides step-by-step instructions for setting up Amazon QuickSight for the Social Sentiment Analysis project.

## Prerequisites

1. An AWS account with QuickSight access
2. The Social Sentiment Analysis project deployed in your AWS account

## Steps

1. **Sign up for QuickSight**:
   - Go to the QuickSight console in AWS
   - If you haven't used QuickSight before, you'll need to sign up for it

2. **Create a new dataset**:
   - In the QuickSight dashboard, click on "New analysis"
   - Click "New dataset"
   - Choose "Athena" as the data source

3. **Configure Athena connection**:
   - Select the Athena database that contains your sentiment analysis data
   - Choose the table that stores your sentiment data
   - Click "Edit/Preview data"

4. **Prepare your data**:
   - In the data preparation screen, ensure all necessary fields are present
   - You may need to create calculated fields for percentages or ratios

5. **Create your analysis**:
   - Start with a blank analysis
   - Add visual elements like line charts for sentiment over time, pie charts for sentiment distribution, etc.

6. **Set up filters**:
   - Add date range filters to allow users to select specific time periods

7. **Create a dashboard**:
   - Once your analysis is complete, create a dashboard
   - Add all relevant visualizations to the dashboard

8. **Share your dashboard**:
   - Use QuickSight's sharing features to give access to relevant team members

9. **Set up scheduled refresh**:
   - Configure QuickSight to regularly refresh the data to keep the dashboard up-to-date

## Best Practices

- Use clear and descriptive names for your visualizations
- Include a title and description for your dashboard
- Use appropriate colors to distinguish between positive, negative, and neutral sentiments
- Consider adding interactivity to your dashboard to allow users to drill down into the data

## Troubleshooting

If you encounter issues:
- Ensure your IAM permissions are correctly set up
- Check that QuickSight has access to the necessary AWS resources
- Verify that your Athena queries are optimized for performance

For more detailed information, refer to the [Amazon QuickSight User Guide](https://docs.aws.amazon.com/quicksight/latest/user/welcome.html).