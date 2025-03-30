# HealthSync

A health tracking application that integrates with Auth0 for secure authentication and Apple HealthKit/Google Health Connect for health data access.

## Features

- **Secure Authentication**: Login with Google or Apple SSO through Auth0
- **Health Data Integration**: Access and store health data from Apple HealthKit and Google Health Connect
- **Daily Health Tracking**: Record mood, energy levels, symptoms, and notes
- **Health Consent Management**: Proper user consent flow for health data access
- **Data Persistence**: Store user profile and entries in a database
- **Session Management**: Maintain user sessions securely

## Setup Instructions

### Prerequisites

- Flutter SDK 3.4.3 or higher
- Xcode (for iOS development)
- Android Studio (for Android development)
- Auth0 Account with a Native Application set up
- Backend server for storing user data and entries

### Auth0 Configuration

1. Create a Native Application in the Auth0 Dashboard
2. Configure the following:
   - **Allowed Callback URLs**: `com.example.healthsync://YOUR_AUTH0_DOMAIN/ios/com.example.healthsync/callback`, `com.example.healthsync://YOUR_AUTH0_DOMAIN/android/com.example.healthsync/callback`
   - **Allowed Logout URLs**: `com.example.healthsync://YOUR_AUTH0_DOMAIN/ios/com.example.healthsync/callback`, `com.example.healthsync://YOUR_AUTH0_DOMAIN/android/com.example.healthsync/callback`
   - **Allowed Web Origins**: `http://localhost:3000` (for web testing)
   - **JWT Signature Algorithm**: RS256
3. Enable the Google and Apple social connections in the Auth0 Dashboard

### iOS Configuration

1. Open the iOS project in Xcode: `open ios/Runner.xcworkspace`
2. In the Xcode project navigator, select the Runner target
3. Go to the "Signing & Capabilities" tab
4. Add the following capabilities:
   - **Associated Domains**
   - **HealthKit**
   - **Sign in with Apple** (if using Apple login)
5. Update your Info.plist with the following entries:
   ```xml
   <key>NSHealthShareUsageDescription</key>
   <string>We need access to read your health data for providing personalized insights</string>
   <key>NSHealthUpdateUsageDescription</key>
   <string>We need access to update your health data for tracking purposes</string>
   ```

### Android Configuration

1. Update your `android/app/build.gradle` file to include the Auth0 manifest placeholders:
   ```gradle
   android {
       defaultConfig {
           // Other configurations
           manifestPlaceholders = [
               'auth0Domain': 'YOUR_AUTH0_DOMAIN',
               'auth0Scheme': '${applicationId}'
           ]
       }
   }
   ```
2. Ensure Health Connect is properly configured in the AndroidManifest.xml:
   ```xml
   <!-- Check whether Health Connect is installed or not -->
   <queries>
       <package android:name="com.google.android.apps.healthdata" />
       <intent>
           <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" />
       </intent>
   </queries>
   ```

### Backend Configuration

1. Set up a backend server with endpoints for:
   - User management (create, read, update)
   - Health consent tracking
   - Entry storage and retrieval
2. Update the API URL in the app:
   - Open `lib/src/services/user_service.dart`, `lib/src/services/entry_service.dart`
   - Update the `apiBaseUrl` constant with your backend URL

### Running the App

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

- **lib/src/models/**: Data models for users and entries
- **lib/src/services/**: Service classes for authentication, database, and health data
- **lib/src/utils/**: Utility classes including consent management
- **lib/src/pages/**: UI screens
- **lib/src/components/**: Reusable UI components

## Authentication Flow

1. User initiates login with Google or Apple
2. Auth0 handles the authentication process
3. Upon successful authentication, user data is stored in the database
4. If first login, a new user record is created
5. For returning users, existing user record is updated with latest auth provider data
6. User session is maintained with secure token storage

## Health Data Access Flow

1. After authentication, app checks if health consent is needed
2. If needed, app shows a consent prompt
3. If user agrees, app requests actual permissions from HealthKit/Health Connect
4. Health consent status is stored in the user profile
5. Health data is accessed and stored with entries when available

## Backend API Requirements

The backend should support the following endpoints:

- `POST /users`: Create a new user
- `GET /users/email/:email`: Get user by email
- `GET /users/auth0/:id`: Get user by Auth0 ID
- `PUT /users/:id`: Update user
- `PATCH /users/:id/health-consent`: Update user health consent
- `POST /entries`: Create a new entry
- `GET /entries/user/:id`: Get all entries for a user
- `GET /entries/user/:id/range`: Get entries for a date range
