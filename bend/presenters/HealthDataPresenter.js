const { HealthDataController } = require('../controllers');
const GeminiAI = require('../apis/GeminiAI');

/**
 * HealthDataPresenter - Handles presenting health data for the API
 */
class HealthDataPresenter {
  /**
   * Add health metrics
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async addHealthMetric(req, res) {
    try {
      const { userId } = req.params;
      const { metricType, values, date, source, notes } = req.body;
      
      if (!metricType || !values) {
        return res.status(400).json({
          success: false,
          error: 'Metric type and values are required'
        });
      }
      
      const metric = await HealthDataController.addHealthMetric(userId, metricType, {
        date,
        values,
        source,
        notes
      });
      
      return res.status(201).json({
        success: true,
        data: this.formatHealthMetric(metric)
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Get health metrics by type
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async getHealthMetrics(req, res) {
    try {
      const { userId } = req.params;
      const { metricType, startDate, endDate } = req.query;
      
      if (!metricType) {
        return res.status(400).json({
          success: false,
          error: 'Metric type is required'
        });
      }
      
      const start = startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000); // Default to last 30 days
      const end = endDate ? new Date(endDate) : new Date();
      
      const metrics = await HealthDataController.getHealthMetricsByType(
        userId,
        metricType,
        start,
        end
      );
      
      return res.status(200).json({
        success: true,
        data: metrics.map(metric => this.formatHealthMetric(metric))
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Get health summary
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async getHealthSummary(req, res) {
    try {
      const { userId } = req.params;
      const { startDate, endDate } = req.query;
      
      const start = startDate ? new Date(startDate) : new Date(Date.now() - 7 * 24 * 60 * 60 * 1000); // Default to last 7 days
      const end = endDate ? new Date(endDate) : new Date();
      
      const summary = await HealthDataController.getHealthSummary(userId, start, end);
      
      return res.status(200).json({
        success: true,
        data: summary
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Get weekly narrative
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async getWeeklyNarrative(req, res) {
    try {
      const { userId } = req.params;
      
      // Get health summary for the last 7 days
      const endDate = new Date();
      const startDate = new Date(endDate.getTime() - 7 * 24 * 60 * 60 * 1000);
      
      const summary = await HealthDataController.getHealthSummary(userId, startDate, endDate);
      
      // Generate narrative using AI
      const narrative = await GeminiAI.generateWeeklyNarrative(summary);
      
      return res.status(200).json({
        success: true,
        data: {
          narrative,
          summary
        }
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Analyze symptom patterns
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async analyzeSymptomPatterns(req, res) {
    try {
      const { userId } = req.params;
      const { symptom, startDate, endDate } = req.query;
      
      if (!symptom) {
        return res.status(400).json({
          success: false,
          error: 'Symptom name is required'
        });
      }
      
      const start = startDate ? new Date(startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000); // Default to last 30 days
      const end = endDate ? new Date(endDate) : new Date();
      
      const analysis = await HealthDataController.analyzeSymptomPatterns(
        userId,
        symptom,
        start,
        end
      );
      
      // Get AI-powered insights
      const insights = await GeminiAI.generatePatternInsights({
        symptom: analysis.symptom,
        sleepSymptomAvg: analysis.comparisons.sleep.symptomDaysAvg,
        sleepNonSymptomAvg: analysis.comparisons.sleep.nonSymptomDaysAvg,
        stepsSymptomAvg: analysis.comparisons.activity.symptomDaysAvg,
        stepsNonSymptomAvg: analysis.comparisons.activity.nonSymptomDaysAvg,
        commonTags: Object.keys(analysis.tags.symptomDays).length > 0 
          ? Object.keys(analysis.tags.symptomDays).sort((a, b) => 
              analysis.tags.symptomDays[b] - analysis.tags.symptomDays[a]
            )
          : []
      });
      
      return res.status(200).json({
        success: true,
        data: {
          ...analysis,
          insights
        }
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Format a health metric for the API response
   * @param {Object} metric - Health metric document
   * @returns {Object} - Formatted health metric
   */
  formatHealthMetric(metric) {
    return {
      id: metric._id,
      date: metric.date,
      metricType: metric.metricType,
      values: metric.values,
      source: metric.source,
      notes: metric.notes
    };
  }
}

module.exports = new HealthDataPresenter();
