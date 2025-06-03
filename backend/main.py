from flask import Flask, request, jsonify
from flask_cors import CORS
import whisper
import os
import uuid
import tempfile

app = Flask(__name__)
CORS(app)
model = whisper.load_model("base")

# Verwende temporäre Ordner statt permanente Speicherung
TEMP_DIR = tempfile.gettempdir()
AUDIO_DIR = os.path.join(TEMP_DIR, "mensa_audio")
os.makedirs(AUDIO_DIR, exist_ok=True)

@app.route("/transcribe", methods=["POST"])
def transcribe_audio():
    if "file" not in request.files:
        return jsonify({"error": "No audio file uploaded"}), 400

    file = request.files["file"]
    file_id = str(uuid.uuid4())
    audio_path = os.path.join(AUDIO_DIR, f"{file_id}.webm")

    # Speichern (temporär)
    file.save(audio_path)

    try:
        # Transkribieren
        result = model.transcribe(audio_path)
        transcript = result["text"]
        
        # Temporäre Datei löschen
        os.remove(audio_path)
        
        return jsonify({"id": file_id, "transcript": transcript})
    except Exception as e:
        # Cleanup bei Fehler
        if os.path.exists(audio_path):
            os.remove(audio_path)
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5001)
