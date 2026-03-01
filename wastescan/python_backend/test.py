import requests

url = "https://detect.roboflow.com/waste-classification-uwqfy/1"
api_key = "Uih1px5V5tb93au696tC"  # Replace with your actual API key
image_path = "test.jpg"  # Use an actual image file

with open(image_path, "rb") as file:
    files = {"file": file}
    response = requests.post(url, headers={"Authorization": api_key}, files=files)

print("Status Code:", response.status_code)
print("Response:", response.json())
