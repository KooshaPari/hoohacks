import os
from flask import Flask, request, jsonify
from flask_cors import CORS # Import CORS
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
from dotenv import load_dotenv
from datetime import datetime
from bson import ObjectId
import json

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
    users_collection = db['users'] # Use or create a collection for users
except Exception as e:
    print(f"Error connecting to MongoDB: {e}")
    client = None
    entries_collection = None
    users_collection = None
# --- End MongoDB Setup ---

# --- JSON Encoder for MongoDB ObjectId ---
class MongoJSONEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, ObjectId):
            return str(obj)
        if isinstance(obj, datetime):
            return obj.isoformat()
        return super(MongoJSONEncoder, self).default(obj)

app.json_encoder = MongoJSONEncoder
# --- End JSON Encoder ---

# --- USER ENDPOINTS ---
@app.route('/users', methods=['POST'])
def create_user():
    """Create a new user"""
    if users_collection is None:
        return jsonify({"error": "Database connection not established"}), 500
    
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "No data provided"}), 400
            
        # Check if required fields are present
        required_fields = ['email', 'firebaseUid']
        if not all(field in data for field in required_fields):
            return jsonify({"error": f"Missing required fields. Required: {required_fields}"}), 400
            
        # Check if user already exists
        existing_user = users_collection.find_one({"email": data['email']})
        if existing_user:
            return jsonify({"error": "User with this email already exists", 
                           "user": json.loads(json.dumps(existing_user, cls=MongoJSONEncoder))}), 409
        
        # Add timestamps
        data['createdAt'] = datetime.utcnow()
        data['updatedAt'] = datetime.utcnow()
        
        # Insert the user
        result = users_collection.insert_one(data)
        
        # Get the created user
        created_user = users_collection.find_one({"_id": result.inserted_id})
        
        return jsonify({
            "message": "User created successfully",
            "user": json.loads(json.dumps(created_user, cls=MongoJSONEncoder))
        }), 201
    
    except Exception as e:
        print(f"Error creating user: {e}")
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500

@app.route('/users/email/<email>', methods=['GET'])
def get_user_by_email(email):
    """Get a user by email"""
    if users_collection is None:
        return jsonify({"error": "Database connection not established"}), 500
    
    try:
        user = users_collection.find_one({"email": email})
        
        if not user:
            return jsonify({"error": "User not found"}), 404
            
        return jsonify(json.loads(json.dumps(user, cls=MongoJSONEncoder))), 200
    
    except Exception as e:
        print(f"Error getting user by email: {e}")
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500

@app.route('/users/firebase/<uid>', methods=['GET'])
def get_user_by_firebase_uid(uid):
    """Get a user by Firebase UID"""
    if users_collection is None:
        return jsonify({"error": "Database connection not established"}), 500
    
    try:
        user = users_collection.find_one({"firebaseUid": uid})
        
        if not user:
            return jsonify({"error": "User not found"}), 404
            
        return jsonify(json.loads(json.dumps(user, cls=MongoJSONEncoder))), 200
    
    except Exception as e:
        print(f"Error getting user by Firebase UID: {e}")
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500

@app.route('/users/<id>', methods=['PUT'])
def update_user(id):
    """Update a user"""
    if users_collection is None:
        return jsonify({"error": "Database connection not established"}), 500
    
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "No data provided"}), 400
        
        # Add updated timestamp
        data['updatedAt'] = datetime.utcnow()
        
        # Update the user
        result = users_collection.update_one(
            {"_id": ObjectId(id)},
            {"$set": data}
        )
        
        if result.matched_count == 0:
            return jsonify({"error": "User not found"}), 404
            
        # Get the updated user
        updated_user = users_collection.find_one({"_id": ObjectId(id)})
        
        return jsonify({
            "message": "User updated successfully",
            "user": json.loads(json.dumps(updated_user, cls=MongoJSONEncoder))
        }), 200
    
    except Exception as e:
        print(f"Error updating user: {e}")
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500

@app.route('/users/<id>/health-consent', methods=['PATCH'])
def update_health_consent(id):
    """Update a user's health consent settings"""
    if users_collection is None:
        return jsonify({"error": "Database connection not established"}), 500
    
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "No data provided"}), 400
            
        update_fields = {}
        
        # Only allow updating specific fields
        if 'hasHealthkitConsent' in data:
            update_fields['hasHealthkitConsent'] = data['hasHealthkitConsent']
            
        if 'hasGoogleFitConsent' in data:
            update_fields['hasGoogleFitConsent'] = data['hasGoogleFitConsent']
            
        if not update_fields:
            return jsonify({"error": "No valid fields to update"}), 400
            
        # Add updated timestamp
        update_fields['updatedAt'] = datetime.utcnow()
        
        # Update the user
        result = users_collection.update_one(
            {"_id": ObjectId(id)},
            {"$set": update_fields}
        )
        
        if result.matched_count == 0:
            return jsonify({"error": "User not found"}), 404
            
        # Get the updated user
        updated_user = users_collection.find_one({"_id": ObjectId(id)})
        
        return jsonify({
            "message": "Health consent updated successfully",
            "user": json.loads(json.dumps(updated_user, cls=MongoJSONEncoder))
        }), 200
    
    except Exception as e:
        print(f"Error updating health consent: {e}")
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500
# --- END USER ENDPOINTS ---

# --- HEALTH ENTRY ENDPOINTS ---
@app.route('/entries', methods=['POST'])
def add_entry():
    # Correct way to check if the collection object was initialized
    if entries_collection is None:
        return jsonify({"error": "Database connection not established"}), 500

    try:
        data = request.get_json()

        if not data:
            return jsonify({"error": "No data provided"}), 400

        # Basic validation (can be expanded)
        required_fields = ['mood', 'energyLevel', 'symptoms', 'notes', 'tags', 'date', 'time', 'userId']
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

        # Validate symptoms format (should be a list of {'symptom': str, 'severity': int})
        symptoms_data = data.get('symptoms')
        if not isinstance(symptoms_data, list):
            return jsonify({"error": "Invalid format for 'symptoms'. Expected a list."}), 400

        for item in symptoms_data:
            if not isinstance(item, dict):
                return jsonify({"error": "Invalid item in 'symptoms' list. Expected a dictionary."}), 400
            if not all(k in item for k in ('symptom', 'severity')):
                return jsonify({"error": "Missing 'symptom' or 'severity' in symptoms item."}), 400
            if not isinstance(item.get('symptom'), str) or not item.get('symptom').strip():
                return jsonify({"error": "Invalid 'symptom' value. Expected a non-empty string."}), 400
            severity = item.get('severity')
            if not isinstance(severity, int) or not (1 <= severity <= 10):
                return jsonify({"error": f"Invalid 'severity' value ({severity}) for symptom '{item.get('symptom')}'. Expected an integer between 1 and 10."}), 400

        # Prepare data for MongoDB insertion
        entry_to_insert = {
            "userId": data.get('userId'),  # Associate entry with user
            "mood": data.get('mood'),
            "energyLevel": data.get('energyLevel'),
            "symptoms": symptoms_data, # Store the validated list of symptoms
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

@app.route('/entries/<user_id>', methods=['GET'])
def get_entries(user_id):
    """Get entries for a specific user"""
    if entries_collection is None:
        return jsonify({"error": "Database connection not established"}), 500
        
    try:
        # Get query parameters for filtering
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')
        
        # Initialize the query filter
        query = {"userId": user_id}
        
        # Add date range filtering if provided
        if start_date or end_date:
            timestamp_filter = {}
            
            if start_date:
                try:
                    start_datetime = datetime.strptime(start_date, "%Y-%m-%d")
                    timestamp_filter["$gte"] = start_datetime
                except ValueError:
                    return jsonify({"error": f"Invalid start_date format: {start_date}. Expected YYYY-MM-DD"}), 400
            
            if end_date:
                try:
                    # Make end_date inclusive by setting to the end of the day
                    end_datetime = datetime.strptime(end_date, "%Y-%m-%d").replace(hour=23, minute=59, second=59)
                    timestamp_filter["$lte"] = end_datetime
                except ValueError:
                    return jsonify({"error": f"Invalid end_date format: {end_date}. Expected YYYY-MM-DD"}), 400
            
            if timestamp_filter:
                query["timestamp"] = timestamp_filter
        
        # Get entries from MongoDB
        entries = list(entries_collection.find(query).sort("timestamp", -1))
        
        # Convert ObjectId and datetime to string for JSON serialization
        serialized_entries = json.loads(json.dumps(entries, cls=MongoJSONEncoder))
        
        return jsonify(serialized_entries), 200
        
    except Exception as e:
        print(f"Error getting entries: {e}")
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500
# --- END HEALTH ENTRY ENDPOINTS ---

@app.route('/health', methods=['GET'])
def health_check():
    """Simple health check endpoint"""
    if client is None:
        return jsonify({"status": "error", "message": "Database connection not established"}), 500
    
    try:
        # Check MongoDB connection
        client.admin.command('ping')
        return jsonify({"status": "healthy", "message": "API is running and connected to MongoDB"}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": f"Database connection issue: {str(e)}"}), 500

if __name__ == '__main__':
    # Run on 0.0.0.0 to be accessible from the network (e.g., mobile emulator)
    # Use a specific port, e.g., 5001, to avoid conflicts
    app.run(host='0.0.0.0', port=5001, debug=True) # Use debug=False in production