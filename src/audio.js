// Microphone capture and Whisper transcription module
(function() {
  let mediaRecorder;
  let audioChunks = [];
  let transcriptionCallback = null;

  async function startRecording(onTranscription) {
    transcriptionCallback = onTranscription;
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    audioChunks = [];
    mediaRecorder = new MediaRecorder(stream);

    mediaRecorder.addEventListener('dataavailable', event => {
      audioChunks.push(event.data);
    });

    mediaRecorder.addEventListener('stop', async () => {
      const audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
      try {
        const text = await transcribeAudio(audioBlob);
        if (transcriptionCallback) transcriptionCallback(text);
      } catch (err) {
        console.error('Transcription error', err);
      }
    });

    mediaRecorder.start();
  }

  function stopRecording() {
    if (mediaRecorder && mediaRecorder.state !== 'inactive') {
      mediaRecorder.stop();
    }
  }

  async function transcribeAudio(blob) {
    const formData = new FormData();
    formData.append('file', blob, 'audio.webm');
    formData.append('model', 'whisper-1');
    // Replace with your Whisper or internal transcription endpoint
    const response = await fetch('https://api.openai.com/v1/audio/transcriptions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${window.superH?.openAiKey || ''}`
      },
      body: formData
    });
    const data = await response.json();
    return data.text || '';
  }

  window.superH = window.superH || {};
  window.superH.audio = { startRecording, stopRecording };
})();
