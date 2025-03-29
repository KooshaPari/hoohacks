import React, { useState, useEffect } from 'react';
import WeeklySummaryPresenter from '../presenters/WeeklySummaryPresenter';

function WeeklySummary() {
  const [summaryData, setSummaryData] = useState(null);
  const [loading, setLoading] = useState(true);
  const presenter = new WeeklySummaryPresenter();
  
  useEffect(() => {
    // Get weekly summary data from presenter
    const data = presenter.getWeeklySummaryData();
    setSummaryData(data);
    setLoading(false);
  }, []);
  
  if (loading) {
    return <div className="loading">Loading weekly summary data...</div>;
  }
  
  return (
    <div className="weekly-summary">
      <h2>Weekly Health Summary</h2>
      <p className="period">
        {new Date(summaryData.summary.period.start).toLocaleDateString()} - {new Date(summaryData.summary.period.end).toLocaleDateString()}
      </p>
      
      {/* AI-Generated Narrative */}
      <div className="card narrative-card">
        <h3>Your Week in Review</h3>
        <p className="narrative-text">{summaryData.narrative}</p>
      </div>
      
      {/* Health Metrics Overview */}
      <div className="card">
        <h3>Health Metrics Overview</h3>
        
        <div className="metrics-grid">
          <div className="metric-card">
            <h4>Mood</h4>
            <p className="metric-value">{summaryData.summary.mood.average}/5</p>
            <p className="metric-label">Weekly Average</p>
          </div>
          
          <div className="metric-card">
            <h4>Energy</h4>
            <p className="metric-value">{summaryData.summary.energy.average}/5</p>
            <p className="metric-label">Weekly Average</p>
          </div>
          
          <div className="metric-card">
            <h4>Sleep</h4>
            <p className="metric-value">{summaryData.summary.sleep.average} hrs</p>
            <p className="metric-label">Weekly Average</p>
          </div>
          
          <div className="metric-card">
            <h4>Activity</h4>
            <p className="metric-value">{summaryData.summary.activity.averageSteps}</p>
            <p className="metric-label">Avg. Daily Steps</p>
          </div>
          
          <div className="metric-card">
            <h4>Heart Rate</h4>
            <p className="metric-value">{summaryData.summary.heartRate.averageResting} bpm</p>
            <p className="metric-label">Avg. Resting HR</p>
          </div>
          
          <div className="metric-card">
            <h4>Journal Entries</h4>
            <p className="metric-value">{summaryData.summary.entries}</p>
            <p className="metric-label">Days Logged</p>
          </div>
        </div>
      </div>
      
      {/* Symptoms Summary */}
      <div className="card">
        <h3>Symptoms Summary</h3>
        
        {Object.keys(summaryData.summary.symptoms).length === 0 ? (
          <p>No symptoms reported this week.</p>
        ) : (
          <div className="symptoms-list">
            {Object.entries(summaryData.summary.symptoms).map(([name, data]) => (
              <div key={name} className="symptom-item">
                <h4>{name}</h4>
                <p>Occurred on {data.count} day{data.count !== 1 ? 's' : ''}</p>
                <p>Average severity: {data.avgSeverity}/10</p>
              </div>
            ))}
          </div>
        )}
      </div>
      
      {/* Trend Charts (placeholder - would use chart.js or similar in actual implementation) */}
      <div className="card">
        <h3>Weekly Trends</h3>
        <div className="chart-grid">
          <div className="chart-container">
            <h4>Sleep Duration</h4>
            <div className="chart-placeholder">
              <p>Chart visualization would appear here</p>
              <p className="chart-data">Data: {summaryData.chartData.sleep.join(', ')}</p>
            </div>
          </div>
          
          <div className="chart-container">
            <h4>Daily Steps</h4>
            <div className="chart-placeholder">
              <p>Chart visualization would appear here</p>
              <p className="chart-data">Data: {summaryData.chartData.steps.join(', ')}</p>
            </div>
          </div>
          
          <div className="chart-container">
            <h4>Mood & Energy</h4>
            <div className="chart-placeholder">
              <p>Chart visualization would appear here</p>
              <p className="chart-data">Mood: {summaryData.chartData.mood.join(', ')}</p>
              <p className="chart-data">Energy: {summaryData.chartData.energy.join(', ')}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default WeeklySummary;
