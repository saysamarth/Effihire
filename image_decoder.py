import base64
import os
from datetime import datetime
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/decode-image', methods=['POST'])
def decode_image():
    try:
        # Get the JSON data from the request
        data = request.get_json()
        
        if not data or 'base64_string' not in data:
            return jsonify({'error': 'No base64_string provided'}), 400
        
        base64_string = data['base64_string']
        
        # Remove data URL prefix if present
        if base64_string.startswith('data:image'):
            base64_string = base64_string.split(",")[1]
        
        # Decode Base64 string
        img_data = base64.b64decode(base64_string)
        
        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"ocr_image_{timestamp}.jpg"
        
        # Save to file in the same directory as the script
        script_dir = os.path.dirname(os.path.abspath(__file__))
        filepath = os.path.join(script_dir, filename)
        
        with open(filepath, "wb") as f:
            f.write(img_data)
        
        print(f"✅ Image saved as {filename}")
        print(f"📁 Full path: {filepath}")
        
        return jsonify({
            'success': True,
            'filename': filename,
            'filepath': filepath,
            'message': f'Image saved as {filename}'
        })
        
    except Exception as e:
        print(f"❌ Error decoding image: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("🚀 Starting Base64 Image Decoder Server...")
    print("📡 Server will run on http://localhost:5000")
    print("📝 Send POST requests to /decode-image with JSON: {'base64_string': 'your_base64_here'}")
    print("🔄 Waiting for image data...")
    
    app.run(host='0.0.0.0', port=5003, debug=True)