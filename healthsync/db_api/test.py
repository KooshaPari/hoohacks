import requests
import json

# Base URL for the API
BASE_URL = "http://localhost:5001"

def test_health_check():
    """Test the health check endpoint"""
    response = requests.get(f"{BASE_URL}/health")
    print(f"Health check status code: {response.status_code}")
    print(f"Health check response: {response.json()}")

def test_create_user():
    """Test creating a new user"""
    user_data = {
        "email": "test@example.com",
        "firebaseUid": "test_firebase_uid_12345",
        "name": "Test User",
        "hasHealthkitConsent": False,
        "hasGoogleFitConsent": False,
        "authProvider": "firebase"
    }
    
    response = requests.post(
        f"{BASE_URL}/users",
        headers={"Content-Type": "application/json"},
        data=json.dumps(user_data)
    )
    
    print(f"Create user status code: {response.status_code}")
    print(f"Create user response: {response.json()}")
    
def test_get_user_by_email():
    """Test getting a user by email"""
    email = "test@example.com"
    response = requests.get(f"{BASE_URL}/users/email/{email}")
    
    print(f"Get user by email status code: {response.status_code}")
    print(f"Get user by email response: {response.json()}")
    
def test_get_user_by_firebase_uid():
    """Test getting a user by Firebase UID"""
    uid = "test_firebase_uid_12345"
    response = requests.get(f"{BASE_URL}/users/firebase/{uid}")
    
    print(f"Get user by Firebase UID status code: {response.status_code}")
    print(f"Get user by Firebase UID response: {response.json()}")

def main():
    """Run all tests"""
    print("\n--- Testing API ---")
    
    print("\n1. Testing health check...")
    test_health_check()
    
    print("\n2. Testing user creation...")
    test_create_user()
    
    print("\n3. Testing get user by email...")
    test_get_user_by_email()
    
    print("\n4. Testing get user by Firebase UID...")
    test_get_user_by_firebase_uid()
    
    print("\n--- Tests completed ---")

if __name__ == "__main__":
    main()