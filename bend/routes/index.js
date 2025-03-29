const express = require('express');
const userRoutes = require('./userRoutes');
const journalRoutes = require('./journalRoutes');
const healthDataRoutes = require('./healthDataRoutes');
const doctorVisitRoutes = require('./doctorVisitRoutes');

const router = express.Router();

// API routes
router.use('/api/auth', userRoutes);
router.use('/api', journalRoutes);
router.use('/api', healthDataRoutes);
router.use('/api', doctorVisitRoutes);

// API documentation
router.get('/api', (req, res) => {
  res.json({
    message: 'HealthSync API',
    version: '1.0.0',
    endpoints: {
      auth: {
        register: 'POST /api/auth/register',
        login: 'POST /api/auth/login'
      },
      users: {
        getProfile: 'GET /api/users/:userId',
        updateProfile: 'PUT /api/users/:userId'
      },
      journal: {
        create: 'POST /api/users/:userId/journal',
        getAll: 'GET /api/users/:userId/journal',
        getOne: 'GET /api/users/:userId/journal/:entryId',
        update: 'PUT /api/users/:userId/journal/:entryId',
        delete: 'DELETE /api/users/:userId/journal/:entryId'
      },
      healthMetrics: {
        add: 'POST /api/users/:userId/metrics',
        get: 'GET /api/users/:userId/metrics'
      },
      healthSummary: {
        get: 'GET /api/users/:userId/summary',
        getWeeklyNarrative: 'GET /api/users/:userId/weekly-narrative',
        analyzeSymptoms: 'GET /api/users/:userId/symptom-analysis'
      },
      doctorVisits: {
        create: 'POST /api/users/:userId/doctor-visits',
        getAll: 'GET /api/users/:userId/doctor-visits',
        getOne: 'GET /api/users/:userId/doctor-visits/:summaryId',
        update: 'PUT /api/users/:userId/doctor-visits/:summaryId',
        generate: 'POST /api/users/:userId/doctor-visits/generate',
        addQuestion: 'POST /api/users/:userId/doctor-visits/:summaryId/questions',
        share: 'POST /api/users/:userId/doctor-visits/:summaryId/share'
      }
    }
  });
});

module.exports = router;
