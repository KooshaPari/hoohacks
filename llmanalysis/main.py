import os
from dotenv import load_dotenv
import json
from google import genai
from fastapi import FastAPI
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

load_dotenv()
app = FastAPI()

def get_api_key():
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise ValueError("GEMINI_API_KEY environment variable is not set. Please set it to your Gemini API key.")
    return api_key

def get_db():
    mongo_uri = os.getenv("MONGO_URI")
    client = MongoClient(mongo_uri)
    db_name = os.getenv("DB_NAME", "llm_analysis")
    return client[db_name]

@app.get("/get_response")
def get_response(prompt='', model="gemini-2.0-flash"):
    client = genai.Client(api_key=get_api_key())
    response = client.models.generate_content(
        model= model,
        contents=prompt
    )
    return response.text

def get_config_response(prompt='', model="gemini-2.0-flash"):
    client = genai.Client(api_key=get_api_key())
    response = client.models.generate_content(
        model= model,
        contents=prompt,
        config={
            'response_mime_type': 'application/json',
        },
    )
    return response.text

@app.get("/get_analysis")
def llm_analysis(target='', sequence=[]):
    with open("prompt/analyzeanalysis_prompt.txt", "r", encoding="utf-8") as file:
            analysis_prompt_template = file.read()
    analysis_prompt = analysis_prompt_template + f"\nTopic: {target}\nList: {', '.join(sequence)}\nOutput:"
    analysis_repsonse = get_response(analysis_prompt)

    return analysis_repsonse

@app.get("/get_summary")
def llm_summary_week(context='', date=''):
    
    if not context:
        data_window = 7 # weekly
        db_list = {} # { "Topic1": ["item1", "item2"], "Topic2": ["item3", "item4"] }
        descriptions = []
        
        for k, v in db_list.items():
            descriptions.append(llm_analysis(k, v))
    else:
        descriptions = [context]
    
    with open("prompt/summary_prompt.txt", "r", encoding="utf-8") as file:
        summary_prompt_template = file.read()
    summary_prompt = summary_prompt_template + f"\nDescriptions: {' '.join(descriptions)}\nSummary:"
    summary_response = get_response(summary_prompt)
    
    # push back to db
    
    return summary_response


@app.get("/get_reflection")
def llm_reflect(context='', date=''):
    
    data_window = 4 # 4 week for a month
    summary = [] # from db
    
    with open("prompt/reflection_prompt.txt", "r", encoding="utf-8") as file:
        reflection_prompt_template = file.read()
    
    reflection_prompt = reflection_prompt_template + f"Summary: {summary}\nReflection:"
    reflection_response = get_response(reflection_prompt)
    
    # push back to db
    
    return reflection_response

@app.get("/get_fill")
def llm_response(prompt=''):
    with open("prompt/data_template.json", "r", encoding="utf-8") as file:
        data_template = json.load(file)
    
    reflection_prompt = data_template + f"JSON Template: {prompt}\nOutput:"
    reflection_response = get_config_response(reflection_prompt)

    # push back to db
    
    return reflection_response

def main():
    prompt = "What is the capital of France?"
    response = llm_response(prompt)
    print(f"Prompt: {prompt}")
    print(f"Response: {response}")

if __name__ == "__main__":
    main()