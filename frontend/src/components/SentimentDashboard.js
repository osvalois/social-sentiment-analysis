import React, { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Card, CardContent, Typography, Grid, Box } from '@mui/material';
import { styled, keyframes } from '@mui/system';
import { fetchSentimentData } from '../utils/api';

// Color palette (matching the About component)
const colors = {
  primary: '#6a11cb',
  secondary: '#2575fc',
  accent: '#ffa07a',
  text: '#ffffff',
  background: '#0a0c1b',
  positive: '#4CAF50',
  negative: '#F44336',
  neutral: '#FFC107',
};

// Keyframe animations
const float = keyframes`
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
`;

// Styled components
const DashboardContainer = styled(Box)(({ theme }) => ({
  padding: theme.spacing(3),
  background: `linear-gradient(135deg, ${colors.primary}20, ${colors.secondary}20)`,
  minHeight: '100vh',
}));

const GlassCard = styled(Card)(({ theme }) => ({
  background: 'rgba(255, 255, 255, 0.05)',
  backdropFilter: 'blur(10px)',
  borderRadius: theme.shape.borderRadius * 2,
  border: '1px solid rgba(255, 255, 255, 0.1)',
  boxShadow: `0 8px 32px 0 ${colors.primary}50`,
  transition: 'all 0.3s ease-in-out',
  '&:hover': {
    transform: 'translateY(-5px)',
    boxShadow: `0 12px 48px 0 ${colors.primary}70`,
  },
}));

const ChartTitle = styled(Typography)(({ theme }) => ({
  color: colors.text,
  fontWeight: 600,
  textAlign: 'center',
  marginBottom: theme.spacing(2),
  textShadow: `2px 2px 4px ${colors.primary}50`,
}));

const CustomTooltip = styled(({ active, payload, label, ...props }) => {
  if (active && payload && payload.length) {
    return (
      <Box {...props}>
        <Typography variant="body2" sx={{ color: colors.text }}>{`Date: ${label}`}</Typography>
        {payload.map((entry, index) => (
          <Typography key={index} variant="body2" sx={{ color: entry.color }}>
            {`${entry.name}: ${entry.value}`}
          </Typography>
        ))}
      </Box>
    );
  }
  return null;
})(({ theme }) => ({
  background: 'rgba(255, 255, 255, 0.1)',
  backdropFilter: 'blur(10px)',
  border: '1px solid rgba(255, 255, 255, 0.18)',
  padding: theme.spacing(2),
  borderRadius: theme.shape.borderRadius,
  boxShadow: '0 4px 30px rgba(0, 0, 0, 0.1)',
}));

function SentimentDashboard() {
  const [sentimentData, setSentimentData] = useState([]);

  useEffect(() => {
    async function loadSentimentData() {
      const data = await fetchSentimentData();
      setSentimentData(data);
    }
    loadSentimentData();
  }, []);

  return (
    <DashboardContainer>
      <Typography variant="h4" gutterBottom sx={{ color: colors.text, textAlign: 'center', mb: 4 }}>
        Sentiment Analysis Dashboard
      </Typography>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <GlassCard>
            <CardContent>
              <ChartTitle variant="h6">Sentiment Over Time</ChartTitle>
              <ResponsiveContainer width="100%" height={400}>
                <LineChart data={sentimentData}>
                  <CartesianGrid strokeDasharray="3 3" stroke={`${colors.text}20`} />
                  <XAxis dataKey="date" stroke={colors.text} />
                  <YAxis stroke={colors.text} />
                  <Tooltip content={<CustomTooltip />} />
                  <Legend wrapperStyle={{ color: colors.text }} />
                  <Line type="monotone" dataKey="positive" stroke={colors.positive} strokeWidth={2} dot={{ r: 4 }} activeDot={{ r: 8 }} />
                  <Line type="monotone" dataKey="negative" stroke={colors.negative} strokeWidth={2} dot={{ r: 4 }} activeDot={{ r: 8 }} />
                  <Line type="monotone" dataKey="neutral" stroke={colors.neutral} strokeWidth={2} dot={{ r: 4 }} activeDot={{ r: 8 }} />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </GlassCard>
        </Grid>
        {/* Add more cards for other visualizations */}
        <Grid item xs={12} md={6}>
          <GlassCard sx={{ height: '100%' }}>
            <CardContent>
              <ChartTitle variant="h6">Sentiment Distribution</ChartTitle>
              {/* Add a pie chart or donut chart here */}
            </CardContent>
          </GlassCard>
        </Grid>
        <Grid item xs={12} md={6}>
          <GlassCard sx={{ height: '100%' }}>
            <CardContent>
              <ChartTitle variant="h6">Top Keywords</ChartTitle>
              {/* Add a word cloud or bar chart for top keywords */}
            </CardContent>
          </GlassCard>
        </Grid>
      </Grid>
    </DashboardContainer>
  );
}

export default SentimentDashboard;