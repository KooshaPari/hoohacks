import requests

url = "http://localhost:8000/get_summary"  # 假設你的 API 在本機運行
data = {
    "model": "gpt-4",
    "prompt": "This study explores the impact of climate change on marine biodiversity, highlighting the decline of coral reefs due to rising sea temperatures."
}

response = requests.get(url, params=data)
print(response.json())