// healthData.js - API routes for health data
const express = require('express');
const router = express.Router();
const HealthDataController = require('../controllers/HealthDataController');

const controller = new HealthDataController();

// Record new health data
router.post('/', async (req, res) => {
  try {
    const result = await controller.recordHealthData(req.body);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(201).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get health data (with optional filtering)
router.get('/', async (req, res) => {
  try {
    const { userId, type, startDate, endDate } = req.query;
    
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }
    
    const result = await controller.getHealthData(userId, type, startDate, endDate);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(200).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get averages for a specific health metric
router.get('/averages', async (req, res) => {
  try {
    const { userId, type, startDate, endDate } = req.query;
    
    if (!userId || !type) {
      return res.status(400).json({ error: 'userId and type are required' });
    }
    
    const result = await controller.calculateAverages(userId, type, startDate, endDate);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(200).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Bulk import health data (e.g., from Apple Health or Fitbit)
router.post('/bulk-import', async (req, res) => {
  try {
    const { userId, data, source } = req.body;
    
    if (!userId || !data || !Array.isArray(data) || !source) {
      return res.status(400).json({ 
        error: 'userId, data array, and source are required' 
      });
    }
    
    const result = await controller.bulkImportHealthData(userId, data, source);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(200).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
