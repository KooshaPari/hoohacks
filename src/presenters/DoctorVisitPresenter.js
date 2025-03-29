import HealthDataController from '../controllers/HealthDataController';

/**
 * DoctorVisitPresenter - Handles presenting data for the Doctor Visit view
 */
class DoctorVisitPresenter {
  constructor() {
    this.healthDataController = new HealthDataController();
  }

  /**
   * Get doctor visit summary data
   * @returns {Object} - Doctor visit summary data
   */
  getDoctorVisitSummary() {
    const summary = this.healthDataController.getDoctorVisitSummary();
    
    // Format the data for presentation
    return {
      period: {
        start: new Date(summary.period.start).toLocaleDateString(),
        end: new Date(summary.period.end).toLocaleDateString()
      },
      keySymptoms: summary.keySymptoms.map(symptom => ({
        name: symptom.name,
        occurrences: symptom.occurrences,
        avgSeverity: symptom.avgSeverity
      })),
      overallPatterns: summary.overallPatterns,
      questions: summary.questions
    };
  }

  /**
   * Add a question to the doctor visit summary
   * @param {String} question - The question to add
   * @returns {Array} - Updated list of questions
   */
  addQuestion(question) {
    // In a real implementation, this would update the model
    // For this MVP, we'll just return a mock updated list
    const summary = this.healthDataController.getDoctorVisitSummary();
    return [...summary.questions, question];
  }

  /**
   * Generate a printable/shareable version of the summary
   * @returns {String} - Formatted summary text
   */
  generateShareableText() {
    const summary = this.healthDataController.getDoctorVisitSummary();
    
    let text = `Health Summary: ${new Date(summary.period.start).toLocaleDateString()} - ${new Date(summary.period.end).toLocaleDateString()}\n\n`;
    
    text += "Key Symptoms Reported:\n";
    summary.keySymptoms.forEach(symptom => {
      text += `- ${symptom.name}: ${symptom.occurrences} occurrences (avg. severity ${symptom.avgSeverity}/10)\n`;
    });
    
    text += "\nOverall Patterns:\n";
    summary.overallPatterns.forEach(pattern => {
      text += `- ${pattern}\n`;
    });
    
    text += "\nQuestions for Doctor:\n";
    summary.questions.forEach(question => {
      text += `- ${question}\n`;
    });
    
    return text;
  }
}

export default DoctorVisitPresenter;
