/**
 * HealthData model - Represents the core health data structure
 */
class HealthData {
  constructor() {
    this.journalEntries = [];
    this.healthMetrics = {
      sleep: [],
      activity: [],
      heartRate: []
    };
  }

  /**
   * Add a new journal entry
   * @param {Object} entry - The journal entry to add
   */
  addJournalEntry(entry) {
    // Generate an ID if none exists
    if (!entry.id) {
      entry.id = Date.now().toString();
    }
    
    // Add timestamp if none exists
    if (!entry.timestamp) {
      entry.timestamp = new Date().toISOString();
    }
    
    this.journalEntries.push(entry);
    return entry;
  }

  /**
   * Get journal entries within a date range
   * @param {Date} startDate - Start of the date range
   * @param {Date} endDate - End of the date range
   * @returns {Array} - Filtered journal entries
   */
  getJournalEntriesInRange(startDate, endDate) {
    return this.journalEntries.filter(entry => {
      const entryDate = new Date(entry.timestamp);
      return entryDate >= startDate && entryDate <= endDate;
    });
  }

  /**
   * Add health metrics
   * @param {String} type - Type of health metric (sleep, activity, heartRate)
   * @param {Object} data - The metric data
   */
  addHealthMetric(type, data) {
    if (!this.healthMetrics[type]) {
      this.healthMetrics[type] = [];
    }
    
    // Add timestamp if none exists
    if (!data.timestamp) {
      data.timestamp = new Date().toISOString();
    }
    
    this.healthMetrics[type].push(data);
    return data;
  }

  /**
   * Get health metrics within a date range
   * @param {String} type - Type of health metric
   * @param {Date} startDate - Start of the date range
   * @param {Date} endDate - End of the date range
   * @returns {Array} - Filtered health metrics
   */
  getHealthMetricsInRange(type, startDate, endDate) {
    if (!this.healthMetrics[type]) {
      return [];
    }
    
    return this.healthMetrics[type].filter(metric => {
      const metricDate = new Date(metric.timestamp);
      return metricDate >= startDate && metricDate <= endDate;
    });
  }
}

export default HealthData;
