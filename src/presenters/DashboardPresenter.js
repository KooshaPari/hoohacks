import HealthDataController from '../controllers/HealthDataController';

/**
 * DashboardPresenter - Handles presenting data for the Dashboard view
 */
class DashboardPresenter {
  constructor() {
    this.healthDataController = new HealthDataController();
  }

  /**
   * Get dashboard data
   * @returns {Object} - Dashboard data
   */
  getDashboardData() {
    const today = new Date();
    const startDate = new Date();
    startDate.setDate(today.getDate() - 7);
    
    const summary = this.healthDataController.getHealthSummary(startDate, today);
    const recentEntries = this.healthDataController.healthData.getJournalEntriesInRange(
      startDate, today
    ).sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp)).slice(0, 3);
    
    return {
      summary,
      recentEntries,
      weeklyNarrative: this.healthDataController.getWeeklyNarrative()
    };
  }
}

export default DashboardPresenter;
