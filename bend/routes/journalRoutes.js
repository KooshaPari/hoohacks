const express = require('express');
const journalController = require('../controllers/journalController');
const userController = require('../controllers/userController');

const router = express.Router();

// Protect all routes
router.use(userController.protect);

router
  .route('/')
  .get(journalController.getAllEntries)
  .post(journalController.createEntry);

router
  .route('/:id')
  .get(journalController.getEntry)
  .patch(journalController.updateEntry)
  .delete(journalController.deleteEntry);

router.get('/stats/daily', journalController.getStats);

module.exports = router;
