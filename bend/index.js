// HealthSync Backend Service
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Import Routes
const journalRouter = require('./routes/journal');
const healthDataRouter = require('./routes/healthData');
const narrativeRouter = require('./routes/narrative');
const doctorVisitRouter = require('./routes/doctorVisit');

// Configure environment variables
dotenv.config();

// Initialize express app
const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/journal', journalRouter);
app.use('/api/health-data', healthDataRouter);
app.use('/api/narrative', narrativeRouter);
app.use('/api/doctor-visit', doctorVisitRouter);

// Default route
app.get('/', (req, res) => {
  res.send('HealthSync API is running');
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app; // For testing
