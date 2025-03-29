// Export all models from a single file for convenient imports

const User = require('./User');
const HealthProfile = require('./HealthProfile');
const JournalEntry = require('./JournalEntry');
const HealthMetric = require('./HealthMetric');
const DoctorVisit = require('./DoctorVisit');

module.exports = {
  User,
  HealthProfile,
  JournalEntry,
  HealthMetric,
  DoctorVisit
};
