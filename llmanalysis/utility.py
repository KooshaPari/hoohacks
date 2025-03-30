import re

def clean_extra_symbols(text, prefix=''):
    text = text.replace('\n', ' ')
    text = text.replace('\r', ' ')
    text = text.replace('\t', ' ')
    cleaned_text = re.sub(r'[^a-zA-Z0-9,.:!? ]', '', text)
    
    text_lower = cleaned_text.lower()
    index = text_lower.find(prefix) + len(prefix)
    if index != -1:
        cleaned_text = cleaned_text[index+len(prefix)+1:].strip()
        
        index = cleaned_text.find(':')
        if index != -1:
            cleaned_text = cleaned_text[index+1:].strip()

    return cleaned_text