
import os
from dotenv import load_dotenv
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

load_dotenv()  # Load environment variables from .env file

# Retrieve password from environment variable
mongo_password = os.getenv("MONGO_PASSWORD")

if not mongo_password:
    raise ValueError("MONGO_PASSWORD environment variable not set.")

# Construct the URI using an f-string
uri = f"mongodb+srv://test_user:{mongo_password}@health-data.i0fc5kr.mongodb.net/?retryWrites=true&w=majority&appName=health-data"

# Create a new client and connect to the server
client = MongoClient(uri, server_api=ServerApi('1'))

# Send a ping to confirm a successful connection
try:
    client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print(e)