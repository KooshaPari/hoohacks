import requests

url = "http://localhost:8000/get_reflection"  # 假設你的 API 在本機運行
data = {
    # "model": "gpt-4",
    "context": "Lunchtime is either a quick meal at their desk or a short escape with colleagues to a nearby café. The afternoon drags on with more tasks, problem-solving, and sometimes unexpected challenges. As the workday ends, some stay late to finish urgent assignments, while others hurry home to unwind."
}

response = requests.get(url, params=data)
print(response.text)  # 檢查狀態碼是否為 200
# print(response.json())