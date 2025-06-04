# 🎤 InnovativeIdeas – Mensa Feedback Web-App

Dieses Projekt ist eine Flutter-Web-App zur Erfassung von Mensa-Feedback über Text- und Spracheingabe. Sprachaufnahmen werden lokal per Whisper transkribiert. Das Backend läuft mit Flask. Alles funktioniert lokal – ohne Online-Services.

---

## ✅ Voraussetzungen

### 🧠 Für alle:
- Internetverbindung für erste Installationen
- Zwei Terminalfenster (z. B. VS Code oder Terminal + PowerShell)
- Google Chrome installiert

---

## 💻 1. Installation auf **Mac**

### 🔧 Homebrew (wenn noch nicht installiert):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 📦 Python + ffmpeg:
```bash
brew install python3 ffmpeg
```

---

## 🖥️ 2. Installation auf **Windows**

### 📦 Installiere manuell:
- [Python 3.x (mit Häkchen bei "Add to PATH")](https://www.python.org/downloads/)
- [ffmpeg für Windows](https://www.gyan.dev/ffmpeg/builds/)  
  → ZIP entpacken  
  → Ordnerpfad zur `bin/` in die Systemumgebungsvariablen → `Path` eintragen

---

## 🌐 3. Flutter Web installieren (Mac & Windows)

### 🔧 Flutter SDK:
- [Flutter installieren (offizielle Anleitung)](https://docs.flutter.dev/get-started/install)

### ⚙️ Nach Installation im Terminal:
```bash
flutter doctor
flutter config --enable-web
```

---

## 📦 4. Python-Bibliotheken installieren

In deinem Projektverzeichnis (z. B. `InnovativeIdeas/`) im Terminal:

```bash
python3 -m pip install --upgrade pip
pip install flask flask-cors openai-whisper
```

Falls du Probleme mit `pip` hast, versuch:
```bash
python -m pip install flask flask-cors openai-whisper
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

## ▶️ Projekt starten

### 🟡 1. Backend starten (in Terminal 1)
```bash
cd backend
python3 main.py
```
→ läuft unter `http://localhost:5000`

---

### 🟠 2. Frontend starten (in Terminal 2)
```bash
cd frontend
flutter run -d chrome
```
→ öffnet automatisch die App im Chrome-Browser

---

## 🔧 Wichtig: CORS aktivieren im Backend

In deiner `main.py`:
```python
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
```

---

## 🛠️ Fehlerbehandlung

- **Mikrofon nicht erkannt?**
  → Browser-Zugriff erlauben  
- **Fehler beim Hochladen?**
  → Stelle sicher, dass das Backend läuft und `flask-cors` installiert ist
- **Audiodatei leer?**
  → Verwende `audio/webm` im `recorder.js` statt `mp3`

---

## 📌 Optional: Alles dokumentieren
```bash
pip freeze > requirements.txt
```

---

## ✅ Ignoriere unerwünschte Dateien in `.gitignore`
```gitignore
.DS_Store
.Rhistory
*.zip
```

---

## Viel Erfolg beim Testen!
