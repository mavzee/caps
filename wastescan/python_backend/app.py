from flask import Flask, request, jsonify
from inference_sdk import InferenceHTTPClient
import base64
import tempfile
import os
import json

app = Flask(__name__)

# Initialize the Roboflow client - Use environment variable for API key
CLIENT = InferenceHTTPClient(
    api_url="https://detect.roboflow.com",
    api_key=os.environ.get('ROBOFLOW_API_KEY', 'Uih1px5V5tb93au696tC')  # Fallback to your key
)

@app.route('/predict', methods=['POST'])
def predict():
    temp_path = None
    print("Received prediction request")  # Debug
    
    try:
        # Get JSON data from Flutter
        data = request.get_json()
        print(f"Received data type: {type(data)}")  # Debug
        
        if not data or 'image' not in data:
            print("No image in data")  # Debug
            return jsonify({"error": "No image data provided"}), 400
        
        print("Decoding base64 image...")  # Debug
        
        # Decode base64 image
        try:
            image_data = base64.b64decode(data['image'])
        except Exception as e:
            print(f"Base64 decode error: {str(e)}")  # Debug
            return jsonify({"error": f"Invalid base64 image: {str(e)}"}), 400
        
        # Save to temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as temp_file:
            temp_file.write(image_data)
            temp_path = temp_file.name
        
        print(f"Image saved to: {temp_path}")  # Debug
        print("Sending to Roboflow...")  # Debug
        
        # Perform inference using the Roboflow API
        result = CLIENT.infer(temp_path, model_id="waste-classification-uwqfy/1")
        print(f"Roboflow response: {json.dumps(result, indent=2)}")  # Debug
        
        # Format the response for Flutter
        formatted_result = {
            'predictions': [],
            'message': 'Success'
        }
        
        if 'predictions' in result and result['predictions']:
            for pred in result['predictions']:
                formatted_result['predictions'].append({
                    'class': pred.get('class', 'unknown'),
                    'confidence': pred.get('confidence', 0.0)
                })
        else:
            # If no predictions, add a default
            formatted_result['predictions'] = [{
                'class': 'unknown',
                'confidence': 0.0
            }]
        
        print(f"Formatted response: {json.dumps(formatted_result, indent=2)}")  # Debug
        
        return jsonify(formatted_result)
        
    except Exception as e:
        print(f"Error in /predict: {str(e)}")  # Debug
        import traceback
        traceback.print_exc()
        return jsonify({
            "error": str(e),
            "predictions": []
        }), 500
        
    finally:
        # Clean up temp file
        if temp_path and os.path.exists(temp_path):
            try:
                os.unlink(temp_path)
                print(f"Cleaned up temp file: {temp_path}")  # Debug
            except:
                pass

@app.route('/test', methods=['GET'])
def test():
    """Simple test endpoint to check if server is running"""
    return jsonify({
        "status": "ok",
        "message": "Flask server is running",
        "endpoints": ["/predict (POST)", "/test (GET)", "/health (GET)"]
    })

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({"status": "ok", "message": "Server is running"})

if __name__ == '__main__':
    print("Starting Waste Classification Server...")
    print("Model: waste-classification-uwqfy/1")
    # Use PORT environment variable for Render
    port = int(os.environ.get('PORT', 5000))
    print(f"Server running on port {port}")
    # Set debug=False for production
    app.run(host='0.0.0.0', port=port, debug=False)