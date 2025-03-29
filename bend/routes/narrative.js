// narrative.js - API routes for health narratives
const express = require('express');
const router = express.Router();
const NarrativeController = require('../controllers/NarrativeController');

const controller = new NarrativeController();

// Generate a weekly health narrative
router.post('/weekly', async (req, res) => {
  try {
    const { userId } = req.body;
    
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }
    
    const result = await controller.generateWeeklyNarrative(userId);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(201).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Generate a pattern analysis for a specific symptom
router.post('/pattern', async (req, res) => {
  try {
    const { userId, symptom } = req.body;
    
    if (!userId || !symptom) {
      return res.status(400).json({ error: 'userId and symptom are required' });
    }
    
    const result = await controller.generatePatternAnalysis(userId, symptom);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(201).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get existing narratives
router.get('/', async (req, res) => {
  try {
    const { userId, type } = req.query;
    
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }
    
    const result = await controller.getNarratives(userId, type);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(200).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get a specific narrative
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await controller.dataStore.getById(id);
    
    if (!result) {
      return res.status(404).json({ error: 'Narrative not found' });
    }
    
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
