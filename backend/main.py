from flask import Flask, request, jsonify
from flask_cors import CORS
import whisper
import os
import uuid

app = Flask(__name__)
CORS(app, origins=["*"])
model = whisper.load_model("base")

# Temporäre Ordner
AUDIO_DIR = "data/audio"
TEXT_DIR = "data/text"
os.makedirs(AUDIO_DIR, exist_ok=True)
os.makedirs(TEXT_DIR, exist_ok=True)

print(f"🔧 AUDIO_DIR: {AUDIO_DIR}")
print(f"🔧 TEXT_DIR: {TEXT_DIR}")

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
        result = model.transcribe(audio_path)
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

if __name__ == "__main__":
    print("🚀 Backend startet auf Port 5001...")
    app.run(debug=True, host='0.0.0.0', port=5001)
