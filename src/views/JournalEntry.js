import React, { useState, useEffect } from 'react';
import JournalPresenter from '../presenters/JournalPresenter';

function JournalEntry() {
  const [formData, setFormData] = useState({
    mood: 3,
    energy: 3,
    symptoms: '',
    notes: '',
    tags: ''
  });
  
  const [recentEntries, setRecentEntries] = useState([]);
  const [submitMessage, setSubmitMessage] = useState('');
  const presenter = new JournalPresenter();
  
  useEffect(() => {
    // Get recent entries from presenter
    const entries = presenter.getRecentEntries();
    setRecentEntries(entries);
  }, []);
  
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };
  
  const handleSubmit = (e) => {
    e.preventDefault();
    
    // Submit data via presenter
    const savedEntry = presenter.saveJournalEntry(formData);
    
    // Update UI
    setRecentEntries([savedEntry, ...recentEntries]);
    setSubmitMessage('Journal entry saved successfully!');
    
    // Reset form
    setFormData({
      mood: 3,
      energy: 3,
      symptoms: '',
      notes: '',
      tags: ''
    });
    
    // Clear message after delay
    setTimeout(() => {
      setSubmitMessage('');
    }, 3000);
  };
  
  return (
    <div className="journal-entry">
      <h2>Daily Health Journal</h2>
      
      {/* Journal Entry Form */}
      <div className="card">
        <h3>New Entry</h3>
        <p className="subtitle">How are you feeling today?</p>
        
        {submitMessage && (
          <div className="submit-message success">
            {submitMessage}
          </div>
        )}
        
        <form onSubmit={handleSubmit}>
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="mood">Mood (1-5):</label>
              <input
                type="range"
                id="mood"
                name="mood"
                min="1"
                max="5"
                value={formData.mood}
                onChange={handleInputChange}
              />
              <div className="range-labels">
                <span>1 (Poor)</span>
                <span>5 (Excellent)</span>
              </div>
            </div>
            
            <div className="form-group">
              <label htmlFor="energy">Energy Level (1-5):</label>
              <input
                type="range"
                id="energy"
                name="energy"
                min="1"
                max="5"
                value={formData.energy}
                onChange={handleInputChange}
              />
              <div className="range-labels">
                <span>1 (Low)</span>
                <span>5 (High)</span>
              </div>
            </div>
          </div>
          
          <div className="form-group">
            <label htmlFor="symptoms">Symptoms (comma separated, with severity 1-10):</label>
            <input
              type="text"
              id="symptoms"
              name="symptoms"
              className="form-control"
              placeholder="Headache:7, Fatigue:5"
              value={formData.symptoms}
              onChange={handleInputChange}
            />
            <small>Format: Symptom:Severity, e.g., "Headache:7, Fatigue:5"</small>
          </div>
          
          <div className="form-group">
            <label htmlFor="notes">Notes:</label>
            <textarea
              id="notes"
              name="notes"
              className="form-control"
              rows="3"
              placeholder="How was your day? Any notable events or feelings?"
              value={formData.notes}
              onChange={handleInputChange}
            ></textarea>
          </div>
          
          <div className="form-group">
            <label htmlFor="tags">Tags:</label>
            <input
              type="text"
              id="tags"
              name="tags"
              className="form-control"
              placeholder="stress poor_sleep skipped_meals"
              value={formData.tags}
              onChange={handleInputChange}
            />
            <small>Space or comma separated, e.g., "stress poor_sleep"</small>
          </div>
          
          <button type="submit" className="btn">Save Entry</button>
        </form>
      </div>
      
      {/* Recent Entries */}
      <div className="card">
        <h3>Recent Entries</h3>
        
        {recentEntries.length === 0 ? (
          <p>No entries yet. Start tracking your daily health!</p>
        ) : (
          <div className="entries-list">
            {recentEntries.map(entry => (
              <div key={entry.id} className="entry-item">
                <div className="entry-header">
                  <h4>{new Date(entry.timestamp).toLocaleDateString()} {new Date(entry.timestamp).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}</h4>
                  <div className="entry-metrics">
                    <span className="entry-mood">Mood: {entry.mood}/5</span>
                    <span className="entry-energy">Energy: {entry.energy}/5</span>
                  </div>
                </div>
                
                {entry.symptoms.length > 0 && (
                  <div className="entry-symptoms">
                    <strong>Symptoms:</strong> {entry.symptoms.map(s => `${s.name} (${s.severity})`).join(', ')}
                  </div>
                )}
                
                <p className="entry-notes">{entry.notes}</p>
                
                {entry.tags.length > 0 && (
                  <div className="entry-tags">
                    {entry.tags.map(tag => (
                      <span key={tag} className="tag">#{tag}</span>
                    ))}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default JournalEntry;
