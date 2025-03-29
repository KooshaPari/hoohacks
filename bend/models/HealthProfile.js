const mongoose = require('mongoose');

const HealthProfileSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  conditions: [{
    name: String,
    diagnosedDate: Date,
    notes: String
  }],
  medications: [{
    name: String,
    dosage: String,
    frequency: String,
    startDate: Date,
    endDate: Date
  }],
  allergies: [{
    allergen: String,
    severity: {
      type: String,
      enum: ['Mild', 'Moderate', 'Severe']
    },
    notes: String
  }],
  preferences: {
    symptomTracking: {
      enabled: {
        type: Boolean,
        default: true
      },
      customSymptoms: [String]
    },
    dataSync: {
      appleHealth: {
        type: Boolean,
        default: false
      },
      googleFit: {
        type: Boolean,
        default: false
      }
    }
  }
}, { timestamps: true });

module.exports = mongoose.model('HealthProfile', HealthProfileSchema);
