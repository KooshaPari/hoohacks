// NarrativeController.js
const Narrative = require('../models/Narrative');
const JournalController = require('./JournalController');
const HealthDataController = require('./HealthDataController');
const DataStore = require('../data/DataStore'); // Mock data store
const GeminiAPI = require('../services/GeminiAPI'); // Mock AI service

class NarrativeController {
  constructor() {
    this.dataStore = new DataStore('narratives');
    this.journalController = new JournalController();
    this.healthDataController = new HealthDataController();
    this.geminiAPI = new GeminiAPI();
  }

  // Generate a weekly health narrative
  async generateWeeklyNarrative(userId) {
    try {
      // Set date range for the past week
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(endDate.getDate() - 7);
      
      // Get journal entries for the period
      const journalResult = await this.journalController.getEntries(
        userId, 
        startDate.toISOString(), 
        endDate.toISOString()
      );
      
      if (!journalResult.success) {
        return journalResult;
      }
      
      // Get health data for the period
      const healthTypes = ['sleep', 'steps', 'heartRate'];
      const healthDataResults = {};
      
      for (const type of healthTypes) {
        const result = await this.healthDataController.getHealthData(
          userId,
          type,
          startDate.toISOString(),
          endDate.toISOString()
        );
        
        if (result.success) {
          healthDataResults[type] = result.data;
        }
      }
      
      // Calculate averages for health metrics
      const averages = {};
      for (const type of healthTypes) {
        const avgResult = await this.healthDataController.calculateAverages(
          userId,
          type,
          startDate.toISOString(),
          endDate.toISOString()
        );
        
        if (avgResult.success) {
          averages[type] = avgResult.data;
        }
      }
      
      // Process journal entries to extract symptoms and tags
      const symptoms = {};
      const tags = {};
      
      journalResult.data.forEach(entry => {
        // Count symptoms
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
        
        // Count tags
        entry.tags.forEach(tag => {
          if (!tags[tag]) {
            tags[tag] = 0;
          }
          tags[tag] += 1;
        });
      });
      
      // Calculate average severity for symptoms
      Object.keys(symptoms).forEach(name => {
        symptoms[name].avgSeverity = 
          Math.round((symptoms[name].totalSeverity / symptoms[name].count) * 10) / 10;
      });
      
      // Prepare data for AI narrative generation
      const narrativeData = {
        period: {
          start: startDate.toISOString(),
          end: endDate.toISOString()
        },
        journalEntries: journalResult.data.length,
        symptoms,
        tags,
        averages,
        mood: {
          average: this._calculateAverage(journalResult.data.map(entry => entry.mood))
        },
        energy: {
          average: this._calculateAverage(journalResult.data.map(entry => entry.energy))
        }
      };
      
      // Generate narrative with AI
      const narrativeContent = await this.geminiAPI.generateWeeklyNarrative(narrativeData);
      
      // Create and save narrative
      const narrative = new Narrative(
        null,
        userId,
        'weekly',
        narrativeContent,
        { start: startDate.toISOString(), end: endDate.toISOString() }
      );
      
      const savedNarrative = await this.dataStore.save(narrative.toObject());
      
      return { success: true, data: savedNarrative };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Generate a pattern analysis narrative for a specific symptom
  async generatePatternAnalysis(userId, symptom) {
    try {
      // Set date range for the past month
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(endDate.getDate() - 30);
      
      // Get journal entries for the period
      const journalResult = await this.journalController.getEntries(
        userId, 
        startDate.toISOString(), 
        endDate.toISOString()
      );
      
      if (!journalResult.success) {
        return journalResult;
      }
      
      // Separate entries with and without the symptom
      const symptomDays = journalResult.data.filter(entry => 
        entry.symptoms.some(s => s.name.toLowerCase() === symptom.toLowerCase())
      );
      
      const nonSymptomDays = journalResult.data.filter(entry => 
        !entry.symptoms.some(s => s.name.toLowerCase() === symptom.toLowerCase())
      );
      
      // Get health data (sleep, steps) for correlation analysis
      const healthTypes = ['sleep', 'steps'];
      let sleepData = [];
      let activityData = [];
      
      const sleepResult = await this.healthDataController.getHealthData(
        userId, 'sleep', startDate.toISOString(), endDate.toISOString()
      );
      
      if (sleepResult.success) {
        sleepData = sleepResult.data;
      }
      
      const activityResult = await this.healthDataController.getHealthData(
        userId, 'steps', startDate.toISOString(), endDate.toISOString()
      );
      
      if (activityResult.success) {
        activityData = activityResult.data;
      }
      
      // Calculate averages for symptom days vs. non-symptom days
      const symptomSleepAvg = this._calculateAverageForDays(
        symptomDays, sleepData, 'value'
      );
      
      const nonSymptomSleepAvg = this._calculateAverageForDays(
        nonSymptomDays, sleepData, 'value'
      );
      
      const symptomStepsAvg = this._calculateAverageForDays(
        symptomDays, activityData, 'value'
      );
      
      const nonSymptomStepsAvg = this._calculateAverageForDays(
        nonSymptomDays, activityData, 'value'
      );
      
      // Compare tags between symptom and non-symptom days
      const symptomTags = this._getTagsFrequency(symptomDays);
      const nonSymptomTags = this._getTagsFrequency(nonSymptomDays);
      
      // Prepare data for AI pattern analysis
      const analysisData = {
        symptom,
        period: {
          start: startDate.toISOString(),
          end: endDate.toISOString()
        },
        symptomDaysCount: symptomDays.length,
        nonSymptomDaysCount: nonSymptomDays.length,
        sleepSymptomAvg: symptomSleepAvg,
        sleepNonSymptomAvg: nonSymptomSleepAvg,
        stepsSymptomAvg: symptomStepsAvg,
        stepsNonSymptomAvg: nonSymptomStepsAvg,
        commonTags: Object.keys(symptomTags).sort((a, b) => symptomTags[b] - symptomTags[a])
      };
      
      // Generate narrative with AI
      const narrativeContent = await this.geminiAPI.generatePatternInsights(analysisData);
      
      // Create and save narrative
      const narrative = new Narrative(
        null,
        userId,
        'pattern',
        narrativeContent,
        { start: startDate.toISOString(), end: endDate.toISOString() }
      );
      
      const savedNarrative = await this.dataStore.save(narrative.toObject());
      
      return { 
        success: true, 
        data: {
          narrative: savedNarrative,
          analysis: {
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
          }
        }
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Get previously generated narratives
  async getNarratives(userId, type = null) {
    try {
      let narratives = await this.dataStore.getAll();
      
      // Filter by user
      narratives = narratives.filter(narrative => narrative.userId === userId);
      
      // Filter by type if provided
      if (type) {
        narratives = narratives.filter(narrative => narrative.type === type);
      }
      
      // Sort by timestamp (newest first)
      narratives.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
      
      return { success: true, data: narratives };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Calculate average value from an array of numbers
  _calculateAverage(values) {
    if (values.length === 0) return 0;
    const sum = values.reduce((total, value) => total + value, 0);
    return Math.round((sum / values.length) * 10) / 10;
  }

  // Calculate average for a specific metric on specific days
  _calculateAverageForDays(days, metricData, metricKey) {
    if (days.length === 0) return 0;
    
    const dayTimestamps = days.map(day => this._getDateString(new Date(day.timestamp)));
    const relevantMetrics = metricData.filter(metric => 
      dayTimestamps.includes(this._getDateString(new Date(metric.timestamp)))
    );
    
    return this._calculateAverage(relevantMetrics.map(metric => metric[metricKey]));
  }

  // Get the frequency of tags in journal entries
  _getTagsFrequency(entries) {
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

  // Get date string (YYYY-MM-DD) from Date object
  _getDateString(date) {
    return date.toISOString().split('T')[0];
  }
}

module.exports = NarrativeController;
