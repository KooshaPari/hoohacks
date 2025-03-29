# HealthSync: Personal Health Narrative Generator

HealthSync is an iOS application that transforms scattered health data into meaningful personal health narratives by integrating Apple Health data with user-logged symptoms and experiences, using Gemini AI to identify patterns and generate insights.

## Features

- **Daily Health Journal**: Track your mood, energy levels, symptoms, and notes.
- **Apple Health Integration**: Automatically sync with sleep, activity, heart rate, and other health metrics.
- **Weekly Health Summary**: AI-generated summaries of your health data, highlighting patterns and trends.
- **Pattern Analysis**: Identify correlations between symptoms and lifestyle factors.
- **Doctor Visit Prep**: Generate concise summaries for healthcare appointments.

## Technical Implementation

- **Architecture**: Model-Controller-Presenter (MCP)
- **Framework**: SwiftUI with SwiftData
- **Health Data**: Apple HealthKit
- **AI Integration**: Gemini API (simulated in MVP)

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Apple Developer Account (for HealthKit testing)

## Getting Started

1. Clone this repository
2. Open `Hoohacks.xcodeproj` in Xcode
3. Build and run the project

## Screens

1. **Journal Entry**: Daily logging of symptoms, mood, and health notes
2. **Weekly Summary**: AI-generated health narratives and patterns
3. **Pattern Analysis**: Detailed analysis of specific symptoms
4. **Doctor Visit Prep**: Prepare summaries for healthcare appointments

## Data Models

- JournalEntry: Daily user entries
- Symptom: Health symptoms with severity
- WeeklySummary: AI-generated weekly health narratives
- Pattern: Identified correlations between symptoms and health factors
- DoctorVisitSummary: Summaries for healthcare provider visits

## Services

- HealthKitService: Interface with Apple HealthKit
- AIService: Integration with AI for health analysis

## Future Enhancements

- Real Gemini API integration
- Medication tracking
- Environmental factor correlation (weather, air quality)
- More sophisticated data visualization
- Sharing with healthcare providers
