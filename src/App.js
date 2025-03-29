import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Header from './views/Header';
import Dashboard from './views/Dashboard';
import JournalEntry from './views/JournalEntry';
import WeeklySummary from './views/WeeklySummary';
import PatternAnalysis from './views/PatternAnalysis';
import DoctorVisit from './views/DoctorVisit';

function App() {
  return (
    <div className="container">
      <Header />
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/journal" element={<JournalEntry />} />
        <Route path="/weekly" element={<WeeklySummary />} />
        <Route path="/patterns" element={<PatternAnalysis />} />
        <Route path="/doctor" element={<DoctorVisit />} />
      </Routes>
    </div>
  );
}

export default App;
