import re
from datetime import datetime

def clean_extra_symbols(text, prefix=''):
    """
    Clean and format text from LLM response.
    
    Args:
        text (str): The text to clean
        prefix (str): Optional prefix to remove
        
    Returns:
        str: Cleaned and formatted text
    """
    if not text:
        return ""
        
    # Replace newlines with spaces
    text = text.replace('\n', ' ')
    text = text.replace('\r', ' ')
    text = text.replace('\t', ' ')
    
    # Remove any unwanted special characters
    cleaned_text = text
    
    # If prefix is provided, try to remove it and any text before it
    if prefix:
        text_lower = cleaned_text.lower()
        index = text_lower.find(prefix.lower())
        if index != -1:
            cleaned_text = cleaned_text[index+len(prefix):].strip()
            
            # Also remove any colon that might follow the prefix
            if cleaned_text.startswith(':'):
                cleaned_text = cleaned_text[1:].strip()
    
    # Remove extra spaces
    cleaned_text = ' '.join(cleaned_text.split())
    
    return cleaned_text


def format_date(date_obj=None):
    """
    Format a date object as YYYY-MM-DD or use current date if none provided.
    
    Args:
        date_obj (datetime, optional): Date object to format
        
    Returns:
        str: Formatted date string
    """
    if date_obj is None:
        date_obj = datetime.now()
        
    return date_obj.strftime('%Y-%m-%d')


def extract_sentiment(text):
    """
    Extract sentiment from text (positive, negative, neutral).
    
    Args:
        text (str): Input text
        
    Returns:
        str: Sentiment category
    """
    # Simple keyword-based approach
    positive_words = ['good', 'great', 'better', 'improve', 'positive', 'happy', 'well']
    negative_words = ['bad', 'worse', 'poor', 'negative', 'sad', 'unwell', 'pain', 'sick']
    
    # Count occurrences
    positive_count = sum(1 for word in positive_words if word.lower() in text.lower())
    negative_count = sum(1 for word in negative_words if word.lower() in text.lower())
    
    # Determine sentiment
    if positive_count > negative_count:
        return "positive"
    elif negative_count > positive_count:
        return "negative"
    else:
        return "neutral"