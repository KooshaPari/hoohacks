// doctorVisit.js - API routes for doctor visit summaries
const express = require('express');
const router = express.Router();
const DoctorVisitController = require('../controllers/DoctorVisitController');

const controller = new DoctorVisitController();

// Generate a doctor visit summary
router.post('/', async (req, res) => {
  try {
    const { userId, days, questions } = req.body;
    
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }
    
    const options = {
      days: days || 30,
      questions
    };
    
    const result = await controller.generateDoctorVisitSummary(userId, options);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(201).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add a question to a doctor visit summary
router.post('/:id/questions', async (req, res) => {
  try {
    const { id } = req.params;
    const { question } = req.body;
    
    if (!question) {
      return res.status(400).json({ error: 'question is required' });
    }
    
    const result = await controller.addQuestion(id, question);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(200).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Generate a shareable text version of a doctor visit summary
router.get('/:id/shareable', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await controller.generateShareableText(id);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(200).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
