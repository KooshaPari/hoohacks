# HealthSync Backend API

A unified backend API for HealthSync web and mobile applications, following MCP (Model-Controller-Presenter) architecture.

## Features

- RESTful API endpoints for user authentication, health journals, health data, and health analyses
- Integration with Gemini API for health insights and pattern detection
- MongoDB database for data persistence
- JWT authentication for API security

## Architecture

The backend follows an MCP (Model-Controller-Presenter) architecture:

- **Models**: Define data structures and database schemas
- **Controllers**: Handle business logic and data operations
- **Presenters**: Format data for client consumption and AI processing

## Endpoints

### Authentication
- `POST /api/users/signup`: Create a new user account
- `POST /api/users/login`: Log in a user
- `PATCH /api/users/updateProfile`: Update user profile
- `PATCH /api/users/updatePassword`: Update user password

### Journal Entries
- `GET /api/journal`: Get all journal entries for the logged-in user
- `POST /api/journal`: Create a new journal entry
- `GET /api/journal/:id`: Get a specific journal entry
- `PATCH /api/journal/:id`: Update a journal entry
- `DELETE /api/journal/:id`: Delete a journal entry
- `GET /api/journal/stats/daily`: Get daily journal statistics

### Health Data
- `GET /api/health-data`: Get all health data for the logged-in user
- `POST /api/health-data`: Create new health data
- `GET /api/health-data/:id`: Get specific health data
- `PATCH /api/health-data/:id`: Update health data
- `DELETE /api/health-data/:id`: Delete health data
- `GET /api/health-data/stats/sleep`: Get sleep statistics
- `GET /api/health-data/stats/activity`: Get activity statistics
- `GET /api/health-data/stats/heartRate`: Get heart rate statistics

### Analysis
- `GET /api/analysis/weekly-summary`: Get weekly health summary with AI-generated narrative
- `GET /api/analysis/pattern-analysis/:symptom`: Get pattern analysis for a specific symptom
- `GET /api/analysis/doctor-visit-summary`: Get doctor visit summary with key points and questions

## Getting Started

### Prerequisites

- Node.js (v14+)
- MongoDB

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```
   npm install
   ```
4. Set up environment variables:
   - Copy `.env.example` to `.env`
   - Configure environment variables as needed
5. Start the server:
   ```
   npm start
   ```
   
### Development

Run in development mode with automatic restarts:
```
npm run dev
```

### Testing

Run tests:
```
npm test
```

## API Documentation

API documentation is generated with Swagger and available at `/api-docs` when the server is running.

## Future Enhancements

- Implement real Gemini API integration
- Add caching for performance optimization
- Implement WebSocket for real-time updates
- Add support for more health data types
- Enhance security with rate limiting and additional authentication options
