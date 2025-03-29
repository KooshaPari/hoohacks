// Export all controllers from a single file for convenient imports

const UserController = require('./UserController');
const JournalController = require('./JournalController');
const HealthDataController = require('./HealthDataController');
const DoctorVisitController = require('./DoctorVisitController');

module.exports = {
  UserController,
  JournalController,
  HealthDataController,
  DoctorVisitController
};
