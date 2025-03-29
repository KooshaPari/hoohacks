// Narrative model
class Narrative {
  constructor(id = null, userId = null, type = '', content = '', period = {}, timestamp = null) {
    this.id = id || this._generateId();
    this.userId = userId;
    this.type = type; // e.g., 'weekly', 'monthly', 'pattern', 'doctor'
    this.content = content;
    this.period = period; // { start, end }
    this.timestamp = timestamp || new Date().toISOString();
  }

  // Generate a simple ID (in production, use UUID or MongoDB ObjectId)
  _generateId() {
    return Date.now().toString();
  }

  // Validate narrative
  validate() {
    if (!this.type) {
      return { valid: false, error: 'Type is required' };
    }
    
    if (!this.content) {
      return { valid: false, error: 'Content is required' };
    }
    
    if (!this.period || !this.period.start || !this.period.end) {
      return { valid: false, error: 'Period with start and end dates is required' };
    }
    
    return { valid: true };
  }

  // Convert to a plain object (for storage/API responses)
  toObject() {
    return {
      id: this.id,
      userId: this.userId,
      type: this.type,
      content: this.content,
      period: this.period,
      timestamp: this.timestamp
    };
  }

  // Create from a plain object (from storage/API requests)
  static fromObject(obj) {
    return new Narrative(
      obj.id,
      obj.userId,
      obj.type,
      obj.content,
      obj.period,
      obj.timestamp
    );
  }
}

module.exports = Narrative;
