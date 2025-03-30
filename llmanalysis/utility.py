import re

def clean_extra_symbols(text, prefix=''):
    text = text.replace('\n', ' ')
    text = text.replace('\r', ' ')
    text = text.replace('\t', ' ')
    cleaned_text = re.sub(r'[^a-zA-Z0-9,.:!? ]', '', text)
    
    index = cleaned_text.find(prefix)
    if index != -1:
        # 根據找到的分割點切割字串
        print(f"Prefix '{prefix}' found at index {index}.")
        cleaned_text = cleaned_text[index+len(prefix)+1:]

    return cleaned_text.strip()