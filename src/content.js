// Super H content script with voice features
(function() {
  const container = document.createElement('div');
  container.id = 'super-h-banner';
  container.style.position = 'fixed';
  container.style.top = '10px';
  container.style.right = '10px';
  container.style.zIndex = '9999';
  container.style.background = '#ffeb3b';
  container.style.color = '#000';
  container.style.padding = '4px 8px';
  container.style.borderRadius = '4px';
  container.style.fontSize = '12px';
  container.textContent = 'Super H voice ready';

  const startBtn = document.createElement('button');
  startBtn.textContent = 'Start';
  startBtn.style.marginLeft = '8px';
  const stopBtn = document.createElement('button');
  stopBtn.textContent = 'Stop';
  stopBtn.style.marginLeft = '4px';
  const transcriptionDiv = document.createElement('div');
  transcriptionDiv.style.marginTop = '4px';
  transcriptionDiv.style.maxWidth = '200px';
  transcriptionDiv.style.wordWrap = 'break-word';

  container.appendChild(startBtn);
  container.appendChild(stopBtn);
  container.appendChild(transcriptionDiv);
  document.body.appendChild(container);

  startBtn.addEventListener('click', () => {
    window.superH.audio.startRecording(text => {
      transcriptionDiv.textContent = text;
    });
  });

  stopBtn.addEventListener('click', () => {
    window.superH.audio.stopRecording();
  });

  function speak(text) {
    const utterance = new SpeechSynthesisUtterance(text);
    speechSynthesis.speak(utterance);
  }

  const observer = new MutationObserver(mutations => {
    for (const mutation of mutations) {
      for (const node of mutation.addedNodes) {
        if (node.nodeType === Node.ELEMENT_NODE && node.matches('div[data-message-author-role="assistant"]')) {
          const text = node.innerText;
          speak(text);
        }
      }
    }
  });

  observer.observe(document.body, { childList: true, subtree: true });
})();
