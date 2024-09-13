import React from 'react';
import ReactDOM from 'react-dom/client';
import { ThemeProvider, createTheme, CssBaseline } from '@mui/material';
import { Typography, Container, Box, Grid, Button, useMediaQuery,  } from '@mui/material';
import { styled, keyframes } from '@mui/system';
import { Zap, Cpu, BarChart as BarChartIcon, TrendingUp, Bird } from 'lucide-react';
import { motion } from 'framer-motion';
import { useSpring, animated, config } from 'react-spring';
import { Textfit } from 'react-textfit';
import CountUp from 'react-countup';
import { Toaster, toast } from 'react-hot-toast';

// Color palette
const colors = {
  primary: '#6C5CE7',
  secondary: '#2D3436',
  accent: '#00CEC9',
  background: '#0984E3',
  highlight: '#FD79A8',
  white: '#FFFFFF',
  dark: '#2D3436',
};

// Create a theme
const theme = createTheme({
  palette: {
    primary: {
      main: colors.primary,
    },
    secondary: {
      main: colors.secondary,
    },
    background: {
      default: colors.background,
    },
  },
});

// Styles
const glassStyle = {
  background: 'rgba(255, 255, 255, 0.1)',
  backdropFilter: 'blur(10px)',
  border: '1px solid rgba(255, 255, 255, 0.2)',
  boxShadow: '0 8px 32px 0 rgba(31, 38, 135, 0.37)',
};

const ModernContainer = styled(Box)(({ theme }) => ({
  ...glassStyle,
  borderRadius: '30px',
  padding: theme.spacing(6),
  position: 'relative',
  overflow: 'hidden',
  transition: 'all 0.3s ease-in-out',
  '&:hover': {
    boxShadow: `0 12px 48px 0 rgba(31, 38, 135, 0.5)`,
    transform: 'translateY(-5px)',
  },
}));

const GradientText = styled(animated(Textfit))({
  backgroundClip: 'text',
  WebkitBackgroundClip: 'text',
  color: 'transparent',
  display: 'inline-block',
  fontWeight: 900,
});

const FeatureCard = styled(motion.div)(({ theme }) => ({
  ...glassStyle,
  borderRadius: '20px',
  padding: theme.spacing(3),
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
  textAlign: 'center',
  transition: 'all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1)',
  cursor: 'pointer',
  '&:hover': {
    boxShadow: `0 14px 28px rgba(0,0,0,0.25), 0 10px 10px rgba(0,0,0,0.22)`,
    transform: 'translateY(-5px)',
  },
}));

const StyledButton = styled(Button)(({ theme }) => ({
  background: `linear-gradient(45deg, ${colors.accent}, ${colors.primary})`,
  color: colors.white,
  borderRadius: '25px',
  padding: '12px 24px',
  fontSize: '1rem',
  fontWeight: 'bold',
  textTransform: 'none',
  transition: 'all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1)',
  '&:hover': {
    background: `linear-gradient(45deg, ${colors.primary}, ${colors.accent})`,
    transform: 'scale(1.05) translateY(-2px)',
    boxShadow: `0 7px 14px rgba(0,0,0,0.2), 0 5px 5px rgba(0,0,0,0.1)`,
  },
}));

const moveBackground = keyframes`
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
`;

const AnimatedBackground = styled(Box)({
  background: `linear-gradient(-45deg, ${colors.background}, ${colors.secondary}, ${colors.primary}, ${colors.accent})`,
  backgroundSize: '400% 400%',
  animation: `${moveBackground} 30s ease infinite`,
  minHeight: '100vh',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
});

// ProductInfo component
function ProductInfo() {
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

  const gradientProps = useSpring({
    from: { backgroundPosition: '0% 50%' },
    to: { backgroundPosition: '100% 50%' },
    config: { duration: 5000, tension: 120, friction: 14 },
    loop: true,
  });

  const features = [
    { icon: Zap, title: "Lightning Fast", desc: "Process thousands of posts instantly" },
    { icon: Cpu, title: "AI-Powered", desc: "Leveraging state-of-the-art ML" },
    { icon: BarChartIcon, title: "Deep Insights", desc: "Uncover hidden trends" },
    { icon: TrendingUp, title: "Predictive", desc: "Forecast sentiment shifts" }
  ];

  const handleStartTrial = () => {
    toast.success('Trial started successfully!', {
      icon: '🚀',
      style: {
        borderRadius: '10px',
        background: colors.dark,
        color: colors.white,
      },
    });
  };

  return (
    <Container maxWidth="lg" sx={{ py: 8 }}>
      <ModernContainer>
        <Grid container spacing={4} alignItems="center">
          <Grid item xs={12} md={6} sx={{ zIndex: 1 }}>
            <GradientText
              mode="single"
              min={24}
              max={isMobile ? 36 : 48}
              style={{
                ...gradientProps,
                backgroundImage: `linear-gradient(45deg, ${colors.accent}, ${colors.primary}, ${colors.highlight})`,
                backgroundSize: '200% auto',
                marginBottom: theme.spacing(4),
              }}
            >
              Sentinel
            </GradientText>
            <Typography variant="body1" sx={{ color: colors.white, lineHeight: 1.8, zIndex: 1, position: 'relative' }}>
              Revolutionize your social media strategy with our cutting-edge sentiment analysis tool. Sentinel harnesses the power of advanced AI to decode the pulse of your audience in real-time.
            </Typography>
            <Box sx={{ mt: 4 }}>
              <Grid container spacing={2}>
                {features.map((feature, index) => (
                  <Grid item xs={6} key={index}>
                    <FeatureCard
                      whileHover={{ scale: 1.05, rotate: 1 }}
                      whileTap={{ scale: 0.95 }}
                    >
                      <feature.icon size={40} color={colors.accent} />
                      <Typography variant="h6" sx={{ mt: 2, color: colors.white }}>
                        {feature.title}
                      </Typography>
                      <Typography variant="body2" sx={{ color: colors.white, opacity: 0.8 }}>
                        {feature.desc}
                      </Typography>
                    </FeatureCard>
                  </Grid>
                ))}
              </Grid>
            </Box>

          </Grid>
          <Grid item xs={12} md={6} sx={{ zIndex: 1 }}>
            <Box
              sx={{
                width: '100%',
                height: '400px',
                ...glassStyle,
                borderRadius: '30px',
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                overflow: 'hidden',
                position: 'relative',
              }}
            >
              <Typography variant="h5" sx={{ color: colors.white, zIndex: 1, fontWeight: 'bold' }}>
                Interactive Demo
              </Typography>
              <Box
                component={motion.div}
                initial={{ opacity: 0 }}
                animate={{ opacity: 0.3 }}
                transition={{ duration: 1 }}
                sx={{
                  position: 'absolute',
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  background: `url('/api/placeholder/800/600') center/cover no-repeat`,
                  filter: 'blur(5px)',
                }}
              />
            </Box>
            <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
              <StyledButton startIcon={<Bird />} onClick={handleStartTrial}>
                Start
              </StyledButton>
            </Box>
          </Grid>
        </Grid>
      </ModernContainer>
    </Container>
  );
}

// Main component
function ModernProductInfo() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <AnimatedBackground>
        <ProductInfo />
        <Toaster position="bottom-center" />
      </AnimatedBackground>
    </ThemeProvider>
  );
}

// Render the app using createRoot
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <ModernProductInfo />
  </React.StrictMode>
);

export default ModernProductInfo;