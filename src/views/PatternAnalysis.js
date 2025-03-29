import React, { useState, useEffect } from 'react';
import PatternAnalysisPresenter from '../presenters/PatternAnalysisPresenter';

function PatternAnalysis() {
  const [selectedSymptom, setSelectedSymptom] = useState('Headache');
  const [analysisData, setAnalysisData] = useState(null);
  const [availableSymptoms, setAvailableSymptoms] = useState([]);
  const [loading, setLoading] = useState(true);
  const presenter = new PatternAnalysisPresenter();
  
  useEffect(() => {
    // Get available symptoms from presenter
    const symptoms = presenter.getAvailableSymptoms();
    setAvailableSymptoms(symptoms);
    
    // Get initial analysis data
    const data = presenter.getPatternAnalysisData(selectedSymptom);
    setAnalysisData(data);
    setLoading(false);
  }, []);
  
  const handleSymptomChange = (e) => {
    const symptom = e.target.value;
    setSelectedSymptom(symptom);
    setLoading(true);
    
    // Get analysis data for the selected symptom
    const data = presenter.getPatternAnalysisData(symptom);
    setAnalysisData(data);
    setLoading(false);
  };
  
  if (loading) {
    return <div className="loading">Loading pattern analysis data...</div>;
  }
  
  return (
    <div className="pattern-analysis">
      <h2>Pattern Analysis</h2>
      
      {/* Symptom Selection */}
      <div className="card">
        <h3>Select Symptom to Analyze</h3>
        
        {availableSymptoms.length === 0 ? (
          <p>No symptoms logged yet. Start tracking symptoms in your daily journal.</p>
        ) : (
          <div className="symptom-selector">
            <select
              value={selectedSymptom}
              onChange={handleSymptomChange}
              className="form-control"
            >
              {availableSymptoms.map(symptom => (
                <option key={symptom} value={symptom}>{symptom}</option>
              ))}
            </select>
          </div>
        )}
      </div>
      
      {availableSymptoms.length > 0 && analysisData && (
        <>
          {/* Analysis Overview */}
          <div className="card">
            <h3>{analysisData.symptom} Analysis</h3>
            <p className="period">Period: {analysisData.period.start} - {analysisData.period.end}</p>
            
            <div className="occurrence-summary">
              <p>
                You experienced {analysisData.symptom} on <strong>{analysisData.occurrences.withSymptom}</strong> out 
                of {analysisData.occurrences.withSymptom + analysisData.occurrences.withoutSymptom} days 
                ({analysisData.occurrences.percentage}%).
              </p>
            </div>
          </div>
          
          {/* Factor Comparisons */}
          <div className="card">
            <h3>Key Factors Comparison</h3>
            <p className="subtitle">Differences between days with and without {analysisData.symptom}</p>
            
            <div className="factors-table">
              <table>
                <thead>
                  <tr>
                    <th>Factor</th>
                    <th>With {analysisData.symptom}</th>
                    <th>Without {analysisData.symptom}</th>
                    <th>Difference</th>
                  </tr>
                </thead>
                <tbody>
                  {analysisData.comparisons.map((comparison, index) => (
                    <tr key={index}>
                      <td>{comparison.factor}</td>
                      <td>{comparison.withSymptom}</td>
                      <td>{comparison.withoutSymptom}</td>
                      <td>{comparison.difference}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
          
          {/* Tags Analysis */}
          <div className="card">
            <h3>Tag Frequency Analysis</h3>
            
            {analysisData.tags.length === 0 ? (
              <p>No tags available for analysis. Try adding tags to your journal entries.</p>
            ) : (
              <div className="tags-comparison">
                <table>
                  <thead>
                    <tr>
                      <th>Tag</th>
                      <th>% of days with {analysisData.symptom}</th>
                      <th>% of days without {analysisData.symptom}</th>
                      <th>Difference</th>
                    </tr>
                  </thead>
                  <tbody>
                    {analysisData.tags.map((tag, index) => (
                      <tr key={index}>
                        <td>#{tag.tag}</td>
                        <td>{tag.symptomPercentage}%</td>
                        <td>{tag.nonSymptomPercentage}%</td>
                        <td className={tag.difference > 0 ? 'positive-diff' : 'negative-diff'}>
                          {tag.difference > 0 ? '+' : ''}{tag.difference}%
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
          
          {/* Pattern Insights */}
          <div className="card">
            <h3>Insights</h3>
            <p className="subtitle">Based on your data, here are some potential patterns:</p>
            
            <div className="insights-list">
              <div className="insight-item">
                <h4>Sleep Correlation</h4>
                <p>
                  On days with {analysisData.symptom}, you slept 
                  <strong> {Math.abs(analysisData.comparisons[0].difference).split(' ')[0]} hours {
                    analysisData.comparisons[0].difference.includes('less') ? 'less' : 'more'
                  }</strong> on average.
                </p>
              </div>
              
              <div className="insight-item">
                <h4>Activity Correlation</h4>
                <p>
                  Your step count was <strong>{
                    analysisData.comparisons[1].difference.includes('less') ? 'lower' : 'higher'
                  }</strong> on days with {analysisData.symptom} 
                  (difference of <strong>{Math.abs(analysisData.comparisons[1].difference).split(' ')[0]} steps</strong>).
                </p>
              </div>
              
              {analysisData.tags.length > 0 && (
                <div className="insight-item">
                  <h4>Tag Correlation</h4>
                  <p>
                    The tag <strong>#{analysisData.tags[0].tag}</strong> appears 
                    <strong> {Math.abs(analysisData.tags[0].difference)}% {
                      analysisData.tags[0].difference > 0 ? 'more' : 'less'
                    } often</strong> on days with {analysisData.symptom}.
                  </p>
                </div>
              )}
            </div>
            
            <div className="insight-disclaimer">
              <strong>Note:</strong> These are observed correlations only, not necessarily cause-and-effect relationships.
            </div>
          </div>
        </>
      )}
    </div>
  );
}

export default PatternAnalysis;
