import HealthDataController from '../controllers/HealthDataController';

/**
 * WeeklySummaryPresenter - Handles presenting data for the Weekly Summary view
 */
class WeeklySummaryPresenter {
  constructor() {
    this.healthDataController = new HealthDataController();
  }

  /**
   * Get weekly summary data
   * @returns {Object} - Weekly summary data
   */
  getWeeklySummaryData() {
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(endDate.getDate() - 7);
    
    const summary = this.healthDataController.getHealthSummary(startDate, endDate);
    const narrative = this.healthDataController.getWeeklyNarrative();
    
    // Get daily data for charts
    const sleepData = this.healthDataController.healthData.getHealthMetricsInRange('sleep', startDate, endDate);
    const activityData = this.healthDataController.healthData.getHealthMetricsInRange('activity', startDate, endDate);
    const journalEntries = this.healthDataController.healthData.getJournalEntriesInRange(startDate, endDate);
    
    // Format chart data
    const chartData = {
      labels: this.getDayLabels(startDate, endDate),
      sleep: this.formatDailyData(sleepData, 'duration'),
      steps: this.formatDailyData(activityData, 'steps'),
      mood: this.formatDailyData(journalEntries, 'mood'),
      energy: this.formatDailyData(journalEntries, 'energy')
    };
    
    return {
      summary,
      narrative,
      chartData
    };
  }

  /**
   * Get day labels for chart
   * @param {Date} startDate - Start date
   * @param {Date} endDate - End date
   * @returns {Array} - Array of day labels
   */
  getDayLabels(startDate, endDate) {
    const days = [];
    const currentDate = new Date(startDate);
    
    while (currentDate <= endDate) {
      days.push(this.formatDateLabel(currentDate));
      currentDate.setDate(currentDate.getDate() + 1);
    }
    
    return days;
  }

  /**
   * Format daily data for charts
   * @param {Array} data - Array of data entries
   * @param {String} valueKey - The key to extract values from
   * @returns {Array} - Formatted daily values
   */
  formatDailyData(data, valueKey) {
    const dayValues = {};
    
    // Initialize with empty values
    const days = this.getDayLabels(
      new Date(new Date().setDate(new Date().getDate() - 7)),
      new Date()
    );
    days.forEach(day => {
      dayValues[day] = null;
    });
    
    // Fill in actual values
    data.forEach(item => {
      const date = this.formatDateLabel(new Date(item.timestamp));
      if (dayValues[date] !== undefined) {
        // For journal entries, use the value directly
        if (valueKey === 'mood' || valueKey === 'energy') {
          dayValues[date] = item[valueKey];
        } else {
          // For health metrics, access the property
          dayValues[date] = item[valueKey];
        }
      }
    });
    
    return Object.values(dayValues);
  }

  /**
   * Format date as a label (e.g., "Mon 3/29")
   * @param {Date} date - The date to format
   * @returns {String} - Formatted date label
   */
  formatDateLabel(date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return `${days[date.getDay()]} ${date.getMonth() + 1}/${date.getDate()}`;
  }
}

export default WeeklySummaryPresenter;
