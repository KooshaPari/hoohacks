import requests

# # example for reflection
# print("Testing reflection endpoint...")
# url = "http://localhost:8000/get_reflection"
# data = {
#     "context": "Lunchtime is either a quick meal at their desk or a short escape with colleagues to a nearby café. The afternoon drags on with more tasks, problem-solving, and sometimes unexpected challenges. As the workday ends, some stay late to finish urgent assignments, while others hurry home to unwind."
# }
# response = requests.get(url, params=data)
# print(response.text)


# example for analysis
print("\n\nTesting analysis endpoint...")
url = "http://localhost:8000/get_analysis"
data = {
    'target': 'Number of times drinking water of each day',
    'sequence_str': '5, 7, 9, 29, 5, 3, 2'
}
response = requests.get(url, params=data)
print(response.text)


# # example for summary
# print("\n\nTesting summary endpoint...")
# url = "http://localhost:8000/get_summary"
# data = {
#     "context": """John wakes up at 6:30 AM and drinks a glass of water. He stretches for a few minutes before heading to the bathroom to wash his face and brush his teeth. After freshening up, he feels alert and ready to start the day.
#     At 7:00 AM, John prepares a light breakfast, consisting of toast, eggs, and coffee. Around 10:30 AM, he drinks another glass of water. At noon, he has lunch, which usually includes a salad and grilled chicken. In the afternoon, he eats a small snack to maintain his energy. At 7:30 PM, he has dinner, usually consisting of rice, vegetables, and fish. Throughout the day, he drinks plenty of water to stay hydrated.
#     At 8:00 AM, John starts work. He spends the morning attending meetings, replying to emails, and completing tasks. In the afternoon, he continues working, occasionally taking short breaks to maintain focus. By 5:30 PM, he finishes work and feels relieved.
#     At 6:00 PM, John exercises for about 45 minutes, either jogging or doing strength training. After exercising, he drinks water and takes a shower to cool down.
#     Throughout the day, John experiences different emotions. In the morning, he feels refreshed and focused. By the afternoon, he starts to feel slightly tired but regains energy after a short walk. In the evening, he relaxes by watching TV, reading, or listening to music. Around 9:30 PM, he starts feeling sleepy and prepares for bed.
#     By 10:30 PM, John turns off the lights and goes to sleep, feeling satisfied with his day.""",
#     "date": "2023-10-01"
# }
# response = requests.get(url, params=data)
# print(response.text)