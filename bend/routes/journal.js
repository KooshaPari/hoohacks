// journal.js - API routes for journal entries
const express = require('express');
const router = express.Router();
const JournalController = require('../controllers/JournalController');

const controller = new JournalController();

// Create a new journal entry
router.post('/', async (req, res) => {
  try {
    const result = await controller.createEntry(req.body);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(201).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all journal entries (with optional filtering)
router.get('/', async (req, res) => {
  try {
    const { userId, startDate, endDate } = req.query;
    const result = await controller.getEntries(userId, startDate, endDate);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(200).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get a specific journal entry
router.get('/:id', async (req, res) => {
  try {
    const result = await controller.getEntryById(req.params.id);
    
    if (!result.success) {
      return res.status(404).json({ error: result.error });
    }
    
    res.status(200).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update a journal entry
router.put('/:id', async (req, res) => {
  try {
    const result = await controller.updateEntry(req.params.id, req.body);
    
    if (!result.success) {
      return res.status(400).json({ error: result.error });
    }
    
    res.status(200).json(result.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete a journal entry
router.delete('/:id', async (req, res) => {
  try {
    const result = await controller.deleteEntry(req.params.id);
    
    if (!result.success) {
      return res.status(404).json({ error: result.error });
    }
    
    res.status(204).end();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
