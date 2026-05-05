const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// middleware
app.use(cors());
app.use(express.json());

// auth middleware
app.use((req, res, next) => {
  const auth = req.headers.authorization;
  if (auth !== 'admin') {
    return res.status(401).json({
      success: false,
      message: 'Unauthorized',
      timestamp: new Date().toISOString()
    });
  }
  next();
});

/* =========================
   MOCK DATA (SAFE VERSION)
========================= */

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

/* ❌ FIX: jangan hardcode IP */
const networkInfo = {
  interface: 'Ethernet',
  upload: 1024,
  download: 2048,
  latency: 12
};

/* =========================
   API ROUTES
========================= */

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

/* =========================
   ERROR HANDLING
========================= */

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found',
    timestamp: new Date().toISOString()
  });
});

/* =========================
   START SERVER (IMPORTANT FIX)
========================= */

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});