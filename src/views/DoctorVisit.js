import React, { useState, useEffect } from 'react';
import DoctorVisitPresenter from '../presenters/DoctorVisitPresenter';

function DoctorVisit() {
  const [summaryData, setSummaryData] = useState(null);
  const [newQuestion, setNewQuestion] = useState('');
  const [questions, setQuestions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [shareableText, setShareableText] = useState('');
  const [showShareable, setShowShareable] = useState(false);
  const presenter = new DoctorVisitPresenter();
  
  useEffect(() => {
    // Get doctor visit summary from presenter
    const data = presenter.getDoctorVisitSummary();
    setSummaryData(data);
    setQuestions(data.questions);
    setLoading(false);
  }, []);
  
  const handleQuestionChange = (e) => {
    setNewQuestion(e.target.value);
  };
  
  const handleAddQuestion = (e) => {
    e.preventDefault();
    if (newQuestion.trim()) {
      // Add question via presenter
      const updatedQuestions = [...questions, newQuestion];
      setQuestions(updatedQuestions);
      setNewQuestion('');
    }
  };
  
  const handleGenerateShareable = () => {
    // Generate shareable text via presenter
    const text = presenter.generateShareableText();
    setShareableText(text);
    setShowShareable(true);
  };
  
  const handleCopyText = () => {
    navigator.clipboard.writeText(shareableText)
      .then(() => {
        alert('Summary copied to clipboard!');
      })
      .catch(err => {
        console.error('Could not copy text: ', err);
      });
  };
  
  if (loading) {
    return <div className="loading">Loading doctor visit summary...</div>;
  }
  
  return (
    <div className="doctor-visit">
      <h2>Doctor Visit Preparation</h2>
      
      <div className="summary-actions">
        <button onClick={handleGenerateShareable} className="btn">
          Generate Shareable Summary
        </button>
      </div>
      
      {/* Summary period */}
      <p className="period">
        Health Summary: {summaryData.period.start} - {summaryData.period.end}
      </p>
      
      {/* Key Symptoms Section */}
      <div className="card">
        <h3>Key Symptoms Reported</h3>
        
        {summaryData.keySymptoms.length === 0 ? (
          <p>No symptoms reported during this period.</p>
        ) : (
          <div className="symptoms-list">
            {summaryData.keySymptoms.map((symptom, index) => (
              <div key={index} className="symptom-item">
                <h4>{symptom.name}</h4>
                <p>{symptom.occurrences} occurrences (avg. severity {symptom.avgSeverity}/10)</p>
              </div>
            ))}
          </div>
        )}
      </div>
      
      {/* Overall Patterns */}
      <div className="card">
        <h3>Overall Patterns</h3>
        
        <ul className="patterns-list">
          {summaryData.overallPatterns.map((pattern, index) => (
            <li key={index} className="pattern-item">{pattern}</li>
          ))}
        </ul>
      </div>
      
      {/* Questions for Doctor */}
      <div className="card">
        <h3>Questions for Doctor</h3>
        
        <ul className="questions-list">
          {questions.map((question, index) => (
            <li key={index} className="question-item">{question}</li>
          ))}
        </ul>
        
        <form onSubmit={handleAddQuestion} className="add-question-form">
          <div className="form-group">
            <label htmlFor="new-question">Add a question:</label>
            <input
              type="text"
              id="new-question"
              value={newQuestion}
              onChange={handleQuestionChange}
              className="form-control"
              placeholder="Enter a question for your doctor..."
            />
          </div>
          <button type="submit" className="btn">Add Question</button>
        </form>
      </div>
      
      {/* Shareable Text Modal */}
      {showShareable && (
        <div className="modal">
          <div className="modal-content">
            <div className="modal-header">
              <h3>Shareable Health Summary</h3>
              <button onClick={() => setShowShareable(false)} className="close-btn">&times;</button>
            </div>
            <div className="modal-body">
              <pre className="shareable-text">{shareableText}</pre>
            </div>
            <div className="modal-footer">
              <button onClick={handleCopyText} className="btn">Copy to Clipboard</button>
              <button onClick={() => setShowShareable(false)} className="btn btn-secondary">Close</button>
            </div>
          </div>
        </div>
      )}
      
      {/* Health Summary Tips */}
      <div className="card tips-card">
        <h3>Tips for Your Doctor Visit</h3>
        
        <ul className="tips-list">
          <li>Bring this summary to your appointment or share it in advance if possible.</li>
          <li>Focus on the patterns you've noticed, rather than just symptoms.</li>
          <li>Mention any lifestyle changes you've tried and their effects.</li>
          <li>Ask about the potential connections between symptoms and lifestyle factors shown in your data.</li>
          <li>Discuss any medication side effects or effectiveness if applicable.</li>
        </ul>
      </div>
    </div>
  );
}

export default DoctorVisit;
