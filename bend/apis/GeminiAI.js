const axios = require('axios');
require('dotenv').config();

/**
 * GeminiAI - Interface for the Gemini AI API
 */
class GeminiAI {
  constructor() {
    this.apiKey = process.env.GEMINI_API_KEY;
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-pro';
  }

  /**
   * Generate a weekly health narrative based on health summary data
   * @param {Object} healthSummary - Health summary data
   * @returns {String} - Generated narrative
   */
  async generateWeeklyNarrative(healthSummary) {
    try {
      // For the MVP, we'll use a mock response
      if (process.env.NODE_ENV === 'production' && this.apiKey) {
        // In a real implementation, this would be an API call to Gemini
        const prompt = this.buildWeeklyNarrativePrompt(healthSummary);
        const response = await this.callGeminiAPI(prompt);
        return response;
      } else {
        // Mock response for development
        return this.mockWeeklyNarrative(healthSummary);
      }
    } catch (error) {
      console.error('Error generating weekly narrative:', error);
      return 'We were unable to generate a health narrative at this time. Please try again later.';
    }
  }

  /**
   * Generate insights for pattern analysis
   * @param {Object} analysisData - Pattern analysis data
   * @returns {Array} - Generated insights
   */
  async generatePatternInsights(analysisData) {
    try {
      // For the MVP, we'll use a mock response
      if (process.env.NODE_ENV === 'production' && this.apiKey) {
        // In a real implementation, this would be an API call to Gemini
        const prompt = this.buildPatternInsightsPrompt(analysisData);
        const response = await this.callGeminiAPI(prompt);
        return this.parseInsightsResponse(response);
      } else {
        // Mock response for development
        return this.mockPatternInsights(analysisData);
      }
    } catch (error) {
      console.error('Error generating pattern insights:', error);
      return [{
        title: 'Error',
        content: 'We were unable to generate insights at this time. Please try again later.'
      }];
    }
  }

  /**
   * Make an API call to Gemini
   * @param {String} prompt - The prompt to send to Gemini
   * @returns {String} - The response from Gemini
   */
  async callGeminiAPI(prompt) {
    try {
      const response = await axios.post(
        `${this.baseUrl}:generateContent?key=${this.apiKey}`,
        {
          contents: [
            {
              parts: [{ text: prompt }]
            }
          ],
          generationConfig: {
            temperature: 0.4,
            maxOutputTokens: 2048
          }
        }
      );

      return response.data.candidates[0].content.parts[0].text;
    } catch (error) {
      console.error('Error calling Gemini API:', error);
      throw error;
    }
  }

  /**
   * Build a prompt for weekly narrative generation
   * @param {Object} healthSummary - Health summary data
   * @returns {String} - Prompt for Gemini
   */
  buildWeeklyNarrativePrompt(healthSummary) {
    return `
      Generate a brief, personalized weekly health summary based on the following data:
      
      Period: ${healthSummary.period.start} to ${healthSummary.period.end}
      Journal entries: ${healthSummary.entries}
      
      Mood average: ${healthSummary.mood.average}/5
      Energy average: ${healthSummary.energy.average}/5
      
      Sleep average: ${healthSummary.sleep.average} hours
      Activity: Average ${healthSummary.activity.averageSteps} steps per day
      Resting heart rate average: ${healthSummary.heartRate.averageResting} bpm
      
      Symptoms reported:
      ${Object.entries(healthSummary.symptoms).map(([name, data]) => 
        `- ${name}: ${data.count} occurrences, average severity ${data.avgSeverity}/10`
      ).join('\n')}
      
      Write a brief, conversational health narrative (3-4 sentences) highlighting key trends and correlations. Address the user directly and be encouraging without giving medical advice.
    `;
  }

  /**
   * Build a prompt for pattern insights generation
   * @param {Object} analysisData - Pattern analysis data
   * @returns {String} - Prompt for Gemini
   */
  buildPatternInsightsPrompt(analysisData) {
    return `
      Generate insights for a symptom pattern analysis based on the following data:
      
      Symptom: ${analysisData.symptom}
      
      Sleep:
      - On symptom days: ${analysisData.sleepSymptomAvg} hours
      - On non-symptom days: ${analysisData.sleepNonSymptomAvg} hours
      
      Physical Activity:
      - On symptom days: ${analysisData.stepsSymptomAvg} steps
      - On non-symptom days: ${analysisData.stepsNonSymptomAvg} steps
      
      Common tags on symptom days: ${analysisData.commonTags.slice(0, 3).join(', ')}
      
      Generate 3 brief insights (one each for sleep, activity, and tags) explaining the correlation between these factors and the symptom. Format each insight with a title and a brief explanation (1-2 sentences). Be informative without giving medical advice.
    `;
  }

  /**
   * Parse the insights response from Gemini
   * @param {String} response - Response from Gemini
   * @returns {Array} - Parsed insights
   */
  parseInsightsResponse(response) {
    // This would parse a structured response from Gemini
    // For simplicity, we'll assume a format for now
    const insights = [];
    
    // Basic parsing logic (would be more robust in a real implementation)
    const sections = response.split('\n\n');
    for (const section of sections) {
      if (section.trim()) {
        const lines = section.split('\n');
        if (lines.length >= 2) {
          insights.push({
            title: lines[0].replace('###', '').trim(),
            content: lines.slice(1).join(' ').trim()
          });
        }
      }
    }
    
    return insights;
  }

  /**
   * Generate a mock weekly narrative for development
   * @param {Object} healthSummary - Health summary data
   * @returns {String} - Mock narrative
   */
  mockWeeklyNarrative(healthSummary) {
    // Check if there are any symptoms
    const hasSymptoms = Object.keys(healthSummary.symptoms).length > 0;
    const firstSymptom = hasSymptoms ? Object.keys(healthSummary.symptoms)[0] : null;
    
    if (hasSymptoms && firstSymptom) {
      return `This week, you reported ${healthSummary.symptoms[firstSymptom].count} days with ${firstSymptom.toLowerCase()}, typically rating it at ${healthSummary.symptoms[firstSymptom].avgSeverity}/10 severity. Your energy levels tended to be higher on days when you slept more than 7 hours and took more than 8,000 steps. I noticed your mood was generally better on days with more physical activity, and your heart rate was slightly elevated on days when you reported symptoms.`;
    } else {
      return `This week, your overall mood averaged ${healthSummary.mood.average}/5 and your energy level was ${healthSummary.energy.average}/5. You averaged ${healthSummary.sleep.average} hours of sleep and ${healthSummary.activity.averageSteps} steps per day. Your data suggests a connection between better sleep and improved mood, with your best days occurring when you had both adequate sleep and physical activity.`;
    }
  }

  /**
   * Generate mock pattern insights for development
   * @param {Object} analysisData - Pattern analysis data
   * @returns {Array} - Mock insights
   */
  mockPatternInsights(analysisData) {
    return [
      {
        title: 'Sleep Correlation',
        content: `On days with ${analysisData.symptom}, you averaged ${analysisData.sleepSymptomAvg} hours of sleep compared to ${analysisData.sleepNonSymptomAvg} hours on symptom-free days.`
      },
      {
        title: 'Activity Correlation',
        content: `Your step count was ${analysisData.stepsSymptomAvg < analysisData.stepsNonSymptomAvg ? 'lower' : 'higher'} on days with ${analysisData.symptom} (${analysisData.stepsSymptomAvg} vs ${analysisData.stepsNonSymptomAvg} steps).`
      },
      {
        title: 'Tag Correlation',
        content: analysisData.commonTags.length > 0 
          ? `The tag #${analysisData.commonTags[0]} appears frequently on days with ${analysisData.symptom}.`
          : `No specific tags were found to correlate with your ${analysisData.symptom} days.`
      }
    ];
  }
}

module.exports = new GeminiAI();
