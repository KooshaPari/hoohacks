// HealthData model
class HealthData {
  constructor(id = null, userId = null, type = '', value = null, unit = '', timestamp = null, source = 'manual') {
    this.id = id || this._generateId();
    this.userId = userId;
    this.type = type; // e.g., 'steps', 'sleep', 'heartRate'
    this.value = value;
    this.unit = unit; // e.g., 'count', 'hours', 'bpm'
    this.timestamp = timestamp || new Date().toISOString();
    this.source = source; // e.g., 'apple_health', 'manual', 'fitbit'
  }

  // Generate a simple ID (in production, use UUID or MongoDB ObjectId)
  _generateId() {
    return Date.now().toString();
  }

  // Validate health data
  validate() {
    if (!this.type) {
      return { valid: false, error: 'Type is required' };
    }
    
    if (this.value === null || this.value === undefined) {
      return { valid: false, error: 'Value is required' };
    }
    
    // Specific validations per type
    switch (this.type) {
      case 'steps':
        if (typeof this.value !== 'number' || this.value < 0) {
          return { valid: false, error: 'Steps must be a non-negative number' };
        }
        break;
      case 'sleep':
        if (typeof this.value !== 'number' || this.value < 0 || this.value > 24) {
          return { valid: false, error: 'Sleep must be a number between 0 and 24' };
        }
        break;
      case 'heartRate':
        if (typeof this.value !== 'number' || this.value < 0) {
          return { valid: false, error: 'Heart rate must be a non-negative number' };
        }
        break;
    }
    
    return { valid: true };
  }

  // Convert to a plain object (for storage/API responses)
  toObject() {
    return {
      id: this.id,
      userId: this.userId,
      type: this.type,
      value: this.value,
      unit: this.unit,
      timestamp: this.timestamp,
      source: this.source
    };
  }

  // Create from a plain object (from storage/API requests)
  static fromObject(obj) {
    return new HealthData(
      obj.id,
      obj.userId,
      obj.type,
      obj.value,
      obj.unit,
      obj.timestamp,
      obj.source
    );
  }
}

module.exports = HealthData;
