/**
 * Mock Gemini API Service
 * In a real implementation, this would make API calls to the Gemini API
 */

exports.generateWeeklyNarrative = async (summary) => {
  // Mock API call to Gemini
  console.log('Generating weekly narrative with summary:', summary);
  
  // Simulate API delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  // In a real implementation, we would use the Gemini API to generate this text
  let narrative = `This week, you logged ${Object.keys(summary.symptoms).length} different symptoms. `;
  
  if (summary.symptoms.Headache) {
    narrative += `You experienced headaches on ${summary.symptoms.Headache.count} days, with an average severity of ${summary.symptoms.Headache.avgSeverity}/10. `;
  }
  
  narrative += `Your average mood was ${summary.mood.average}/5 and energy was ${summary.energy.average}/5. `;
  narrative += `You slept an average of ${summary.sleep.average} hours per night and took an average of ${summary.activity.averageSteps} steps per day. `;
  
  if (summary.heartRate.averageResting) {
    narrative += `Your average resting heart rate was ${summary.heartRate.averageResting} bpm. `;
  }
  
  narrative += `Based on your data, there seems to be a connection between your sleep duration and your overall mood and energy levels. `;
  
  if (summary.symptoms.Headache && summary.sleep.average < 7) {
    narrative += `On days when you experienced headaches, you tended to get less sleep than your weekly average. `;
  }
  
  narrative += `Days with higher step counts generally corresponded with better mood and energy ratings.`;
  
  return narrative;
};

exports.generatePatternInsights = async (analysis) => {
  // Mock API call to Gemini
  console.log('Generating pattern insights with analysis:', analysis);
  
  // Simulate API delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  // In a real implementation, we would use the Gemini API to generate insights
  const insights = [];
  
  // Sleep insight
  if (analysis.comparisons.sleep.difference !== 0) {
    const sleepDiff = Math.abs(analysis.comparisons.sleep.difference).toFixed(1);
    const sleepTrend = analysis.comparisons.sleep.difference > 0 ? 'less' : 'more';
    
    insights.push({
      factor: 'Sleep Duration',
      insight: `On days with ${analysis.symptom}, you slept ${sleepDiff} hours ${sleepTrend} on average compared to symptom-free days. This suggests a potential connection between your sleep patterns and ${analysis.symptom.toLowerCase()} frequency.`
    });
  }
  
  // Activity insight
  if (analysis.comparisons.activity.difference !== 0) {
    const stepsDiff = Math.abs(analysis.comparisons.activity.difference).toFixed(0);
    const stepsTrend = analysis.comparisons.activity.difference > 0 ? 'fewer' : 'more';
    
    insights.push({
      factor: 'Physical Activity',
      insight: `Your step count was ${stepsDiff} steps ${stepsTrend} on days with ${analysis.symptom} compared to symptom-free days. This pattern might suggest a relationship between your activity level and ${analysis.symptom.toLowerCase()} occurrence.`
    });
  }
  
  // Tag insight
  const tagsSymptom = Object.entries(analysis.tags.symptomDays || {}).sort((a, b) => b[1] - a[1]);
  const tagsNonSymptom = Object.entries(analysis.tags.nonSymptomDays || {}).sort((a, b) => b[1] - a[1]);
  
  if (tagsSymptom.length > 0) {
    const topTag = tagsSymptom[0][0];
    
    insights.push({
      factor: 'Associated Factors',
      insight: `The tag "#${topTag}" appears more frequently on days when you experience ${analysis.symptom}. This might be worth exploring further to understand potential triggers or associations.`
    });
  }
  
  // Generic insight if no specific patterns found
  if (insights.length === 0) {
    insights.push({
      factor: 'Overall Patterns',
      insight: `Based on the available data, no strong patterns have emerged yet relating to your ${analysis.symptom.toLowerCase()}. Continue tracking to gather more data for better insights.`
    });
  }
  
  return insights;
};

exports.generateDoctorVisitSummary = async (summaryData) => {
  // Mock API call to Gemini
  console.log('Generating doctor visit summary with data:', summaryData);
  
  // Simulate API delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  // In a real implementation, we would use the Gemini API to generate this
  const doctorSummary = {
    keySymptoms: summaryData.keySymptoms.map(symptom => ({
      name: symptom.name,
      occurrences: symptom.occurrences,
      avgSeverity: symptom.avgSeverity
    })),
    overallPatterns: []
  };
  
  // Generate patterns based on the data
  if (summaryData.keySymptoms.length > 0) {
    const topSymptom = summaryData.keySymptoms[0];
    
    // Sleep pattern
    if (summaryData.sleep.average < 7) {
      doctorSummary.overallPatterns.push(
        `${topSymptom.name} occurred most frequently on days following less than 7 hours of sleep.`
      );
    }
    
    // Activity pattern
    if (summaryData.activity.averageSteps < 5000) {
      doctorSummary.overallPatterns.push(
        `Lower physical activity days (under 5,000 steps) show a correlation with higher symptom occurrence.`
      );
    }
    
    // Tag patterns
    const tags = Object.entries(summaryData.tags).sort((a, b) => b[1] - a[1]);
    if (tags.length > 0) {
      doctorSummary.overallPatterns.push(
        `The tag "#${tags[0][0]}" appears in ${tags[0][1]} entries and may be associated with symptom days.`
      );
    }
  }
  
  // Default pattern if none found
  if (doctorSummary.overallPatterns.length === 0) {
    doctorSummary.overallPatterns.push(
      `No clear patterns have emerged from the current data. Continue tracking for better insights.`
    );
  }
  
  // Questions for doctor
  doctorSummary.questions = [
    "Could my symptoms be related to my sleep patterns?",
    "Are there specific lifestyle changes you'd recommend based on these patterns?",
    "Should I be concerned about the frequency of these symptoms?"
  ];
  
  if (summaryData.keySymptoms.length > 0) {
    doctorSummary.questions.push(
      `What might be causing my ${summaryData.keySymptoms[0].name.toLowerCase()} and how can I manage it better?`
    );
  }
  
  return doctorSummary;
};
