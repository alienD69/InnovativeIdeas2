from flask import Flask, request, jsonify
from flask_cors import CORS
import whisper
import os
import uuid
from datetime import datetime
import json

app = Flask(__name__)
CORS(app, origins=["*"])
model = whisper.load_model("base")

# Temporäre Ordner
AUDIO_DIR = "data/audio"
TEXT_DIR = "data/text"
FEEDBACK_DIR = "data/feedback"  # Neuer Ordner für Text-Feedback
os.makedirs(AUDIO_DIR, exist_ok=True)
os.makedirs(TEXT_DIR, exist_ok=True)
os.makedirs(FEEDBACK_DIR, exist_ok=True)

print(f"🔧 AUDIO_DIR: {AUDIO_DIR}")
print(f"🔧 TEXT_DIR: {TEXT_DIR}")
print(f"🔧 FEEDBACK_DIR: {FEEDBACK_DIR}")

@app.route("/transcribe", methods=["POST"])
def transcribe_audio():
    print("🎤 /transcribe endpoint called")
    
    if "file" not in request.files:
        print("❌ No file in request")
        return jsonify({"error": "No audio file uploaded"}), 400

    file = request.files["file"]
    print(f"📁 Dateiname: {file.filename}")
    print(f"📏 Dateigröße (Bytes): {len(file.read())}")
    file.seek(0)  # ganz wichtig – zurück zum Anfang für save()
    
    file_id = str(uuid.uuid4())
    audio_path = os.path.join(AUDIO_DIR, f"{file_id}.webm")
    text_path = os.path.join(TEXT_DIR, f"{file_id}.txt")
    
    print(f"💾 Speichere Audio: {audio_path}")

    try:
        # Speichern
        file.save(audio_path)
        print(f"🔍 Datei existiert: {os.path.exists(audio_path)}")
        print(f"🔍 Dateigröße: {os.path.getsize(audio_path) if os.path.exists(audio_path) else 'Nicht gefunden'}")

        
        # Transkribieren
        print("🔄 Starte Transkription...")
        result = model.transcribe(
            audio_path, 
            language='de',
            fp16=False,            # CPU-optimiert
            temperature=0.0,       # Weniger Halluzination
            no_speech_threshold=0.6 # Silence-Detection
        )
        transcript = result["text"]
        print(f"📝 Transkript: {transcript}")

        # Transkript speichern
        with open(text_path, "w", encoding='utf-8') as f:
            f.write(transcript)
        print(f"✅ Text gespeichert: {text_path}")
        print(f"🔍 Text-Datei existiert: {os.path.exists(text_path)}")
        if os.path.exists(text_path):
            with open(text_path, 'r') as f:
                print(f"🔍 Text-Inhalt: {f.read()}")
        # NICHT löschen für Debug
        # os.remove(audio_path)
        
        return jsonify({"id": file_id, "transcript": transcript})
    except Exception as e:
        print(f"❌ Fehler: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route("/save_text_feedback", methods=["POST"])
def save_text_feedback():
    print("📝 /save_text_feedback endpoint called")
    
    try:
        # JSON-Daten aus Request lesen
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
        
        food_name = data.get('food_name', '')
        feedback_text = data.get('feedback', '')
        rating = data.get('rating', 0)
        
        print(f"📄 Gericht: {food_name}")
        print(f"📄 Feedback: {feedback_text}")
        print(f"📄 Bewertung: {rating}")
        
        if not food_name or not feedback_text:
            return jsonify({"error": "food_name and feedback are required"}), 400
        
        # Eindeutige ID für das Feedback
        feedback_id = str(uuid.uuid4())
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        
        # Dateiname: timestamp_foodname_id.json
        safe_food_name = "".join(c for c in food_name if c.isalnum() or c in (' ', '-', '_')).rstrip()
        safe_food_name = safe_food_name.replace(' ', '_')
        filename = f"{timestamp}_{safe_food_name}_{feedback_id[:8]}.json"
        
        feedback_path = os.path.join(FEEDBACK_DIR, filename)
        
        # Feedback-Daten strukturiert speichern
        feedback_data = {
            "id": feedback_id,
            "timestamp": datetime.now().isoformat(),
            "food_name": food_name,
            "feedback_text": feedback_text,
            "rating": rating,
            "feedback_type": "text"
        }
        
        # Als JSON speichern
        with open(feedback_path, 'w', encoding='utf-8') as f:
            json.dump(feedback_data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ Text-Feedback gespeichert: {feedback_path}")
        
        return jsonify({
            "success": True,
            "feedback_id": feedback_id,
            "message": "Text-Feedback erfolgreich gespeichert"
        })
        
    except Exception as e:
        print(f"❌ Fehler beim Speichern des Text-Feedbacks: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route("/health", methods=["GET"])
def health_check():
    """Einfacher Health-Check Endpoint"""
    return jsonify({
        "status": "healthy",
        "endpoints": ["/transcribe", "/save_text_feedback", "/health"],
        "audio_dir": AUDIO_DIR,
        "text_dir": TEXT_DIR,
        "feedback_dir": FEEDBACK_DIR
    })

if __name__ == "__main__":
    print("🚀 Backend startet auf Port 5001...")
    print("📡 Verfügbare Endpoints:")
    print("   POST /transcribe - Audio-Transkription")
    print("   POST /save_text_feedback - Text-Feedback speichern")
    print("   GET /health - Health Check")
    app.run(debug=True, host='0.0.0.0', port=5001)
