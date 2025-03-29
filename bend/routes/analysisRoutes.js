const express = require('express');
const analysisController = require('../controllers/analysisController');
const userController = require('../controllers/userController');

const router = express.Router();

// Protect all routes
router.use(userController.protect);

router.get('/weekly-summary', analysisController.getWeeklySummary);
router.get('/pattern-analysis/:symptom', analysisController.getPatternAnalysis);
router.get('/doctor-visit-summary', analysisController.getDoctorVisitSummary);

module.exports = router;
