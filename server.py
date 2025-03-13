from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore
from test4 import create_square_around_point, check_point_and_square, Rectangle

app = Flask(__name__)
CORS(app)  # Enable CORS for cross-origin requests

# Initialize Firebase
cred = credentials.Certificate("serviceAccountKey.json")  # Add your Firebase service key
firebase_admin.initialize_app(cred)
db = firestore.client()

# Function to calculate missing rectangle coordinates
def calculate_coordinates(x1, y1, x4, y4):
    x2, y2 = x4, y1  # Upper-right
    x3, y3 = x1, y4  # Lower-left
    return x2, y2, x3, y3

# API route to calculate rectangle corners
@app.route('/calculate_rectangle', methods=['POST'])
def calculate_rectangle():
    data = request.get_json()
    x1, y1, x4, y4 = data['x1'], data['y1'], data['x4'], data['y4']
    x2, y2, x3, y3 = calculate_coordinates(x1, y1, x4, y4)

    return jsonify({"x2": x2, "y2": y2, "x3": x3, "y3": y3})

# API to create squares around points from Firestore
@app.route('/create_squares', methods=['GET'])
def create_squares():
    try:
        # Fetch all coordinates from Firestore
        coordinates_docs = db.collection("coordinates").stream()
        coordinates = [{"x": doc.to_dict()["x"], "y": doc.to_dict()["y"]} for doc in coordinates_docs]

        results = []
        for coord in coordinates:
            x, y = coord["x"], coord["y"]
            square = create_square_around_point(x, y, side_length=0.000015)

            results.append({
                "x": x, "y": y,
                "square": {
                    "x1": square.x1, "y1": square.y1,
                    "x2": square.x2, "y2": square.y2,
                    "x3": square.x3, "y3": square.y3,
                    "x4": square.x4, "y4": square.y4
                }
            })

        return jsonify({"squares": results})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# API to check if a point and square fit inside parking slots
@app.route('/check_parking_status', methods=['GET'])
def check_parking_status():
    try:
        print("Fetching coordinates from Firestore...")
        coordinates_docs = db.collection("coordinates").stream()
        coordinates = [
                    {
                        "x": float(doc.to_dict()["x"]),  
                        "y": float(doc.to_dict()["y"])
                    }
                    for doc in coordinates_docs
                ]
        print(f"Found {len(coordinates)} coordinates.")

        print("Fetching parking slots from Firestore...")
        slots_docs = db.collection("parking_slots").stream()
        rectangles = [
                Rectangle(
                    x1=float(doc.to_dict()["x1"]), y1=float(doc.to_dict()["y1"]),
                    x2=float(doc.to_dict()["x2"]), y2=float(doc.to_dict()["y2"]),
                    x3=float(doc.to_dict()["x3"]), y3=float(doc.to_dict()["y3"]),
                    x4=float(doc.to_dict()["x4"]), y4=float(doc.to_dict()["y4"])
                )
                for doc in slots_docs
            ]


        print(f"Found {len(rectangles)} parking slots.")

        results = []
        for coord in coordinates:
            x, y = coord["x"], coord["y"]
            print(f"Processing point ({x}, {y})...")

            square = create_square_around_point(x, y, side_length=0.000015)

            status = check_point_and_square(rectangles, x, y)

            results.append({
                "x": x, "y": y,
                "square": {
                    "x1": square.x1, "y1": square.y1,
                    "x2": square.x2, "y2": square.y2,
                    "x3": square.x3, "y3": square.y3,
                    "x4": square.x4, "y4": square.y4
                },
                "status": status
            })

        return jsonify({"results": results})

    except Exception as e:
        print(f"Error in check_parking_status: {e}")  # Log error
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
