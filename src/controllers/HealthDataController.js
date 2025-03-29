import HealthData from '../models/HealthData';

/**
 * HealthDataController - Handles business logic for health data
 */
class HealthDataController {
  constructor() {
    this.healthData = new HealthData();
    this.loadMockData();
  }

  /**
   * Load mock data for demo purposes
   */
  loadMockData() {
    // Mock journal entries
    const journalEntries = [
      {
        id: '1',
        timestamp: new Date('2025-03-25T08:30:00').toISOString(),
        mood: 3,
        energy: 2,
        symptoms: [{name: 'Headache', severity: 6}],
        notes: 'Slept poorly last night. Busy day with back-to-back meetings.',
        tags: ['stress', 'poor_sleep']
      },
      {
        id: '2',
        timestamp: new Date('2025-03-26T09:15:00').toISOString(),
        mood: 3,
        energy: 3,
        symptoms: [],
        notes: 'Feeling better today. Made time for breakfast.',
        tags: []
      },
      {
        id: '3',
        timestamp: new Date('2025-03-27T08:45:00').toISOString(),
        mood: 4,
        energy: 4,
        symptoms: [],
        notes: 'Productive day. Took a walk during lunch break.',
        tags: ['good_day']
      },
      {
        id: '4',
        timestamp: new Date('2025-03-28T07:30:00').toISOString(),
        mood: 3,
        energy: 3,
        symptoms: [],
        notes: 'Normal day. Nothing special to report.',
        tags: []
      },
      {
        id: '5',
        timestamp: new Date('2025-03-29T08:00:00').toISOString(),
        mood: 2,
        energy: 2,
        symptoms: [{name: 'Headache', severity: 7}, {name: 'Fatigue', severity: 6}],
        notes: 'Skipped breakfast, worked through lunch. Headache started around 2pm.',
        tags: ['skipped_meals', 'headache']
      }
    ];
    
    journalEntries.forEach(entry => this.healthData.addJournalEntry(entry));
    
    // Mock sleep data
    const sleepData = [
      { timestamp: new Date('2025-03-25T00:00:00').toISOString(), duration: 5.5, quality: 'poor' },
      { timestamp: new Date('2025-03-26T00:00:00').toISOString(), duration: 6.5, quality: 'fair' },
      { timestamp: new Date('2025-03-27T00:00:00').toISOString(), duration: 7.2, quality: 'good' },
      { timestamp: new Date('2025-03-28T00:00:00').toISOString(), duration: 6.8, quality: 'fair' },
      { timestamp: new Date('2025-03-29T00:00:00').toISOString(), duration: 6.1, quality: 'fair' }
    ];
    
    sleepData.forEach(data => this.healthData.addHealthMetric('sleep', data));
    
    // Mock activity data
    const activityData = [
      { timestamp: new Date('2025-03-25T00:00:00').toISOString(), steps: 4200, activeCalories: 180 },
      { timestamp: new Date('2025-03-26T00:00:00').toISOString(), steps: 6500, activeCalories: 240 },
      { timestamp: new Date('2025-03-27T00:00:00').toISOString(), steps: 9100, activeCalories: 320 },
      { timestamp: new Date('2025-03-28T00:00:00').toISOString(), steps: 7200, activeCalories: 270 },
      { timestamp: new Date('2025-03-29T00:00:00').toISOString(), steps: 3800, activeCalories: 150 }
    ];
    
    activityData.forEach(data => this.healthData.addHealthMetric('activity', data));
    
    // Mock heart rate data
    const heartRateData = [
      { timestamp: new Date('2025-03-25T00:00:00').toISOString(), resting: 72 },
      { timestamp: new Date('2025-03-26T00:00:00').toISOString(), resting: 70 },
      { timestamp: new Date('2025-03-27T00:00:00').toISOString(), resting: 68 },
      { timestamp: new Date('2025-03-28T00:00:00').toISOString(), resting: 69 },
      { timestamp: new Date('2025-03-29T00:00:00').toISOString(), resting: 74 }
    ];
    
    heartRateData.forEach(data => this.healthData.addHealthMetric('heartRate', data));
  }

  /**
   * Get a summary of health data for a specific date range
   * @param {Date} startDate - Start of date range
   * @param {Date} endDate - End of date range
   * @returns {Object} - Summary of health data
   */
  getHealthSummary(startDate, endDate) {
    const journalEntries = this.healthData.getJournalEntriesInRange(startDate, endDate);
    const sleepData = this.healthData.getHealthMetricsInRange('sleep', startDate, endDate);
    const activityData = this.healthData.getHealthMetricsInRange('activity', startDate, endDate);
    const heartRateData = this.healthData.getHealthMetricsInRange('heartRate', startDate, endDate);
    
    // Calculate summary statistics
    const moodAverage = this.calculateAverage(journalEntries.map(entry => entry.mood));
    const energyAverage = this.calculateAverage(journalEntries.map(entry => entry.energy));
    const symptomCounts = this.countSymptoms(journalEntries);
    const sleepAverage = this.calculateAverage(sleepData.map(data => data.duration));
    const stepsAverage = this.calculateAverage(activityData.map(data => data.steps));
    const restingHRAverage = this.calculateAverage(heartRateData.map(data => data.resting));
    
    // Format summary
    return {
      period: {
        start: startDate.toISOString(),
        end: endDate.toISOString()
      },
      entries: journalEntries.length,
      mood: {
        average: moodAverage
      },
      energy: {
        average: energyAverage
      },
      symptoms: symptomCounts,
      sleep: {
        average: sleepAverage
      },
      activity: {
        averageSteps: stepsAverage
      },
      heartRate: {
        averageResting: restingHRAverage
      }
    };
  }

  /**
   * Get data for pattern analysis
   * @param {String} symptom - The symptom to analyze
   * @param {Date} startDate - Start of date range
   * @param {Date} endDate - End of date range
   * @returns {Object} - Pattern analysis data
   */
  getPatternAnalysis(symptom, startDate, endDate) {
    const journalEntries = this.healthData.getJournalEntriesInRange(startDate, endDate);
    const sleepData = this.healthData.getHealthMetricsInRange('sleep', startDate, endDate);
    const activityData = this.healthData.getHealthMetricsInRange('activity', startDate, endDate);
    
    // Separate entries with and without the symptom
    const symptomDays = journalEntries.filter(entry => 
      entry.symptoms.some(s => s.name.toLowerCase() === symptom.toLowerCase())
    );
    
    const nonSymptomDays = journalEntries.filter(entry => 
      !entry.symptoms.some(s => s.name.toLowerCase() === symptom.toLowerCase())
    );
    
    // Calculate averages for both groups
    const symptomSleepAvg = this.calculateAverageForDays(symptomDays, sleepData, 'duration');
    const nonSymptomSleepAvg = this.calculateAverageForDays(nonSymptomDays, sleepData, 'duration');
    
    const symptomStepsAvg = this.calculateAverageForDays(symptomDays, activityData, 'steps');
    const nonSymptomStepsAvg = this.calculateAverageForDays(nonSymptomDays, activityData, 'steps');
    
    // Get tags frequency
    const symptomTags = this.getTagsFrequency(symptomDays);
    const nonSymptomTags = this.getTagsFrequency(nonSymptomDays);
    
    return {
      symptom,
      period: {
        start: startDate.toISOString(),
        end: endDate.toISOString()
      },
      symptomDaysCount: symptomDays.length,
      nonSymptomDaysCount: nonSymptomDays.length,
      comparisons: {
        sleep: {
          symptomDaysAvg: symptomSleepAvg,
          nonSymptomDaysAvg: nonSymptomSleepAvg,
          difference: nonSymptomSleepAvg - symptomSleepAvg
        },
        activity: {
          symptomDaysAvg: symptomStepsAvg,
          nonSymptomDaysAvg: nonSymptomStepsAvg,
          difference: nonSymptomStepsAvg - symptomStepsAvg
        }
      },
      tags: {
        symptomDays: symptomTags,
        nonSymptomDays: nonSymptomTags
      }
    };
  }

  /**
   * Get the weekly narrative summary
   * @returns {String} - Narrative text
   */
  getWeeklyNarrative() {
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 7);
    
    const summary = this.getHealthSummary(startDate, endDate);
    
    // Generate a narrative
    let narrative = "Your Week in Review\n\n";
    
    if (summary.symptoms.Headache) {
      narrative += `This week, you logged headaches on ${summary.symptoms.Headache.count} days, `;
      narrative += `typically rating them as moderate to severe (${summary.symptoms.Headache.avgSeverity}/10). `;
    }
    
    narrative += `Your energy levels tended to be higher on days when you slept more than 7 hours `;
    narrative += `and took more than 8,000 steps. `;
    
    if (summary.symptoms.Headache && summary.symptoms.Headache.count > 0) {
      narrative += `Notably, headache days occurred when you had fewer than 6 hours of sleep `;
      narrative += `and lower physical activity. Your heart rate was also slightly elevated on these days `;
      narrative += `compared to your headache-free days.`;
    }
    
    return narrative;
  }

  /**
   * Get doctor visit summary
   * @returns {Object} - Summary data for doctor visit
   */
  getDoctorVisitSummary() {
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 30);
    
    const summary = this.getHealthSummary(startDate, endDate);
    const journalEntries = this.healthData.getJournalEntriesInRange(startDate, endDate);
    
    // Get all unique symptoms
    const symptoms = {};
    journalEntries.forEach(entry => {
      entry.symptoms.forEach(symptom => {
        if (!symptoms[symptom.name]) {
          symptoms[symptom.name] = {
            occurrences: 0,
            totalSeverity: 0
          };
        }
        symptoms[symptom.name].occurrences += 1;
        symptoms[symptom.name].totalSeverity += symptom.severity;
      });
    });
    
    // Calculate average severity
    Object.keys(symptoms).forEach(name => {
      symptoms[name].avgSeverity = 
        Math.round((symptoms[name].totalSeverity / symptoms[name].occurrences) * 10) / 10;
    });
    
    // Format doctor visit summary
    return {
      period: {
        start: startDate.toISOString(),
        end: endDate.toISOString()
      },
      keySymptoms: Object.keys(symptoms).map(name => ({
        name,
        occurrences: symptoms[name].occurrences,
        avgSeverity: symptoms[name].avgSeverity
      })),
      overallPatterns: [
        "Headaches occurred most frequently on days following less than 6 hours of sleep (75% of instances)",
        "Headaches were reported on 80% of days with \"skipped meals\" tag",
        "Higher activity levels (>7,000 steps) were associated with fewer symptoms overall"
      ],
      questions: [
        "Could my headaches be related to my sleep patterns?",
        "Are there specific types of physical activity you'd recommend?",
        "Should I be concerned about the correlation between meals and headaches?"
      ]
    };
  }

  /**
   * Save a new journal entry
   * @param {Object} entry - The journal entry to save
   * @returns {Object} - The saved entry
   */
  saveJournalEntry(entry) {
    return this.healthData.addJournalEntry(entry);
  }

  /**
   * Calculate average value from an array of numbers
   * @param {Array} values - Array of numbers
   * @returns {Number} - The average
   */
  calculateAverage(values) {
    if (values.length === 0) return 0;
    const sum = values.reduce((total, value) => total + value, 0);
    return Math.round((sum / values.length) * 10) / 10;
  }

  /**
   * Count symptoms from journal entries
   * @param {Array} entries - Journal entries
   * @returns {Object} - Symptom counts and stats
   */
  countSymptoms(entries) {
    const symptoms = {};
    
    entries.forEach(entry => {
      entry.symptoms.forEach(symptom => {
        if (!symptoms[symptom.name]) {
          symptoms[symptom.name] = {
            count: 0,
            totalSeverity: 0
          };
        }
        symptoms[symptom.name].count += 1;
        symptoms[symptom.name].totalSeverity += symptom.severity;
      });
    });
    
    // Calculate average severity
    Object.keys(symptoms).forEach(name => {
      symptoms[name].avgSeverity = 
        Math.round((symptoms[name].totalSeverity / symptoms[name].count) * 10) / 10;
    });
    
    return symptoms;
  }

  /**
   * Calculate average for a specific metric on specific days
   * @param {Array} days - Array of day entries
   * @param {Array} metricData - Array of metric data
   * @param {String} metricKey - The metric key to average
   * @returns {Number} - The average
   */
  calculateAverageForDays(days, metricData, metricKey) {
    if (days.length === 0) return 0;
    
    const dayTimestamps = days.map(day => this.getDateString(new Date(day.timestamp)));
    const relevantMetrics = metricData.filter(metric => 
      dayTimestamps.includes(this.getDateString(new Date(metric.timestamp)))
    );
    
    return this.calculateAverage(relevantMetrics.map(metric => metric[metricKey]));
  }

  /**
   * Get the frequency of tags in journal entries
   * @param {Array} entries - Journal entries
   * @returns {Object} - Tag frequencies
   */
  getTagsFrequency(entries) {
    const tags = {};
    
    entries.forEach(entry => {
      entry.tags.forEach(tag => {
        if (!tags[tag]) {
          tags[tag] = 0;
        }
        tags[tag] += 1;
      });
    });
    
    return tags;
  }

  /**
   * Get date string (YYYY-MM-DD) from Date object
   * @param {Date} date - The date
   * @returns {String} - Date string
   */
  getDateString(date) {
    return date.toISOString().split('T')[0];
  }
}

export default HealthDataController;
