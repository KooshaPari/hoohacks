const { JournalController } = require('../controllers');

/**
 * JournalPresenter - Handles presenting journal data for the API
 */
class JournalPresenter {
  /**
   * Create a journal entry
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async createJournalEntry(req, res) {
    try {
      const { userId } = req.params;
      const entryData = req.body;
      
      const entry = await JournalController.createJournalEntry(userId, entryData);
      
      return res.status(201).json({
        success: true,
        data: this.formatJournalEntry(entry)
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Get journal entries within a date range
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async getJournalEntries(req, res) {
    try {
      const { userId } = req.params;
      const { startDate, endDate } = req.query;
      
      const start = startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000); // Default to last 30 days
      const end = endDate ? new Date(endDate) : new Date();
      
      const entries = await JournalController.getJournalEntriesInRange(userId, start, end);
      
      return res.status(200).json({
        success: true,
        data: entries.map(entry => this.formatJournalEntry(entry))
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Get a journal entry by ID
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async getJournalEntryById(req, res) {
    try {
      const { userId, entryId } = req.params;
      
      const entry = await JournalController.getJournalEntryById(entryId, userId);
      
      return res.status(200).json({
        success: true,
        data: this.formatJournalEntry(entry)
      });
    } catch (error) {
      return res.status(404).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Update a journal entry
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async updateJournalEntry(req, res) {
    try {
      const { userId, entryId } = req.params;
      const updateData = req.body;
      
      const entry = await JournalController.updateJournalEntry(entryId, userId, updateData);
      
      return res.status(200).json({
        success: true,
        data: this.formatJournalEntry(entry)
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Delete a journal entry
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async deleteJournalEntry(req, res) {
    try {
      const { userId, entryId } = req.params;
      
      await JournalController.deleteJournalEntry(entryId, userId);
      
      return res.status(200).json({
        success: true,
        message: 'Journal entry deleted successfully'
      });
    } catch (error) {
      return res.status(404).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Format a journal entry for the API response
   * @param {Object} entry - Journal entry document
   * @returns {Object} - Formatted journal entry
   */
  formatJournalEntry(entry) {
    return {
      id: entry._id,
      date: entry.date,
      mood: entry.mood,
      energy: entry.energy,
      symptoms: entry.symptoms.map(symptom => ({
        name: symptom.name,
        severity: symptom.severity
      })),
      notes: entry.notes,
      tags: entry.tags,
      healthMetrics: entry.healthMetrics || {}
    };
  }
}

module.exports = new JournalPresenter();
