import HealthDataController from '../controllers/HealthDataController';

/**
 * JournalPresenter - Handles presenting data for the Journal view
 */
class JournalPresenter {
  constructor() {
    this.healthDataController = new HealthDataController();
  }

  /**
   * Save a journal entry
   * @param {Object} journalData - The journal entry data
   * @returns {Object} - The saved entry
   */
  saveJournalEntry(journalData) {
    // Format data for the model
    const entry = {
      mood: parseInt(journalData.mood, 10),
      energy: parseInt(journalData.energy, 10),
      symptoms: this.parseSymptoms(journalData.symptoms),
      notes: journalData.notes,
      tags: this.parseTags(journalData.tags)
    };
    
    return this.healthDataController.saveJournalEntry(entry);
  }

  /**
   * Get recent journal entries
   * @param {Number} count - Number of entries to retrieve
   * @returns {Array} - Recent journal entries
   */
  getRecentEntries(count = 5) {
    const allEntries = [...this.healthDataController.healthData.journalEntries];
    return allEntries
      .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
      .slice(0, count);
  }

  /**
   * Parse symptoms string into array of symptom objects
   * @param {String} symptomsStr - Comma-separated symptoms with optional severity
   * @returns {Array} - Array of symptom objects
   */
  parseSymptoms(symptomsStr) {
    if (!symptomsStr) return [];
    
    return symptomsStr.split(',').map(symptom => {
      const parts = symptom.trim().split(':');
      return {
        name: parts[0].trim(),
        severity: parts.length > 1 ? parseInt(parts[1], 10) : 5
      };
    });
  }

  /**
   * Parse tags string into array of tags
   * @param {String} tagsStr - Comma or space separated tags
   * @returns {Array} - Array of tags
   */
  parseTags(tagsStr) {
    if (!tagsStr) return [];
    
    // Replace commas with spaces and split by space
    return tagsStr
      .replace(/,/g, ' ')
      .split(' ')
      .map(tag => tag.trim())
      .filter(tag => tag.length > 0);
  }
}

export default JournalPresenter;
