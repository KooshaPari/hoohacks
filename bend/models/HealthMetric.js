const mongoose = require('mongoose');

const HealthMetricSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  metricType: {
    type: String,
    enum: ['sleep', 'activity', 'heartRate', 'weight', 'bloodPressure', 'bloodGlucose', 'other'],
    required: true
  },
  // Generic values field to store different metric types
  values: {
    type: mongoose.Schema.Types.Mixed,
    required: true
  },
  source: {
    type: String,
    enum: ['manual', 'appleHealth', 'googleFit', 'fitbit', 'other'],
    default: 'manual'
  },
  notes: String
}, { timestamps: true });

// Compound index for querying metrics by user and type within date ranges
HealthMetricSchema.index({ user: 1, metricType: 1, date: -1 });

module.exports = mongoose.model('HealthMetric', HealthMetricSchema);
