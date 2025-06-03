let mediaRecorder;
let audioChunks = [];

function startRecording() {
    navigator.mediaDevices.getUserMedia({ audio: true })
        .then(stream => {
            mediaRecorder = new MediaRecorder(stream);
            audioChunks = [];

            mediaRecorder.ondataavailable = event => {
                if (event.data.size > 0) {
                    audioChunks.push(event.data);
                }
            };

            mediaRecorder.onstop = () => {
                const audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
                const file = new File([audioBlob], "feedback.webm", { type: "audio/webm" });
                sendAudioToBackend(file);
            };

            mediaRecorder.start();
            console.log("Recording started");
        })
        .catch(err => {
            console.error("Mikrofon nicht verfügbar:", err);
        });
}

function stopRecording() {
    if (mediaRecorder) {
        mediaRecorder.stop();
        console.log("Recording stopped");
    }
}

function sendAudioToBackend(file) {
    const formData = new FormData();
    formData.append("file", file);

    fetch("http://localhost:5000/transcribe", {
        method: "POST",
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        window.dispatchEvent(new CustomEvent("transcriptionResult", { detail: data.transcript }));
    })
    .catch(error => console.error("Fehler beim Hochladen:", error));
}
