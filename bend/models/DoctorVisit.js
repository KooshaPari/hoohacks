const mongoose = require('mongoose');

const DoctorVisitSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  generatedDate: {
    type: Date,
    default: Date.now,
    required: true
  },
  periodStart: {
    type: Date,
    required: true
  },
  periodEnd: {
    type: Date,
    required: true
  },
  keySymptoms: [{
    name: String,
    occurrences: Number,
    avgSeverity: Number
  }],
  overallPatterns: [String],
  questions: [String],
  notes: String,
  sharedWith: [String], // email addresses or doctor identifiers
  aiGenerated: {
    type: Boolean,
    default: true
  }
}, { timestamps: true });

module.exports = mongoose.model('DoctorVisit', DoctorVisitSchema);
