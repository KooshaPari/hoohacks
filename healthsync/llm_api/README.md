# HealthSync LLM API

This API provides health data analysis, summaries, and insights using Google's Gemini API.

## Setup

1. Install dependencies in a virtual environment:

```bash
# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

2. Create a `.env` file with the following variables:

```
GEMINI_API_KEY=your_gemini_api_key_here
MONGO_URI=your_mongodb_connection_string
DB_NAME=health_data_db
LLM_MODEL=gemini-2.5-pro-exp-03-25
```

3. Run the API:

```bash
uvicorn main:app --reload --port 5002
```

## API Endpoints

- `GET /` - Health check
- `GET /get_response?prompt={prompt}` - Get a raw response from the LLM
- `POST /analyze_health_data` - Analyze health data entries
- `POST /generate_summary` - Generate a summary from health data
- `POST /generate_reflection` - Generate a reflection from summaries
- `POST /complete_health_template` - Fill in a health data template

## Integration with Flutter

In your Flutter app, you can call these endpoints using the `http` package:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getHealthAnalysis(List<dynamic> entries, String userId) async {
  final response = await http.post(
    Uri.parse('http://localhost:5002/analyze_health_data'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'entries': entries,
      'timeframe': 'week',
      'user_id': userId
    }),
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['analysis'];
  } else {
    throw Exception('Failed to get health analysis');
  }
}
```