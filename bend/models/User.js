const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true
  },
  dateCreated: {
    type: Date,
    default: Date.now
  },
  healthProfile: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'HealthProfile'
  }
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
