import os
from flask import Flask, request, jsonify
from flask_cors import CORS # Import CORS
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
from dotenv import load_dotenv
from datetime import datetime

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)
CORS(app) # Enable CORS for all routes and origins by default

# --- MongoDB Setup ---
mongo_password = os.getenv("MONGO_PASSWORD")
if not mongo_password:
    raise ValueError("MONGO_PASSWORD environment variable not set.")

uri = f"mongodb+srv://test_user:{mongo_password}@health-data.i0fc5kr.mongodb.net/?retryWrites=true&w=majority&appName=health-data"

# Create a new client and connect to the server
try:
    client = MongoClient(uri, server_api=ServerApi('1'))
    client.admin.command('ping')
    print("Successfully connected to MongoDB!")
    db = client['health_data_db'] # Use or create a database named 'health_data_db'
    entries_collection = db['entries'] # Use or create a collection named 'entries'
except Exception as e:
    print(f"Error connecting to MongoDB: {e}")
    client = None
    entries_collection = None
# --- End MongoDB Setup ---

@app.route('/add_entry', methods=['POST'])
def add_entry():
    # Correct way to check if the collection object was initialized
    if entries_collection is None:
        return jsonify({"error": "Database connection not established"}), 500

    try:
        data = request.get_json()

        if not data:
            return jsonify({"error": "No data provided"}), 400

        # Basic validation (can be expanded)
        required_fields = ['mood', 'energyLevel', 'symptoms', 'notes', 'tags', 'date', 'time']
        if not all(field in data for field in required_fields):
            return jsonify({"error": "Missing required fields"}), 400

        # Combine date and time into a single datetime object for timestamp
        # Assumes date is YYYY-MM-DD and time is HH:MM (adjust if Flutter sends different format)
        try:
            date_str = data.get('date')
            time_str = data.get('time')
            # Attempt to parse common ISO-like formats or specific formats
            if 'T' in date_str: # Handle ISO 8601 format directly if sent
                 timestamp_str = date_str.split('T')[0] + ' ' + time_str
            else:
                 timestamp_str = f"{date_str} {time_str}"

            # Define possible formats Flutter might send
            possible_formats = [
                "%Y-%m-%d %H:%M",        # Assumed format
                "%Y-%m-%dT%H:%M:%S.%f", # ISO format with microseconds
                "%Y-%m-%d %H:%M:%S",     # ISO format without microseconds
            ]
            timestamp = None
            for fmt in possible_formats:
                try:
                    timestamp = datetime.strptime(timestamp_str, fmt)
                    break # Stop if parsing is successful
                except ValueError:
                    continue # Try next format

            if timestamp is None:
                 raise ValueError(f"Could not parse timestamp string: {timestamp_str}")

        except (ValueError, TypeError) as e:
             print(f"Error parsing date/time: {e}, received date='{data.get('date')}', time='{data.get('time')}'")
             return jsonify({"error": f"Invalid date or time format. Received date='{data.get('date')}', time='{data.get('time')}'"}), 400


        # Prepare data for MongoDB insertion
        entry_to_insert = {
            "mood": data.get('mood'),
            "energyLevel": data.get('energyLevel'),
            "symptoms": data.get('symptoms'), # Store as string for now
            "notes": data.get('notes'),
            "tags": [tag.strip() for tag in data.get('tags', '').split(',') if tag.strip()], # Split tags into a list
            "timestamp": timestamp, # Store combined datetime object
            "createdAt": datetime.utcnow() # Add a server-side creation timestamp
        }

        # Insert data into MongoDB
        result = entries_collection.insert_one(entry_to_insert)

        return jsonify({
            "message": "Entry added successfully",
            "inserted_id": str(result.inserted_id)
        }), 201

    except Exception as e:
        print(f"Error adding entry: {e}")
        return jsonify({"error": "An internal server error occurred"}), 500

if __name__ == '__main__':
    # Run on 0.0.0.0 to be accessible from the network (e.g., mobile emulator)
    # Use a specific port, e.g., 5001, to avoid conflicts
    app.run(host='0.0.0.0', port=5001, debug=True) # Use debug=False in production