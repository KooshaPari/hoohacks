// Export all presenters from a single file for convenient imports

const UserPresenter = require('./UserPresenter');
const JournalPresenter = require('./JournalPresenter');
const HealthDataPresenter = require('./HealthDataPresenter');
const DoctorVisitPresenter = require('./DoctorVisitPresenter');

module.exports = {
  UserPresenter,
  JournalPresenter,
  HealthDataPresenter,
  DoctorVisitPresenter
};
