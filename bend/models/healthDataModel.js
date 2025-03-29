const mongoose = require('mongoose');

const healthDataSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: [true, 'Health data must belong to a user']
  },
  date: {
    type: Date,
    default: Date.now
  },
  dataType: {
    type: String,
    enum: ['sleep', 'activity', 'heartRate', 'nutrition'],
    required: [true, 'Health data must have a type']
  },
  values: {
    // Sleep data
    duration: Number, // in hours
    quality: {
      type: String,
      enum: ['poor', 'fair', 'good', 'excellent']
    },
    deepSleepMinutes: Number,
    remSleepMinutes: Number,
    
    // Activity data
    steps: Number,
    activeCalories: Number,
    exerciseMinutes: Number,
    standHours: Number,
    
    // Heart rate data
    restingHeartRate: Number, // bpm
    averageHeartRate: Number, // bpm
    heartRateVariability: Number, // ms
    
    // Nutrition data
    calories: Number,
    protein: Number, // grams
    carbohydrates: Number, // grams
    fat: Number, // grams
    water: Number // oz
  },
  source: {
    type: String,
    enum: ['apple_health', 'fitbit', 'garmin', 'samsung_health', 'manual_entry'],
    default: 'manual_entry'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Indexes
healthDataSchema.index({ user: 1, dataType: 1, date: -1 });

const HealthData = mongoose.model('HealthData', healthDataSchema);

module.exports = HealthData;
