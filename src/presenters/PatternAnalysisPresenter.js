import HealthDataController from '../controllers/HealthDataController';

/**
 * PatternAnalysisPresenter - Handles presenting data for the Pattern Analysis view
 */
class PatternAnalysisPresenter {
  constructor() {
    this.healthDataController = new HealthDataController();
  }

  /**
   * Get pattern analysis data for a symptom
   * @param {String} symptom - The symptom to analyze
   * @returns {Object} - Pattern analysis data
   */
  getPatternAnalysisData(symptom = 'Headache') {
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(endDate.getDate() - 30);
    
    const analysis = this.healthDataController.getPatternAnalysis(
      symptom,
      startDate,
      endDate
    );
    
    // Format the data for presentation
    return {
      symptom: analysis.symptom,
      period: {
        start: new Date(analysis.period.start).toLocaleDateString(),
        end: new Date(analysis.period.end).toLocaleDateString()
      },
      occurrences: {
        withSymptom: analysis.symptomDaysCount,
        withoutSymptom: analysis.nonSymptomDaysCount,
        percentage: Math.round((analysis.symptomDaysCount / 
          (analysis.symptomDaysCount + analysis.nonSymptomDaysCount)) * 100)
      },
      comparisons: [
        {
          factor: 'Sleep Duration',
          withSymptom: `${analysis.comparisons.sleep.symptomDaysAvg} hours`,
          withoutSymptom: `${analysis.comparisons.sleep.nonSymptomDaysAvg} hours`,
          difference: `${Math.abs(analysis.comparisons.sleep.difference).toFixed(1)} hours ${
            analysis.comparisons.sleep.difference > 0 ? 'less' : 'more'
          }`
        },
        {
          factor: 'Physical Activity',
          withSymptom: `${analysis.comparisons.activity.symptomDaysAvg} steps`,
          withoutSymptom: `${analysis.comparisons.activity.nonSymptomDaysAvg} steps`,
          difference: `${Math.abs(analysis.comparisons.activity.difference).toFixed(0)} steps ${
            analysis.comparisons.activity.difference > 0 ? 'less' : 'more'
          }`
        }
      ],
      tags: this.formatTagsComparison(
        analysis.tags.symptomDays, 
        analysis.tags.nonSymptomDays,
        analysis.symptomDaysCount,
        analysis.nonSymptomDaysCount
      )
    };
  }

  /**
   * Format tags comparison data
   * @param {Object} symptomTags - Tags from symptom days
   * @param {Object} nonSymptomTags - Tags from non-symptom days
   * @param {Number} symptomCount - Number of symptom days
   * @param {Number} nonSymptomCount - Number of non-symptom days
   * @returns {Array} - Formatted tag comparison data
   */
  formatTagsComparison(symptomTags, nonSymptomTags, symptomCount, nonSymptomCount) {
    const allTags = new Set([
      ...Object.keys(symptomTags),
      ...Object.keys(nonSymptomTags)
    ]);
    
    return Array.from(allTags).map(tag => {
      const symptomFreq = symptomTags[tag] || 0;
      const nonSymptomFreq = nonSymptomTags[tag] || 0;
      
      const symptomPercentage = symptomCount > 0 
        ? Math.round((symptomFreq / symptomCount) * 100) 
        : 0;
        
      const nonSymptomPercentage = nonSymptomCount > 0 
        ? Math.round((nonSymptomFreq / nonSymptomCount) * 100) 
        : 0;
      
      return {
        tag,
        symptomPercentage,
        nonSymptomPercentage,
        difference: symptomPercentage - nonSymptomPercentage
      };
    }).sort((a, b) => Math.abs(b.difference) - Math.abs(a.difference));
  }

  /**
   * Get available symptoms for analysis
   * @returns {Array} - List of available symptoms
   */
  getAvailableSymptoms() {
    const allEntries = this.healthDataController.healthData.journalEntries;
    const symptoms = new Set();
    
    allEntries.forEach(entry => {
      entry.symptoms.forEach(symptom => {
        symptoms.add(symptom.name);
      });
    });
    
    return Array.from(symptoms);
  }
}

export default PatternAnalysisPresenter;
