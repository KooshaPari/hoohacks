const JournalEntry = require('../models/journalEntryModel');
const HealthData = require('../models/healthDataModel');
const axios = require('axios');

// Service to generate insights using Gemini API (mocked for now)
const geminiService = require('../services/geminiService');

exports.getWeeklySummary = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const today = new Date();
    const weekAgo = new Date(today);
    weekAgo.setDate(today.getDate() - 7);
    
    // Get journal entries for the week
    const journalEntries = await JournalEntry.find({
      user: userId,
      date: { $gte: weekAgo, $lte: today }
    }).sort('date');
    
    // Get sleep data for the week
    const sleepData = await HealthData.find({
      user: userId,
      dataType: 'sleep',
      date: { $gte: weekAgo, $lte: today }
    }).sort('date');
    
    // Get activity data for the week
    const activityData = await HealthData.find({
      user: userId,
      dataType: 'activity',
      date: { $gte: weekAgo, $lte: today }
    }).sort('date');
    
    // Get heart rate data for the week
    const heartRateData = await HealthData.find({
      user: userId,
      dataType: 'heartRate',
      date: { $gte: weekAgo, $lte: today }
    }).sort('date');
    
    // Calculate summary statistics
    const summary = {
      period: {
        start: weekAgo,
        end: today
      },
      entries: journalEntries.length,
      mood: {
        average: calculateAverage(journalEntries.map(entry => entry.mood))
      },
      energy: {
        average: calculateAverage(journalEntries.map(entry => entry.energy))
      },
      symptoms: countSymptoms(journalEntries),
      sleep: {
        average: calculateAverage(sleepData.map(data => data.values.duration))
      },
      activity: {
        averageSteps: calculateAverage(activityData.map(data => data.values.steps))
      },
      heartRate: {
        averageResting: calculateAverage(heartRateData.map(data => data.values.restingHeartRate))
      }
    };
    
    // Get AI-generated narrative (mocked for now)
    const narrative = await geminiService.generateWeeklyNarrative(summary);
    
    res.status(200).json({
      status: 'success',
      data: {
        summary,
        narrative
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.getPatternAnalysis = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { symptom } = req.params;
    const { startDate, endDate } = req.query;
    
    const start = startDate ? new Date(startDate) : new Date(new Date().setDate(new Date().getDate() - 30));
    const end = endDate ? new Date(endDate) : new Date();
    
    // Get all journal entries for the period
    const journalEntries = await JournalEntry.find({
      user: userId,
      date: { $gte: start, $lte: end }
    });
    
    // Separate entries with and without the symptom
    const symptomDays = journalEntries.filter(entry => 
      entry.symptoms.some(s => s.name.toLowerCase() === symptom.toLowerCase())
    );
    
    const nonSymptomDays = journalEntries.filter(entry => 
      !entry.symptoms.some(s => s.name.toLowerCase() === symptom.toLowerCase())
    );
    
    // Get dates for symptom days and non-symptom days
    const symptomDayDates = symptomDays.map(entry => entry.date.toISOString().split('T')[0]);
    const nonSymptomDayDates = nonSymptomDays.map(entry => entry.date.toISOString().split('T')[0]);
    
    // Get sleep data for the period
    const sleepData = await HealthData.find({
      user: userId,
      dataType: 'sleep',
      date: { $gte: start, $lte: end }
    });
    
    // Get activity data for the period
    const activityData = await HealthData.find({
      user: userId,
      dataType: 'activity',
      date: { $gte: start, $lte: end }
    });
    
    // Calculate averages for symptom days vs non-symptom days
    const symptomSleepAvg = calculateAverageForDays(
      symptomDayDates, 
      sleepData, 
      'values.duration'
    );
    
    const nonSymptomSleepAvg = calculateAverageForDays(
      nonSymptomDayDates, 
      sleepData, 
      'values.duration'
    );
    
    const symptomStepsAvg = calculateAverageForDays(
      symptomDayDates, 
      activityData, 
      'values.steps'
    );
    
    const nonSymptomStepsAvg = calculateAverageForDays(
      nonSymptomDayDates, 
      activityData, 
      'values.steps'
    );
    
    // Get tags frequency
    const symptomTags = getTagsFrequency(symptomDays);
    const nonSymptomTags = getTagsFrequency(nonSymptomDays);
    
    // Prepare analysis
    const analysis = {
      symptom,
      period: {
        start,
        end
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
    
    // Get AI-generated insights (mocked for now)
    const insights = await geminiService.generatePatternInsights(analysis);
    
    res.status(200).json({
      status: 'success',
      data: {
        analysis,
        insights
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.getDoctorVisitSummary = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { startDate, endDate } = req.query;
    
    const start = startDate ? new Date(startDate) : new Date(new Date().setDate(new Date().getDate() - 30));
    const end = endDate ? new Date(endDate) : new Date();
    
    // Get all journal entries for the period
    const journalEntries = await JournalEntry.find({
      user: userId,
      date: { $gte: start, $lte: end }
    });
    
    // Count symptoms
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
    
    // Format key symptoms
    const keySymptoms = Object.keys(symptoms).map(name => ({
      name,
      occurrences: symptoms[name].occurrences,
      avgSeverity: symptoms[name].avgSeverity
    }));
    
    // Get sleep data for the period
    const sleepData = await HealthData.find({
      user: userId,
      dataType: 'sleep',
      date: { $gte: start, $lte: end }
    });
    
    // Get activity data for the period
    const activityData = await HealthData.find({
      user: userId,
      dataType: 'activity',
      date: { $gte: start, $lte: end }
    });
    
    // Get heart rate data for the period
    const heartRateData = await HealthData.find({
      user: userId,
      dataType: 'heartRate',
      date: { $gte: start, $lte: end }
    });
    
    // Prepare summary data for Gemini
    const summaryData = {
      period: {
        start,
        end
      },
      keySymptoms,
      sleep: {
        average: calculateAverage(sleepData.map(data => data.values.duration))
      },
      activity: {
        averageSteps: calculateAverage(activityData.map(data => data.values.steps))
      },
      heartRate: {
        averageResting: calculateAverage(heartRateData.map(data => data.values.restingHeartRate))
      },
      tags: getTagsFrequency(journalEntries)
    };
    
    // Get AI-generated doctor visit summary (mocked for now)
    const doctorSummary = await geminiService.generateDoctorVisitSummary(summaryData);
    
    res.status(200).json({
      status: 'success',
      data: {
        summaryData,
        doctorSummary
      }
    });
  } catch (err) {
    next(err);
  }
};

// Helper Functions
const calculateAverage = (values) => {
  if (values.length === 0) return 0;
  const validValues = values.filter(val => val !== undefined && val !== null);
  if (validValues.length === 0) return 0;
  
  const sum = validValues.reduce((total, value) => total + value, 0);
  return Math.round((sum / validValues.length) * 10) / 10;
};

const countSymptoms = (entries) => {
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
};

const calculateAverageForDays = (dayDates, metricData, metricPath) => {
  if (dayDates.length === 0 || metricData.length === 0) return 0;
  
  const relevantMetrics = metricData.filter(metric => 
    dayDates.includes(metric.date.toISOString().split('T')[0])
  );
  
  if (relevantMetrics.length === 0) return 0;
  
  // Handle dot notation for nested paths
  const getNestedValue = (obj, path) => {
    const parts = path.split('.');
    return parts.reduce((o, key) => (o && o[key] !== undefined) ? o[key] : undefined, obj);
  };
  
  return calculateAverage(relevantMetrics.map(metric => getNestedValue(metric, metricPath)));
};

const getTagsFrequency = (entries) => {
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
};
