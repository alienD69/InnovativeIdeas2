from flask import Flask, request, jsonify
import whisper
import os
import uuid

app = Flask(__name__)
model = whisper.load_model("base")

AUDIO_DIR = "data/audio"
TEXT_DIR = "data/text"
os.makedirs(AUDIO_DIR, exist_ok=True)
os.makedirs(TEXT_DIR, exist_ok=True)

@app.route("/transcribe", methods=["POST"])
def transcribe_audio():
    if "file" not in request.files:
        return jsonify({"error": "No audio file uploaded"}), 400

    file = request.files["file"]
    print("Dateiname:", file.filename)
    print("Dateigröße (Bytes):", len(file.read()))
    file.seek(0)  # ganz wichtig – zurück zum Anfang für save()
    file_id = str(uuid.uuid4())
    audio_path = os.path.join(AUDIO_DIR, f"{file_id}.webm")
    text_path = os.path.join(TEXT_DIR, f"{file_id}.txt")

    # Speichern
    file.save(audio_path)

    # Transkribieren
    result = model.transcribe(audio_path)
    transcript = result["text"]

    # Transkript speichern
    with open(text_path, "w") as f:
        f.write(transcript)

    return jsonify({"id": file_id, "transcript": transcript})

if __name__ == "__main__":
    app.run(debug=True)
