# Mensa App

Frontend: Flutter
Backend: Python

Zum Starten des Frontends Befehl "flutter run -d chrome" ausführen



# 🎤 InnovativeIdeas – Mensa Feedback Web-App

Dieses Projekt ist eine Flutter-Web-App zur Erfassung von Mensa-Feedback über Text- und Spracheingabe. Sprachaufnahmen werden lokal per Whisper transkribiert. Das Backend läuft mit Flask.

---

## ✅ Voraussetzungen

### 📦 Flutter Web (Frontend)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Chrome installiert

```bash
flutter doctor
flutter config --enable-web
```

---

### 🐍 Python + Whisper (Backend)
- Python 3.9 oder höher
- pip installiert
- ffmpeg installiert

#### 📥 Installation (macOS):
```bash
brew install ffmpeg
python3 -m pip install --upgrade pip
pip install flask flask-cors openai-whisper
```

#### 📥 Installation (Linux):
```bash
sudo apt install ffmpeg
python3 -m pip install --upgrade pip
pip install flask flask-cors openai-whisper
```

---

## 📁 Projektstruktur

```
InnovativeIdeas/
├── backend/
│   ├── main.py                 # Flask + Whisper API
│   └── data/audio/            # gespeicherte Aufnahmen
│       data/text/             # gespeicherte Transkripte
├── frontend/
│   ├── lib/main.dart          # Flutter UI
│   ├── web/index.html         # HTML-Einbettung
│   └── web/recorder.js        # JS für Audioaufnahme
├── .gitignore
└── README.md
```

---

## ▶️ Lokales Starten

### 1. Backend starten (in Terminal 1):
```bash
cd backend
python3 main.py
```

→ läuft dann auf `http://localhost:5000`

---

### 2. Frontend starten (in Terminal 2):
```bash
cd frontend
flutter run -d chrome
```

→ öffnet die Web-App automatisch im Browser

---

## ⚠️ CORS-Probleme?

Falls Audio-Upload blockiert wird, stelle sicher:
- `flask-cors` ist installiert
- In `main.py` ist enthalten:

```python
from flask_cors import CORS
...
CORS(app)
```

---

## 💡 Weitere Tipps

- Um Pakete zu dokumentieren:
```bash
pip freeze > requirements.txt
```

- Um Dateien wie `.DS_Store` oder `.Rhistory` zu ignorieren:
```gitignore
.DS_Store
.Rhistory
```

---

## 🚀 Viel Erfolg bei der Entwicklung!
