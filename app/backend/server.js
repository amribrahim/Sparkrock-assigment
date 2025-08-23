const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// CORS configuration
const corsOptions = {
  origin: process.env.CORS_ORIGIN || '*',
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok',
    environment: NODE_ENV,
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Hello endpoint
app.get('/api/hello', (req, res) => {
  res.json({ 
    message: 'Hello from Sparkrock API!',
    environment: NODE_ENV,
    timestamp: new Date().toISOString()
  });
});

// Environment info endpoint
app.get('/api/info', (req, res) => {
  res.json({
    name: 'sparkrock-api',
    version: '1.0.0',
    environment: NODE_ENV,
    port: PORT,
    nodeVersion: process.version,
    platform: process.platform
  });
});

app.listen(PORT, () => {
  console.log(`🚀 API listening on port ${PORT}`);
  console.log(`🌍 Environment: ${NODE_ENV}`);
  console.log(`⏰ Started at: ${new Date().toISOString()}`);
});
