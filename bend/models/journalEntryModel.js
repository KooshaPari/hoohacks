const mongoose = require('mongoose');

const symptomSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'A symptom must have a name']
  },
  severity: {
    type: Number,
    min: 1,
    max: 10,
    default: 5
  }
});

const journalEntrySchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: [true, 'A journal entry must belong to a user']
  },
  date: {
    type: Date,
    default: Date.now,
    required: [true, 'A journal entry must have a date']
  },
  mood: {
    type: Number,
    min: 1,
    max: 5,
    required: [true, 'A journal entry must have a mood rating']
  },
  energy: {
    type: Number,
    min: 1,
    max: 5,
    required: [true, 'A journal entry must have an energy rating']
  },
  symptoms: [symptomSchema],
  notes: {
    type: String,
    trim: true
  },
  tags: [String],
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      default: [0, 0]
    },
    description: String
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Indexes
journalEntrySchema.index({ user: 1, date: -1 }); // For quickly finding entries by user and sorting by date

const JournalEntry = mongoose.model('JournalEntry', journalEntrySchema);

module.exports = JournalEntry;
