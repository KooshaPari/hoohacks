# HealthSync - Personal Health Narrative Generator

An app that transforms scattered health data into meaningful personal health narratives by integrating health tracking data with user-logged symptoms and experiences, then using AI to identify patterns and generate insights.

## Project Overview

HealthSync helps users understand connections between their daily life (activity, sleep, diet snippets, stress) and how they feel (symptoms, mood, energy), facilitating better self-awareness and more informed conversations with healthcare providers.

## Features

- **Daily Health Journal**: Log symptoms, mood, energy levels, and notes
- **Weekly Health Narrative**: AI-generated summary highlighting trends and correlations
- **Pattern Analysis**: Detailed analysis of potential triggers for specific symptoms
- **Doctor Visit Preparation**: Concise summaries to share with healthcare providers

## Tech Stack

- **Frontend**: React/JavaScript
- **Architecture**: Model-Controller-Presenter (MCP)
- **AI Integration**: Gemini API (simulated for MVP)

## Running the Project

### Prerequisites

- Node.js (v14 or higher)
- npm or yarn

### Installation

1. Navigate to the project directory:
   ```
   cd /Users/kooshapari/temp-PRODVERCEL/hoohacks/tester
   ```

2. Install dependencies:
   ```
   npm install
   ```
   or
   ```
   yarn install
   ```

### Development

Run the development server:
```
npm start
```
or
```
yarn start
```

The app will be available at [http://localhost:3000](http://localhost:3000)

### Building for Production

Build the project:
```
npm run build
```
or
```
yarn build
```

### Testing

```
npm test
```
or
```
yarn test
```

## Project Structure

```
/src
  /models       - Data structures and business logic
  /controllers  - Handles data flow between models and presenters
  /presenters   - Prepares data for views
  /views        - React components that display the UI
  /utils        - Utility functions
  /api          - API integrations (simulated for MVP)
```

## MCP Architecture

This project follows the Model-Controller-Presenter (MCP) pattern:

- **Models**: Core data structures and business logic
- **Controllers**: Manage data flow and application state
- **Presenters**: Transform model data for view consumption
- **Views**: Display the information and handle user interaction

## Future Enhancements

- Integration with real health APIs (Apple HealthKit, Google Fit)
- Medication tracking and adherence patterns
- Environmental factor correlation (weather, air quality)
- Deeper machine learning for more personalized insights
