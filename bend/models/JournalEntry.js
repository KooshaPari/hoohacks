const mongoose = require('mongoose');

const SymptomSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  severity: {
    type: Number,
    min: 1,
    max: 10,
    required: true
  }
});

const JournalEntrySchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  date: {
    type: Date,
    required: true,
    default: Date.now
  },
  mood: {
    type: Number,
    min: 1,
    max: 5,
    required: true
  },
  energy: {
    type: Number,
    min: 1,
    max: 5,
    required: true
  },
  symptoms: [SymptomSchema],
  notes: {
    type: String,
    trim: true
  },
  tags: [String],
  healthMetrics: {
    sleep: {
      duration: Number, // hours
      quality: String
    },
    activity: {
      steps: Number,
      activeCalories: Number
    },
    heartRate: {
      resting: Number
    }
  }
}, { timestamps: true });

// Index for date-based queries
JournalEntrySchema.index({ user: 1, date: -1 });

module.exports = mongoose.model('JournalEntry', JournalEntrySchema);
