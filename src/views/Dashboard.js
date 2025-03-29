import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import DashboardPresenter from '../presenters/DashboardPresenter';

function Dashboard() {
  const [dashboardData, setDashboardData] = useState(null);
  const [loading, setLoading] = useState(true);
  const presenter = new DashboardPresenter();
  
  useEffect(() => {
    // Get dashboard data from presenter
    const data = presenter.getDashboardData();
    setDashboardData(data);
    setLoading(false);
  }, []);
  
  if (loading) {
    return <div className="loading">Loading dashboard data...</div>;
  }
  
  return (
    <div className="dashboard">
      <h2>Your Health Dashboard</h2>
      
      {/* Weekly Narrative */}
      <div className="card narrative-card">
        <h3>Weekly Insights</h3>
        <p>{dashboardData.weeklyNarrative}</p>
        <Link to="/weekly" className="btn">View Full Weekly Summary</Link>
      </div>
      
      {/* Quick Stats */}
      <div className="stats-container">
        <div className="card stat-card">
          <h3>Mood</h3>
          <p className="stat-value">{dashboardData.summary.mood.average}/5</p>
          <p className="stat-label">Weekly Average</p>
        </div>
        
        <div className="card stat-card">
          <h3>Energy</h3>
          <p className="stat-value">{dashboardData.summary.energy.average}/5</p>
          <p className="stat-label">Weekly Average</p>
        </div>
        
        <div className="card stat-card">
          <h3>Sleep</h3>
          <p className="stat-value">{dashboardData.summary.sleep.average} hrs</p>
          <p className="stat-label">Weekly Average</p>
        </div>
        
        <div className="card stat-card">
          <h3>Activity</h3>
          <p className="stat-value">{dashboardData.summary.activity.averageSteps}</p>
          <p className="stat-label">Avg. Daily Steps</p>
        </div>
      </div>
      
      {/* Recent Journal Entries */}
      <div className="card">
        <h3>Recent Journal Entries</h3>
        
        {dashboardData.recentEntries.length === 0 ? (
          <p>No recent entries. <Link to="/journal">Start journaling</Link> to track your health!</p>
        ) : (
          <div className="recent-entries">
            {dashboardData.recentEntries.map(entry => (
              <div key={entry.id} className="entry-summary">
                <div className="entry-header">
                  <h4>{new Date(entry.timestamp).toLocaleDateString()}</h4>
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
            
            <Link to="/journal" className="btn">Add New Entry</Link>
          </div>
        )}
      </div>
      
      {/* Quick Links */}
      <div className="quick-links">
        <Link to="/patterns" className="card link-card">
          <h3>Explore Symptom Patterns</h3>
          <p>Analyze correlations between your symptoms and lifestyle factors.</p>
        </Link>
        
        <Link to="/doctor" className="card link-card">
          <h3>Prepare for Doctor Visit</h3>
          <p>Generate a comprehensive health summary to share with your healthcare provider.</p>
        </Link>
      </div>
    </div>
  );
}

export default Dashboard;
