const { DoctorVisit } = require('../models');
const HealthDataController = require('./HealthDataController');

/**
 * DoctorVisitController - Handles operations related to doctor visit summaries
 */
class DoctorVisitController {
  /**
   * Create a doctor visit summary
   * @param {String} userId - User ID
   * @param {Object} summaryData - Doctor visit summary data
   * @returns {Object} - Created doctor visit summary
   */
  async createDoctorVisitSummary(userId, summaryData) {
    try {
      const doctorVisit = new DoctorVisit({
        user: userId,
        periodStart: summaryData.periodStart,
        periodEnd: summaryData.periodEnd,
        keySymptoms: summaryData.keySymptoms || [],
        overallPatterns: summaryData.overallPatterns || [],
        questions: summaryData.questions || [],
        notes: summaryData.notes || '',
        sharedWith: summaryData.sharedWith || [],
        aiGenerated: summaryData.aiGenerated !== undefined ? summaryData.aiGenerated : true
      });

      await doctorVisit.save();
      return doctorVisit;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Generate a doctor visit summary automatically
   * @param {String} userId - User ID
   * @param {Date} startDate - Start date
   * @param {Date} endDate - End date
   * @returns {Object} - Generated doctor visit summary
   */
  async generateDoctorVisitSummary(userId, startDate, endDate) {
    try {
      // Get health summary for the period
      const healthSummary = await HealthDataController.getHealthSummary(
        userId,
        startDate,
        endDate
      );

      // Extract key symptoms
      const keySymptoms = Object.entries(healthSummary.symptoms).map(([name, data]) => ({
        name,
        occurrences: data.count,
        avgSeverity: data.avgSeverity
      }));

      // Generate overall patterns (would be AI-generated in a real implementation)
      const overallPatterns = [
        `Symptoms were most frequent on days with less than average sleep.`,
        `Higher activity levels correlated with improved mood and energy levels.`,
        `Stress tags were present on 75% of days with reported symptoms.`
      ];

      // Generate common questions (would be personalized in a real implementation)
      const questions = [
        "Could my symptoms be related to my sleep patterns?",
        "Are there specific lifestyle changes you'd recommend based on these patterns?",
        "Should I be tracking any additional health metrics?"
      ];

      // Create the doctor visit summary
      const doctorVisit = new DoctorVisit({
        user: userId,
        periodStart: startDate,
        periodEnd: endDate,
        keySymptoms,
        overallPatterns,
        questions,
        aiGenerated: true
      });

      await doctorVisit.save();
      return doctorVisit;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get doctor visit summaries for a user
   * @param {String} userId - User ID
   * @returns {Array} - Doctor visit summaries
   */
  async getDoctorVisitSummaries(userId) {
    try {
      return await DoctorVisit.find({ user: userId })
        .sort({ generatedDate: -1 });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get a doctor visit summary by ID
   * @param {String} summaryId - Summary ID
   * @param {String} userId - User ID for verification
   * @returns {Object} - Doctor visit summary
   */
  async getDoctorVisitSummaryById(summaryId, userId) {
    try {
      const summary = await DoctorVisit.findOne({
        _id: summaryId,
        user: userId
      });

      if (!summary) {
        throw new Error('Doctor visit summary not found');
      }

      return summary;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update a doctor visit summary
   * @param {String} summaryId - Summary ID
   * @param {String} userId - User ID for verification
   * @param {Object} updateData - Data to update
   * @returns {Object} - Updated doctor visit summary
   */
  async updateDoctorVisitSummary(summaryId, userId, updateData) {
    try {
      const summary = await DoctorVisit.findOne({
        _id: summaryId,
        user: userId
      });

      if (!summary) {
        throw new Error('Doctor visit summary not found');
      }

      // Update fields
      if (updateData.keySymptoms) summary.keySymptoms = updateData.keySymptoms;
      if (updateData.overallPatterns) summary.overallPatterns = updateData.overallPatterns;
      if (updateData.questions) summary.questions = updateData.questions;
      if (updateData.notes !== undefined) summary.notes = updateData.notes;
      if (updateData.sharedWith) summary.sharedWith = updateData.sharedWith;

      await summary.save();
      return summary;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Add a question to a doctor visit summary
   * @param {String} summaryId - Summary ID
   * @param {String} userId - User ID for verification
   * @param {String} question - Question to add
   * @returns {Object} - Updated doctor visit summary
   */
  async addQuestionToSummary(summaryId, userId, question) {
    try {
      const summary = await DoctorVisit.findOne({
        _id: summaryId,
        user: userId
      });

      if (!summary) {
        throw new Error('Doctor visit summary not found');
      }

      summary.questions.push(question);
      await summary.save();
      return summary;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Share a doctor visit summary with an email address
   * @param {String} summaryId - Summary ID
   * @param {String} userId - User ID for verification
   * @param {String} email - Email to share with
   * @returns {Object} - Updated doctor visit summary
   */
  async shareSummary(summaryId, userId, email) {
    try {
      const summary = await DoctorVisit.findOne({
        _id: summaryId,
        user: userId
      });

      if (!summary) {
        throw new Error('Doctor visit summary not found');
      }

      if (!summary.sharedWith.includes(email)) {
        summary.sharedWith.push(email);
      }
      
      await summary.save();
      return summary;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new DoctorVisitController();
