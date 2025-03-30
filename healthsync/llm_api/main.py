import os
from dotenv import load_dotenv
import json
from google import genai
from fastapi import FastAPI, HTTPException, Body
from fastapi.middleware.cors import CORSMiddleware
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
from typing import List, Dict, Any, Optional
from pydantic import BaseModel

from utility import clean_extra_symbols

load_dotenv()
app = FastAPI()

# Configure CORS for Flutter web app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For development; restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Default LLM model - can be changed via environment variable
llm = os.getenv("LLM_MODEL", "gemini-2.5-pro-exp-03-25")

# Get API key from environment
api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    print("Warning: GEMINI_API_KEY environment variable is not set. LLM functions will not work.")


def get_db():
    """Get MongoDB database connection"""
    try:
        mongo_uri = os.getenv("MONGO_URI")
        if not mongo_uri:
            print("Warning: MONGO_URI not set. Database functions will not work.")
            return None
            
        client = MongoClient(mongo_uri, server_api=ServerApi('1'))
        # Ping the database to check connection
        client.admin.command('ping')
        print("Connected successfully to MongoDB")
        
        db_name = os.getenv("DB_NAME", "health_data_db")
        return client[db_name]
    except Exception as e:
        print(f"Error connecting to MongoDB: {e}")
        return None


# Pydantic models for API validation
class HealthAnalysisRequest(BaseModel):
    entries: List[Dict[str, Any]]
    timeframe: str = "week"  # week, month, year
    user_id: str

class ReflectionRequest(BaseModel):
    summaries: List[str]
    timeframe: str = "month"
    user_id: str


@app.get("/")
def read_root():
    """Health check endpoint"""
    return {"status": "healthy", "message": "LLM Analysis API is running"}


@app.get("/get_response")
def get_response(prompt: str, model: str = llm):
    """Get a raw response from the LLM model"""
    if not api_key:
        raise HTTPException(status_code=500, detail="API key not configured")
        
    try:
        client = genai.Client(api_key=api_key)
        response = client.models.generate_content(
            model=model,
            contents=prompt,
            config={
                'temperature': 0,
                'max_output_tokens': 2048,
            },
        )
        return {"response": response.text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error from LLM API: {str(e)}")


def get_json_response(prompt: str, model: str = llm):
    """Get a JSON formatted response from the LLM model"""
    if not api_key:
        raise HTTPException(status_code=500, detail="API key not configured")
        
    try:
        client = genai.Client(api_key=api_key)
        response = client.models.generate_content(
            model=model,
            contents=prompt,
            config={
                'response_mime_type': 'application/json',
                'temperature': 0
            },
        )
        return response.text
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error from LLM API: {str(e)}")


@app.post("/analyze_health_data")
def analyze_health_data(request: HealthAnalysisRequest):
    """Analyze health data entries using LLM"""
    if not api_key:
        raise HTTPException(status_code=500, detail="API key not configured")
    
    try:
        # Format entries for analysis
        entries_str = json.dumps(request.entries, indent=2)
        
        # Load the analysis prompt template
        with open("prompt/analyze_prompt.txt", "r", encoding="utf-8") as file:
            analysis_prompt_template = file.read()
        
        # Construct the prompt
        analysis_prompt = analysis_prompt_template + f"\nTimeframe: {request.timeframe}\nHealth Data: {entries_str}\nAnalysis:"
        
        # Get LLM response
        analysis_response = clean_extra_symbols(get_response(analysis_prompt).get("response"), prefix='Analysis')
        
        # Save to database if connected
        db = get_db()
        if db:
            analyses_collection = db.get_collection("health_analyses")
            analysis_doc = {
                "user_id": request.user_id,
                "timeframe": request.timeframe,
                "timestamp": datetime.utcnow(),
                "analysis": analysis_response,
                "entry_count": len(request.entries)
            }
            analyses_collection.insert_one(analysis_doc)
        
        return {"analysis": analysis_response}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error analyzing health data: {str(e)}")


@app.post("/generate_summary")
def generate_summary(request: HealthAnalysisRequest):
    """Generate a summary from health data entries"""
    if not api_key:
        raise HTTPException(status_code=500, detail="API key not configured")
    
    try:
        # First analyze the data
        entries_str = json.dumps(request.entries, indent=2)
        
        # Load the analysis prompt template
        with open("prompt/analyze_prompt.txt", "r", encoding="utf-8") as file:
            analysis_prompt_template = file.read()
        
        # Construct the analysis prompt
        analysis_prompt = analysis_prompt_template + f"\nTimeframe: {request.timeframe}\nHealth Data: {entries_str}\nAnalysis:"
        
        # Get analysis first
        analysis_response = clean_extra_symbols(get_response(analysis_prompt).get("response"), prefix='Analysis')
        
        # Now generate summary based on the analysis
        with open("prompt/summary_prompt.txt", "r", encoding="utf-8") as file:
            summary_prompt_template = file.read()
            
        summary_prompt = summary_prompt_template + f"\nTimeframe: {request.timeframe}\nAnalysis: {analysis_response}\nSummary:"
        summary_response = clean_extra_symbols(get_response(summary_prompt).get("response"), prefix='Summary')
        
        # Save to database if connected
        db = get_db()
        if db:
            summaries_collection = db.get_collection("health_summaries")
            summary_doc = {
                "user_id": request.user_id,
                "timeframe": request.timeframe,
                "timestamp": datetime.utcnow(),
                "summary": summary_response,
                "analysis": analysis_response,
                "entry_count": len(request.entries)
            }
            summaries_collection.insert_one(summary_doc)
        
        return {
            "summary": summary_response,
            "analysis": analysis_response
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating summary: {str(e)}")


@app.post("/generate_reflection")
def generate_reflection(request: ReflectionRequest):
    """Generate a reflection from multiple summaries"""
    if not api_key:
        raise HTTPException(status_code=500, detail="API key not configured")
    
    try:
        # Combine summaries
        combined_summaries = "\n".join(request.summaries)
        
        # Load the reflection prompt template
        with open("prompt/reflection_prompt.txt", "r", encoding="utf-8") as file:
            reflection_prompt_template = file.read()
        
        # Construct the prompt
        reflection_prompt = reflection_prompt_template + f"\nTimeframe: {request.timeframe}\nSummaries: {combined_summaries}\nReflection:"
        
        # Get LLM response
        reflection_response = clean_extra_symbols(get_response(reflection_prompt).get("response"), prefix='Reflection')
        
        # Save to database if connected
        db = get_db()
        if db:
            reflections_collection = db.get_collection("health_reflections")
            reflection_doc = {
                "user_id": request.user_id,
                "timeframe": request.timeframe,
                "timestamp": datetime.utcnow(),
                "reflection": reflection_response,
                "summary_count": len(request.summaries)
            }
            reflections_collection.insert_one(reflection_doc)
        
        return {"reflection": reflection_response}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating reflection: {str(e)}")


@app.post("/complete_health_template")
def complete_health_template(template: Dict[str, Any] = Body(...), user_input: str = Body(...)):
    """Fill in a JSON template with health data based on user input"""
    if not api_key:
        raise HTTPException(status_code=500, detail="API key not configured")
    
    try:
        # Convert template to string
        template_str = json.dumps(template, indent=2)
        
        # Load the fill prompt template
        with open("prompt/fill_prompt.txt", "r", encoding="utf-8") as file:
            fill_prompt_template = file.read()
        
        # Construct the prompt
        fill_prompt = fill_prompt_template + f"\nJSON Template: {template_str}\nUser Input: {user_input}\nOutput:"
        
        # Get JSON response
        json_response = get_json_response(fill_prompt)
        
        # Parse JSON response
        try:
            completed_template = json.loads(json_response)
            return completed_template
        except json.JSONDecodeError:
            # If JSON parsing fails, return the raw text
            return {"error": "Failed to parse JSON response", "raw_response": json_response}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error completing health template: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5002)
