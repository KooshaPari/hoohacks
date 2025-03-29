const { DoctorVisitController } = require('../controllers');

/**
 * DoctorVisitPresenter - Handles presenting doctor visit data for the API
 */
class DoctorVisitPresenter {
  /**
   * Create a doctor visit summary
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async createDoctorVisitSummary(req, res) {
    try {
      const { userId } = req.params;
      const summaryData = req.body;
      
      const summary = await DoctorVisitController.createDoctorVisitSummary(userId, summaryData);
      
      return res.status(201).json({
        success: true,
        data: this.formatDoctorVisitSummary(summary)
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Generate a doctor visit summary
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async generateDoctorVisitSummary(req, res) {
    try {
      const { userId } = req.params;
      const { startDate, endDate } = req.query;
      
      const start = startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000); // Default to last 30 days
      const end = endDate ? new Date(endDate) : new Date();
      
      const summary = await DoctorVisitController.generateDoctorVisitSummary(userId, start, end);
      
      return res.status(201).json({
        success: true,
        data: this.formatDoctorVisitSummary(summary)
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Get doctor visit summaries
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async getDoctorVisitSummaries(req, res) {
    try {
      const { userId } = req.params;
      
      const summaries = await DoctorVisitController.getDoctorVisitSummaries(userId);
      
      return res.status(200).json({
        success: true,
        data: summaries.map(summary => this.formatDoctorVisitSummary(summary))
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Get a doctor visit summary by ID
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async getDoctorVisitSummaryById(req, res) {
    try {
      const { userId, summaryId } = req.params;
      
      const summary = await DoctorVisitController.getDoctorVisitSummaryById(summaryId, userId);
      
      return res.status(200).json({
        success: true,
        data: this.formatDoctorVisitSummary(summary)
      });
    } catch (error) {
      return res.status(404).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Update a doctor visit summary
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async updateDoctorVisitSummary(req, res) {
    try {
      const { userId, summaryId } = req.params;
      const updateData = req.body;
      
      const summary = await DoctorVisitController.updateDoctorVisitSummary(
        summaryId,
        userId,
        updateData
      );
      
      return res.status(200).json({
        success: true,
        data: this.formatDoctorVisitSummary(summary)
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Add a question to a doctor visit summary
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async addQuestionToSummary(req, res) {
    try {
      const { userId, summaryId } = req.params;
      const { question } = req.body;
      
      if (!question) {
        return res.status(400).json({
          success: false,
          error: 'Question is required'
        });
      }
      
      const summary = await DoctorVisitController.addQuestionToSummary(
        summaryId,
        userId,
        question
      );
      
      return res.status(200).json({
        success: true,
        data: this.formatDoctorVisitSummary(summary)
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Share a doctor visit summary
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async shareSummary(req, res) {
    try {
      const { userId, summaryId } = req.params;
      const { email } = req.body;
      
      if (!email) {
        return res.status(400).json({
          success: false,
          error: 'Email is required'
        });
      }
      
      const summary = await DoctorVisitController.shareSummary(
        summaryId,
        userId,
        email
      );
      
      return res.status(200).json({
        success: true,
        data: this.formatDoctorVisitSummary(summary)
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Format a doctor visit summary for the API response
   * @param {Object} summary - Doctor visit summary document
   * @returns {Object} - Formatted doctor visit summary
   */
  formatDoctorVisitSummary(summary) {
    return {
      id: summary._id,
      generatedDate: summary.generatedDate,
      periodStart: summary.periodStart,
      periodEnd: summary.periodEnd,
      keySymptoms: summary.keySymptoms,
      overallPatterns: summary.overallPatterns,
      questions: summary.questions,
      notes: summary.notes,
      sharedWith: summary.sharedWith,
      aiGenerated: summary.aiGenerated
    };
  }
}

module.exports = new DoctorVisitPresenter();
