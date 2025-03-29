const express = require('express');
const healthDataController = require('../controllers/healthDataController');
const userController = require('../controllers/userController');

const router = express.Router();

// Protect all routes
router.use(userController.protect);

router
  .route('/')
  .get(healthDataController.getAllHealthData)
  .post(healthDataController.createHealthData);

router
  .route('/:id')
  .get(healthDataController.getHealthData)
  .patch(healthDataController.updateHealthData)
  .delete(healthDataController.deleteHealthData);

router.get('/stats/sleep', healthDataController.getSleepStats);
router.get('/stats/activity', healthDataController.getActivityStats);
router.get('/stats/heartRate', healthDataController.getHeartRateStats);

module.exports = router;
