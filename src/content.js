// Super H content script
(function() {
  function injectBanner() {
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
    container.textContent = 'Super H active';
    document.body.appendChild(container);
    console.log('Super H content script loaded');
  }

  function initConnectors() {
    console.log('Initializing connectors for audio, video, languages, whisper, terminal actions and web services');
    console.log('Audio connector ready (Whisper placeholder)');
    console.log('Video connector ready (placeholder)');
    ['en-US', 'es-419', 'fr-FR'].forEach(l => console.log('Language connector ready: ' + l));
    console.log('Terminal actions connector ready');
    console.log('Web services connector ready');
  }

  function onReady() {
    injectBanner();
    initConnectors();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', onReady);
  } else {
    onReady();
  }
})();
