const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Mock data
const systemInfo = {
  cpu: {
    usage: 45.2,
    cores: 8,
    temperature: 65.5
  },
  memory: {
    total: 16384,
    used: 8192,
    available: 8192,
    percentage: 50.0
  },
  disk: {
    total: 512000,
    used: 256000,
    available: 256000,
    percentage: 50.0
  }
};

const processes = [
  { id: 1234, name: 'chrome.exe', cpu: 15.5, memory: 512, status: 'running' },
  { id: 5678, name: 'node.exe', cpu: 8.2, memory: 256, status: 'running' },
  { id: 9012, name: 'explorer.exe', cpu: 3.1, memory: 128, status: 'running' }
];

const networkInfo = {
  interface: 'Ethernet',
  ip: '192.168.1.100',
  upload: 1024,
  download: 2048,
  latency: 12
};

// API Routes
app.get('/api/system', (req, res) => {
  res.json({
    success: true,
    data: systemInfo,
    timestamp: new Date().toISOString()
  });
});

app.get('/api/processes', (req, res) => {
  res.json({
    success: true,
    data: processes,
    timestamp: new Date().toISOString()
  });
});

app.get('/api/network', (req, res) => {
  res.json({
    success: true,
    data: networkInfo,
    timestamp: new Date().toISOString()
  });
});

app.post('/api/processes/:id/kill', (req, res) => {
  const { id } = req.params;
  res.json({
    success: true,
    message: `Process ${id} killed successfully`,
    timestamp: new Date().toISOString()
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Server is running',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    timestamp: new Date().toISOString()
  });
});

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found',
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
