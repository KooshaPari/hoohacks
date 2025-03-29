import React from 'react';
import { Link } from 'react-router-dom';

function Header() {
  return (
    <header className="header">
      <div className="logo">
        <h1>HealthSync</h1>
        <p>Personal Health Narrative Generator</p>
      </div>
      <nav className="nav">
        <Link to="/" className="nav-link">Dashboard</Link>
        <Link to="/journal" className="nav-link">Journal</Link>
        <Link to="/weekly" className="nav-link">Weekly Summary</Link>
        <Link to="/patterns" className="nav-link">Pattern Analysis</Link>
        <Link to="/doctor" className="nav-link">Doctor Visit</Link>
      </nav>
    </header>
  );
}

export default Header;
